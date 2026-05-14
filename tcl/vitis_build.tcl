# run with: xsct vitis_build.tcl [optional: path/to/build_dir]

file delete -force ../builds/vitis_ws
setws ../builds/vitis_ws

# Default to latest build dir, but allow override: xsct vitis_build.tcl ../builds/build_100526
if {$argc > 0} {
    set latest_build [lindex $argv 0]
} else {
    set build_dirs [glob -type d ../builds/build_*]
    set sorted [lsort -command {apply {{a b} {
        expr {[file mtime $a] - [file mtime $b]}
    }}} $build_dirs]
    set latest_build [lindex $sorted end]
}

set xsa_file [lindex [glob $latest_build/*.xsa] 0]
set bit_file [lindex [glob $latest_build/*.runs/impl_1/*.bit] 0]
puts "Using XSA: $xsa_file"
puts "Using BIT: $bit_file"

# Create platform from exported .xsa
platform create -name {zybo_platform} -hw $xsa_file
platform write

# Create standalone domain on Cortex-A9 core 0
domain create -name {standalone} -os {standalone} -proc {ps7_cortexa9_0}

# Create empty C app
app create -name {audio_analyzer} \
    -platform {zybo_platform} \
    -domain {standalone} \
    -template {Empty Application(C)}

# Import sources (preserves files, drops directory structure)
importsources -name {audio_analyzer} -path {../software}
# Subdirs as include paths so flat #includes in main.c resolve
app config -name {audio_analyzer} include-path {../src/i2c}
app config -name {audio_analyzer} include-path {../src/bram}
app config -name {audio_analyzer} include-path {../src/irq}
app config -name {audio_analyzer} include-path {../src/uart}

# Build
app build -name {audio_analyzer}

# Program and run
# connect
# targets -set -filter {name =~ "APU*"}
# fpga $bit_file
# targets -set -filter {name =~ "ARM*#0"}
# # Initialize PS (DDR controller, clocks) — replaces FSBL when loading over JTAG
# source ../builds/vitis_ws/zybo_platform/export/zybo_platform/hw/ps7_init.tcl
# ps7_init
# ps7_post_config
# dow ../builds/vitis_ws/audio_analyzer/Debug/audio_analyzer.elf
# con

