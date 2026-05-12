vivado_build.tcl:
	- Source this in the Vivado TCL console to generate the BD and associated wrapper

vitis_built.tcl:
	- Source "xsct vitis_build.tcl <optional/path/to/build/directory>" in the terminal to build the PS application
	- Also programs the FPGA 

vitis_run.tcl
	- Source "xsct vitis_run.tcl" in the terminal to program the Zybo
	- Opens Hardware Manager, connects to device, programs FPGA and runs .elf file


