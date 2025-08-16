#!/usr/bin/env python3

# ============================================================
import helper_functions
from pathlib import Path
from vunit import VUnit


# ============================================================
def encode(config: dict) -> str:
    return ", ".join(["%s:%s" % (key, str(config[key])) for key in config])


# ============================================================
# Setup

VU = VUnit.from_argv()
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
    if src_file.name == "project_top.vhd":
        continue
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
# Add generics
# ----------------------------
# FIR filter
filter_configs = [
    dict(filter_type="lp", filter_cutoff="1000"),
    dict(filter_type="lp", filter_cutoff="5000"),
    dict(filter_type="lp", filter_cutoff="15000"),
    dict(filter_type="hp", filter_cutoff="1000"),
    dict(filter_type="hp", filter_cutoff="5000"),
    dict(filter_type="hp", filter_cutoff="15000"),
]

testbench = lib.entity("fir_filter_tb")
test = testbench.test("filter-cutoffs")

for cfg in filter_configs:
    test.add_config(
        name=f"{cfg["filter_type"]}_{cfg["filter_cutoff"]}_hz",
        generics=dict(encoded_tb_cfg=encode(cfg)),
    )
# ----------------------------
# Another testbench...
# ----------------------------
# And another testbench etc.
# ============================================================

VU.add_compile_option(
    "modelsim.vcom_flags", ["+acc=npr", '+cover="sbcef', "-check_synthesis"]
)

VU.main()
