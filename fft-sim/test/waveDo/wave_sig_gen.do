onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group SigGen /signal_generator_tb/signal_generator_inst/clk_50
add wave -noupdate -expand -group SigGen /signal_generator_tb/signal_generator_inst/i_start
add wave -noupdate -expand -group SigGen /signal_generator_tb/signal_generator_inst/i_reset
add wave -noupdate -expand -group SigGen /signal_generator_tb/signal_generator_inst/i_tready
add wave -noupdate -expand -group SigGen -radix binary /signal_generator_tb/signal_generator_inst/o_tdata
add wave -noupdate -expand -group SigGen /signal_generator_tb/signal_generator_inst/o_tvalid
add wave -noupdate -expand -group SigGen /signal_generator_tb/signal_generator_inst/o_tlast
add wave -noupdate -expand -group SigGen -radix unsigned /signal_generator_tb/signal_generator_inst/r_addra
add wave -noupdate -expand -group SigGen -format Analog-Step -height 80 -max 32767.0 -min -7098.0 -radix decimal /signal_generator_tb/signal_generator_inst/w_re_data
add wave -noupdate -expand -group SigGen /signal_generator_tb/signal_generator_inst/r_tlast
add wave -noupdate -expand -group SigGen /signal_generator_tb/signal_generator_inst/r_tvalid
add wave -noupdate -expand -group SigGen /signal_generator_tb/signal_generator_inst/r_has_been_tready
add wave -noupdate -group SPmem /signal_generator_tb/signal_generator_inst/SPmem_inst/clk
add wave -noupdate -group SPmem /signal_generator_tb/signal_generator_inst/SPmem_inst/i_addra
add wave -noupdate -group SPmem /signal_generator_tb/signal_generator_inst/SPmem_inst/i_dina
add wave -noupdate -group SPmem /signal_generator_tb/signal_generator_inst/SPmem_inst/i_wea
add wave -noupdate -group SPmem /signal_generator_tb/signal_generator_inst/SPmem_inst/i_ena
add wave -noupdate -group SPmem /signal_generator_tb/signal_generator_inst/SPmem_inst/o_douta
add wave -noupdate -group SPmem /signal_generator_tb/signal_generator_inst/SPmem_inst/addra
add wave -noupdate -group SPmem /signal_generator_tb/signal_generator_inst/SPmem_inst/dina
add wave -noupdate -group SPmem /signal_generator_tb/signal_generator_inst/SPmem_inst/wea
add wave -noupdate -group SPmem /signal_generator_tb/signal_generator_inst/SPmem_inst/ena
add wave -noupdate -group SPmem /signal_generator_tb/signal_generator_inst/SPmem_inst/regcea
add wave -noupdate -group SPmem /signal_generator_tb/signal_generator_inst/SPmem_inst/douta
add wave -noupdate -group SPmem /signal_generator_tb/signal_generator_inst/SPmem_inst/douta_reg
add wave -noupdate -group SPmem /signal_generator_tb/signal_generator_inst/SPmem_inst/ram_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {53470000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {78046500 ps}
