onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group tb -radix unsigned /i2s_ser_tb/tb_counter
add wave -noupdate -expand -group tb /i2s_ser_tb/tb_pbclk
add wave -noupdate -expand -group tb /i2s_ser_tb/tb_pbclk_fe
add wave -noupdate -expand -group tb -radix binary /i2s_ser_tb/tb_tdata
add wave -noupdate -expand -group i2s_ser /i2s_ser_tb/i2s_ser_inst/clk_25
add wave -noupdate -expand -group i2s_ser /i2s_ser_tb/i2s_ser_inst/i_pbclk
add wave -noupdate -expand -group i2s_ser -color {Cornflower Blue} /i2s_ser_tb/i2s_ser_inst/i_bclk
add wave -noupdate -expand -group i2s_ser /i2s_ser_tb/i2s_ser_inst/i_tdata
add wave -noupdate -expand -group i2s_ser /i2s_ser_tb/i2s_ser_inst/i_tvalid
add wave -noupdate -expand -group i2s_ser /i2s_ser_tb/i2s_ser_inst/i_en
add wave -noupdate -expand -group i2s_ser /i2s_ser_tb/i2s_ser_inst/o_pbdat
add wave -noupdate -expand -group i2s_ser /i2s_ser_tb/i2s_ser_inst/s_ser_state
add wave -noupdate -expand -group i2s_ser /i2s_ser_tb/i2s_ser_inst/r_pbclk
add wave -noupdate -expand -group i2s_ser /i2s_ser_tb/i2s_ser_inst/r_bclk
add wave -noupdate -expand -group i2s_ser /i2s_ser_tb/i2s_ser_inst/w_left
add wave -noupdate -expand -group i2s_ser /i2s_ser_tb/i2s_ser_inst/w_right
add wave -noupdate -expand -group i2s_ser -color Magenta /i2s_ser_tb/i2s_ser_inst/w_bclk_re
add wave -noupdate -expand -group i2s_ser -color Cyan /i2s_ser_tb/i2s_ser_inst/w_bclk_fe
add wave -noupdate -expand -group i2s_ser /i2s_ser_tb/i2s_ser_inst/r_bit_cntr
add wave -noupdate -expand -group i2s_ser /i2s_ser_tb/i2s_ser_inst/r_data_pending
add wave -noupdate -expand -group i2s_ser /i2s_ser_tb/i2s_ser_inst/r_data
add wave -noupdate -expand -group i2s_ser /i2s_ser_tb/i2s_ser_inst/r_sdata
add wave -noupdate -expand -group i2s_deser /i2s_ser_tb/i2s_deser_inst/clk_25
add wave -noupdate -expand -group i2s_deser /i2s_ser_tb/i2s_deser_inst/i_lrclk
add wave -noupdate -expand -group i2s_deser /i2s_ser_tb/i2s_deser_inst/i_bclk
add wave -noupdate -expand -group i2s_deser /i2s_ser_tb/i2s_deser_inst/i_serial_data
add wave -noupdate -expand -group i2s_deser /i2s_ser_tb/i2s_deser_inst/i_en
add wave -noupdate -expand -group i2s_deser /i2s_ser_tb/i2s_deser_inst/o_data
add wave -noupdate -expand -group i2s_deser /i2s_ser_tb/i2s_deser_inst/o_valid
add wave -noupdate -expand -group i2s_deser /i2s_ser_tb/i2s_deser_inst/s_deser_state
add wave -noupdate -expand -group i2s_deser /i2s_ser_tb/i2s_deser_inst/r_lrclk
add wave -noupdate -expand -group i2s_deser /i2s_ser_tb/i2s_deser_inst/r_bclk
add wave -noupdate -expand -group i2s_deser /i2s_ser_tb/i2s_deser_inst/w_left
add wave -noupdate -expand -group i2s_deser /i2s_ser_tb/i2s_deser_inst/w_right
add wave -noupdate -expand -group i2s_deser /i2s_ser_tb/i2s_deser_inst/w_bclk_re
add wave -noupdate -expand -group i2s_deser /i2s_ser_tb/i2s_deser_inst/r_bit_cntr
add wave -noupdate -expand -group i2s_deser /i2s_ser_tb/i2s_deser_inst/r_ldata
add wave -noupdate -expand -group i2s_deser /i2s_ser_tb/i2s_deser_inst/r_rdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {44880565 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 145
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
configure wave -timelineunits ps
update
WaveRestoreZoom {46724382 ps} {56724734 ps}
