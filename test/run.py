#!/usr/bin/env python3

# ============================================================
from helper_functions import fir_data_checker
from scripts.models.dds import dds
from scripts.synth_and_test.dds import dds_checker
from pathlib import Path
from vunit import VUnit
import random


# ============================================================
def encode(config: dict) -> str:
    return ", ".join(["%s:%s" % (key, str(config[key])) for key in config])


# ============================================================
# Setup

VU = VUnit.from_argv(compile_builtins=False)
VU.add_vhdl_builtins()

# Enable location preprocessing but exclude all but check_false to make the example less bloated
VU.enable_location_preprocessing(
    exclude_subprograms=[
        "debug",
        "info",
        "check",
        "check_failed",
        "check_true",
        "check_implication",
        "check_stable",
        "check_equal",
        "check_not_unknown",
        "check_zero_one_hot",
        "check_one_hot",
        "check_next",
        "check_sequence",
        "check_relation",
    ]
)
VU.enable_check_preprocessing()

# ============================================================
# Directories

# Source directory
src_dir = (Path(__file__).parent / ".." / "src").resolve()

# Testbench directory
tb_dir = (Path(__file__).parent).resolve()

# Waveform .do directory
wave_dir = (Path(__file__).parent / "wave").resolve()

lib = VU.add_library("lib")

# ============================================================
# Add sources
for src_file in src_dir.rglob("*.vhd"):
    lib.add_source_files(src_file)

# ============================================================
# Add testbenches
for tb_file in tb_dir.rglob("tb_*"):
    if tb_file.parent.name == "xsim-tests":
        # Vivado XSIM files
        continue
    if tb_file.is_relative_to(tb_dir / "vunit_out"):
        # Skipping vunit_out directory
        continue
    if tb_file.is_relative_to(tb_dir / "wave"):
        # Skipping .do directory
        continue
    lib.add_source_files(tb_file)

# ============================================================
# Add waves
for tb in lib.get_test_benches():
    wave_do = wave_dir / f"{tb.name}.do"
    if wave_do.is_file():
        print(f"- Found existing .do file at: {wave_do}\r")
        tb.set_sim_option("modelsim.init_file.gui", "launch.tcl")
        tb.set_sim_option(
            "modelsim.vsim_flags.gui",
            [
                "-t 1ps",
                "-fsmdebug",
                '-voptargs="+acc"',
                "-coverage",
                "-debugDB",
                "-do",
                f"{{{wave_do.as_posix()}}}",
            ],
        )
    else:
        print(f"- No existing .do file for {tb.name}. Running add_waveforms.tcl\r")
        tb.set_sim_option("modelsim.init_file.gui", "add_waveforms.tcl")
        tb.set_sim_option(
            "modelsim.vsim_flags.gui",
            ["-t 1ps", "-fsmdebug", '-voptargs="+acc"', "-coverage", "-debugDB"],
        )
# ============================================================
# Add test configs


# --------------------------------------------------
# FIR filter
# --------------------------------------------------
testbench = lib.entity("fir_filter_tb")
test = testbench.test("filter-cutoffs")

# Set generic
filter_configs = [
    dict(filter_type="lp", filter_cutoff="1000"),
    dict(filter_type="lp", filter_cutoff="5000"),
    dict(filter_type="lp", filter_cutoff="15000"),
    dict(filter_type="hp", filter_cutoff="1000"),
    dict(filter_type="hp", filter_cutoff="5000"),
    dict(filter_type="hp", filter_cutoff="15000"),
]

noise_stimuli = "white_10khz_16bits.txt"
dual_tone_stimuli = "2_tone_10khz_16bits.txt"

# Add checker
fir_checker = fir_data_checker()

for cfg in filter_configs:
    test.add_config(
        name=f'{cfg["filter_type"]}_{cfg["filter_cutoff"]}_hz',
        generics=dict(encoded_tb_cfg=encode(cfg)),
        # pre_config=fir_checker.pre_config_wrapper(a_type=dual_tone_stimuli),
        pre_config=fir_checker.pre_config_wrapper(a_type=noise_stimuli),
        post_check=fir_checker.post_check,
    )


# --------------------------------------------------
# FIR filter bank
# --------------------------------------------------
test = lib.entity("filter_bank_tb").test("filter-combos")

