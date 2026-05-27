#!/usr/bin/env python3

# ============================================================
from helper_functions import fir_data_checker
from pathlib import Path
from shutil import rmtree
from vunit import VUnit, VUnitCLI
from vunit.vivado import *
import random

# Seed random number generator for reproducibility
random.seed(42)

import sys
import os

sys.path.append("../")
from scripts.models.dds import dds
from scripts.synth_and_test.dds import dds_checker
from scripts.synth_and_test.window import window_checker
from scripts.synth_and_test.decimation import decimation_checker


# ============================================================
def encode(config: dict) -> str:
    return ", ".join(["%s:%s" % (key, str(config[key])) for key in config])


# ============================================================
# Setup
cli = VUnitCLI(description="VUnit project with Vivado Synthesis support")
cli.parser.add_argument(
    "--synth",
    type=str,
    default=None,
    help="Run Vivado synthesis on the specified entity",
)
cli.parser.add_argument(
    "--batch",
    action="store_true",
    default=False,
    help="Run in batch mode",
)
args = cli.parse_args()

VU = VUnit.from_args(args=args, compile_builtins=False)
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
frequency_list = [int(random.uniform(0, 2**G_FREQ_WIDTH)) for _ in range(15)]

test.add_config(
    name=f"multiple_freqs",
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
    post_check=dds_checker_obj.post_check_wrapper(
        a_freq_list=frequency_list, a_cfg=cfg, a_save_plot=True
    ),
)
# --------------------------------------------------
# Window Function
# --------------------------------------------------
testbench = lib.entity("window_function_time_tb")
test = testbench.test("auto")

# Configuration
G_INPUT_DATA_WIDTH = 16
G_INPUT_DATA_DEPTH = 1024
G_WINDOW_DATA_WIDTH = 16

for window_type in ["hamming", "hann", "blackman"]:
    window_checker_obj = window_checker(
        a_window_type=window_type,
        a_window_length=G_INPUT_DATA_DEPTH,
        a_data_width=G_WINDOW_DATA_WIDTH,
        a_sampling_freq=44100,  # Assuming 44.1 kHz sampling frequency for test signal generation
    )

    test.add_config(
        name=f"{window_type.upper()}",
        generics=dict(
            G_INPUT_DATA_WIDTH=G_INPUT_DATA_WIDTH,
            G_INPUT_DATA_DEPTH=G_INPUT_DATA_DEPTH,
            G_WINDOW_DATA_WIDTH=G_WINDOW_DATA_WIDTH,
        ),
        pre_config=window_checker_obj.pre_config_wrapper(a_input_samples=5e3),
        post_check=window_checker_obj.post_check_wrapper(),
    )

# ----------------------------
# Decimation Bank
# ----------------------------
testbench = lib.entity("decimation_bank_tb")
test = testbench.test("auto")
FS = 48.8e3

checker = decimation_checker(a_fpass=100, a_atten_db=60, a_fs=int(FS))
for factor in [2, 4, 8, 16]:
    test.add_config(
        name=f"div_{factor}",
        generics=dict(G_MULTIRATE_FACTOR=factor),
        pre_config=checker.pre_config_wrapper(a_n_samples=8192),
        post_check=checker.post_check_wrapper(a_decimation_factor=factor),
    )

test = testbench.test("visual")
test.add_config(
    name=f"div_2_4_8_16",
    pre_config=checker.pre_config_wrapper(a_n_samples=8192),
)

# ----------------------------
# Another testbench...
# ----------------------------
# And another testbench etc.

# ============================================================
VU.add_compile_option("modelsim.vcom_flags", ["+acc=npr", '+cover="sbcef'])
# ============================================================

# Synthesize or simulate
if args.synth:
    print(f"--- Starting Vivado Synthesis for entity: {args.synth} ---")
    root = Path(__file__).parent.resolve()
    project_name = "vivado"
    if (root / project_name).exists():
        rmtree(root / project_name)
    # Path to TCL script
    tcl_script = (
        Path(__file__).parent / ".." / "scripts" / "tcl" / "generate_project.tcl"
    )
    try:
        run_vivado(
            tcl_file_name=str(tcl_script),
            tcl_args=[root, project_name, args.synth, src_dir, not (args.batch)],
            vivado_path=None,  # Uses default 'vivado' command
        )
        print("--- Synthesis Complete! ---")
    except Exception as e:
        print(f"Synthesis failed: {e}")
        sys.exit(1)
else:
    VU.main()
