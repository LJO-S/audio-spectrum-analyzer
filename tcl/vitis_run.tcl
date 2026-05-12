# Program and run
connect
targets -set -filter {name =~ "APU*"}
fpga ../builds/vitis_ws/audio_analyzer/_ide/bitstream/top_bd_wrapper_wrapper.bit
targets -set -filter {name =~ "ARM*#0"}
# Initialize PS (DDR controller, clocks) — replaces FSBL when loading over JTAG
source ../builds/vitis_ws/zybo_platform/export/zybo_platform/hw/ps7_init.tcl
ps7_init
ps7_post_config
dow ../builds/vitis_ws/audio_analyzer/Debug/audio_analyzer.elf
con