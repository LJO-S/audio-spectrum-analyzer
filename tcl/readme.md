build_project.tcl:
	- Source "vivado -mode batch -source build_project.tcl" in terminal to build project from scratch
	- Also looks for DCP files in previous builds to speed everything up

vivado_build.tcl:
	- Source this in the Vivado TCL console to generate the BD and associated wrapper

vitis_build.tcl:
	- Source "xsct vitis_build.tcl <optional/path/to/build/directory>" in the terminal to build the PS application

vitis_run.tcl
	- Source "xsct vitis_run.tcl" in the terminal to program the Zybo
	- Opens Hardware Manager, connects to device, programs FPGA and runs .elf file


