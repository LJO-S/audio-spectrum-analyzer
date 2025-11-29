onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group tb -radix unsigned /i2s_deser_tb/clk_100
add wave -noupdate -expand -group tb -radix unsigned /i2s_deser_tb/i_lrclk
add wave -noupdate -expand -group tb -radix unsigned /i2s_deser_tb/i_bclk
add wave -noupdate -expand -group tb -radix unsigned /i2s_deser_tb/i_serial_data
add wave -noupdate -expand -group tb -radix binary /i2s_deser_tb/o_data
add wave -noupdate -expand -group tb -radix unsigned /i2s_deser_tb/o_valid
add wave -noupdate -expand -group tb -radix unsigned /i2s_deser_tb/tb_counter
add wave -noupdate -expand -group tb -radix unsigned /i2s_deser_tb/tb_enable
add wave -noupdate -expand -group tb -radix unsigned /i2s_deser_tb/tb_iis_state
add wave -noupdate -expand -group tb -radix unsigned /i2s_deser_tb/tb_bit_cntr
add wave -noupdate -expand -group tb /i2s_deser_tb/main/ldata
add wave -noupdate -expand -group tb /i2s_deser_tb/main/rdata
add wave -noupdate -height 60 -expand -group DUT /i2s_deser_tb/i2s_deser_inst/clk_100
add wave -noupdate -height 60 -expand -group DUT /i2s_deser_tb/i2s_deser_inst/i_lrclk
add wave -noupdate -height 60 -expand -group DUT /i2s_deser_tb/i2s_deser_inst/i_bclk
add wave -noupdate -height 60 -expand -group DUT -format Literal /i2s_deser_tb/i2s_deser_inst/i_serial_data
add wave -noupdate -height 60 -expand -group DUT /i2s_deser_tb/i2s_deser_inst/i_en
add wave -noupdate -height 60 -expand -group DUT /i2s_deser_tb/i2s_deser_inst/o_data
add wave -noupdate -height 60 -expand -group DUT /i2s_deser_tb/i2s_deser_inst/o_valid
add wave -noupdate -height 60 -expand -group DUT /i2s_deser_tb/i2s_deser_inst/s_deser_state
add wave -noupdate -height 60 -expand -group DUT /i2s_deser_tb/i2s_deser_inst/r_lrclk
add wave -noupdate -height 60 -expand -group DUT /i2s_deser_tb/i2s_deser_inst/r_bclk
add wave -noupdate -height 60 -expand -group DUT /i2s_deser_tb/i2s_deser_inst/w_left
add wave -noupdate -height 60 -expand -group DUT /i2s_deser_tb/i2s_deser_inst/w_right
add wave -noupdate -height 60 -expand -group DUT /i2s_deser_tb/i2s_deser_inst/w_bclk_re
add wave -noupdate -height 60 -expand -group DUT -radix unsigned -radixshowbase 0 /i2s_deser_tb/i2s_deser_inst/r_bit_cntr
add wave -noupdate -height 60 -expand -group DUT -radix binary /i2s_deser_tb/i2s_deser_inst/r_ldata
add wave -noupdate -height 60 -expand -group DUT -radix binary /i2s_deser_tb/i2s_deser_inst/r_rdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {36020000 ps} 1} {Trace {36020000 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 150
configure wave -valuecolwidth 166
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
WaveRestoreZoom {0 ps} {97797120 ps}
