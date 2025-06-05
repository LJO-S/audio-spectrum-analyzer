# Check if the wave.do file exists
if { [file exists wave.do] } {
    # Load the existing wave.do file
    puts "wave.do file found. Loading existing waveform configuration."
    do wave.do
} else {
    # No wave.do found, adding all waves from the top module
    puts "wave.do file not found. Adding all waveforms from the top module."
    view wave
    wave zoom full
    add wave -r -radixshowbase 0 /*
}
#vunit_restart
add log -r /*
vunit_run
# Optionally run the simulation
# run -all