filter_configs = [
    dict(filter_1="off", fc_1="0", filter_2="off", fc_2="0"),
    dict(filter_1="lp", fc_1="5000", filter_2="off", fc_2="5000"),
    dict(filter_1="off", fc_1="5000", filter_2="hp", fc_2="5000"),
    dict(filter_1="lp", fc_1="15000", filter_2="hp", fc_2="15000"),
    dict(filter_1="lp", fc_1="15000", filter_2="hp", fc_2="5000"),
    dict(filter_1="lp", fc_1="3000", filter_2="hp", fc_2="18000"),
]

noise_stimuli = "white_10khz_16bits.txt"

fir_bank_checker = fir_data_checker()

for cfg in filter_configs:
    test.add_config(
        name=f'lp_{"off".upper() if cfg["filter_1"] == "off" else cfg["fc_1"]}'
        + f'_hp_{"off".upper() if cfg["filter_2"] == "off" else cfg["fc_2"]}',
        generics=dict(encoded_tb_cfg=encode(cfg)),
        pre_config=fir_bank_checker.pre_config_wrapper(noise_stimuli),
        post_check=fir_bank_checker.post_check,
    )

test = lib.entity("filter_bank_tb").test("filter-incr")
filter_configs = [
    dict(filter_1="lp", fc_1="15000", filter_2="hp", fc_2="1000"),
]
for cfg in filter_configs:
    test.add_config(
        name=f'lp_{"off".upper() if cfg["filter_1"] == "off" else cfg["fc_1"]}'
        + f'_hp_{"off".upper() if cfg["filter_2"] == "off" else cfg["fc_2"]}_to_10k_hp',
        generics=dict(encoded_tb_cfg=encode(cfg)),
        pre_config=fir_bank_checker.pre_config_wrapper(noise_stimuli),
        post_check=fir_bank_checker.post_check,
    )
# --------------------------------------------------
# DDS
# --------------------------------------------------
testbench = lib.entity("dds_tb")
test = testbench.test("auto")

# Configuration
G_FREQ_WIDTH = 22  # 2²² / FS ≈ 4.19 MHz max frequency
G_DATA_WIDTH = 16
G_ACCUMULATOR_WIDTH = 32
G_LUT_ADDR_WIDTH = 10
G_SYS_CLK_HZ = int(100e6)

cfg = dict(
    G_FREQ_WIDTH=G_FREQ_WIDTH,
    G_DATA_WIDTH=G_DATA_WIDTH,
    G_ACCUMULATOR_WIDTH=G_ACCUMULATOR_WIDTH,
    G_LUT_ADDR_WIDTH=G_LUT_ADDR_WIDTH,
    G_SYS_CLK_HZ=G_SYS_CLK_HZ,
)

dds_checker_obj = dds_checker(a_cfg=cfg)

# Create a list of random frequencies bounded by 0 to 2*22
frequency_list = [int(random.uniform(0, 2**G_FREQ_WIDTH)) for _ in range(8)]

test.add_config(
    name=f"{G_FREQ_WIDTH}bit_freq_{G_DATA_WIDTH}bit_data_{G_ACCUMULATOR_WIDTH}bit_acc_{G_LUT_ADDR_WIDTH}lut_{int(G_SYS_CLK_HZ/1e6)}MHz_clk",
    generics=dict(
        G_FREQ_WIDTH=cfg["G_FREQ_WIDTH"],
        G_DATA_WIDTH=cfg["G_DATA_WIDTH"],
        G_ACCUMULATOR_WIDTH=cfg["G_ACCUMULATOR_WIDTH"],
        G_LUT_ADDR_WIDTH=cfg["G_LUT_ADDR_WIDTH"],
        G_SYS_CLK_HZ=cfg["G_SYS_CLK_HZ"],
        G_INIT_FILE=f"dds_lut.txt",
    ),
    pre_config=dds_checker_obj.pre_config_wrapper(
        a_freq_list=frequency_list, a_cfg=cfg
    ),
    post_check=dds_checker_obj.post_check_wrapper(a_freq_list=frequency_list, a_cfg=cfg, a_save_plot=True),
)
# ----------------------------
# Another testbench...
# ----------------------------
# And another testbench etc.
# ============================================================

VU.add_compile_option("modelsim.vcom_flags", ["+acc=npr", '+cover="sbcef'])

VU.main()
