#!/usr/bin/env python3


from pathlib import Path
from vunit import VUnit


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

src_dir = Path(__file__).parent / ".." / "src"
tb_dir = Path(__file__).parent

lib = VU.add_library("lib")

for src_file in src_dir.glob("*.vhd"):
    lib.add_source_files(src_file)

for tb_file in tb_dir.glob("tb_*"):
    lib.add_source_files(tb_file)


VU.add_compile_option(
    "modelsim.vcom_flags", ["+acc=npr", '+cover="sbcef', "-check_synthesis"]
)

VU.set_sim_option(
    "modelsim.vsim_flags.gui",
    ["-t 1ps", "-fsmdebug", '-voptargs="+acc"', "-coverage", "-debugDB"],
)

VU.set_sim_option("modelsim.init_file.gui", "add_waveforms.tcl")


VU.main()
