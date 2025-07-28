onerror {resume}
quietly virtual function -install /audio_top_tb -env /audio_top_tb { ( !(bool)((tb_bit_cntr[4:0]  < 5'b10000)) )} dbgTemp1_9
quietly virtual function -install /audio_top_tb -env /audio_top_tb { ((bool)dbgTemp1_9  ? 1'bx : tb_serial_value)} dbgTemp2_i_sdata_4
quietly virtual function -install /audio_top_tb -env /audio_top_tb { ( !(bool)((tb_bit_cntr[4:0]  < 5'b10000)) )} dbgTemp0_9
quietly virtual function -install /audio_top_tb -env /audio_top_tb { ( ~(tb_serial_value ) )} dbgTemp2_i_sdata_6
quietly virtual function -install /audio_top_tb -env /audio_top_tb { ((bool)dbgTemp0_9  ? 1'bx : dbgTemp2_i_sdata_6)} dbgTemp2_i_sdata_7
quietly virtual function -install /audio_top_tb -env /audio_top_tb { ((tb_iis_state  == LEFT_INITIAL) ? 1'bx : ((tb_iis_state  == LEFT_SEND) ? dbgTemp2_i_sdata_4 : ((tb_iis_state  == RIGHT_INITIAL) ? 1'bx : ((tb_iis_state  == RIGHT_SEND) ? dbgTemp2_i_sdata_7 : 1'bx))))} dbgTemp2_i_sdata_8
quietly virtual function -install /audio_top_tb -env /audio_top_tb { ( ~(bool)(tb_serial_value ) )} dbgTemp3_9
quietly virtual function -install /audio_top_tb -env /audio_top_tb { ((bool)dbgTemp0_9  ? dbgTemp3_9 : tb_serial_value)} dbgTemp2_tb_serial_value_7
quietly virtual function -install /audio_top_tb -env /audio_top_tb { ((tb_iis_state  == LEFT_INITIAL) ? tb_serial_value : ((tb_iis_state  == LEFT_SEND) ? tb_serial_value : ((tb_iis_state  == RIGHT_INITIAL) ? tb_serial_value : ((tb_iis_state  == RIGHT_SEND) ? dbgTemp2_tb_serial_value_7 : tb_serial_value))))} dbgTemp2_tb_serial_value_8
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group DUT /audio_top_tb/audio_top_inst/clk_25
add wave -noupdate -expand -group DUT /audio_top_tb/audio_top_inst/i_i2c_cfg_done
add wave -noupdate -expand -group DUT /audio_top_tb/audio_top_inst/i_capture_en
add wave -noupdate -expand -group DUT /audio_top_tb/audio_top_inst/i_sdata
add wave -noupdate -expand -group DUT /audio_top_tb/audio_top_inst/o_mclk
add wave -noupdate -expand -group DUT /audio_top_tb/audio_top_inst/o_lrclk
add wave -noupdate -expand -group DUT /audio_top_tb/audio_top_inst/o_bclk
add wave -noupdate -expand -group DUT /audio_top_tb/audio_top_inst/o_tdata
add wave -noupdate -expand -group DUT /audio_top_tb/audio_top_inst/o_tvalid
add wave -noupdate -expand -group DUT /audio_top_tb/audio_top_inst/o_tlast
add wave -noupdate -expand -group DUT /audio_top_tb/audio_top_inst/i_tready
add wave -noupdate -expand -group DUT /audio_top_tb/audio_top_inst/r_clk_counter
add wave -noupdate -expand -group DUT /audio_top_tb/audio_top_inst/w_lrclk
add wave -noupdate -expand -group DUT /audio_top_tb/audio_top_inst/w_bclk
add wave -noupdate -expand -group DUT /audio_top_tb/audio_top_inst/w_i2s_to_buffer_data
add wave -noupdate -expand -group DUT /audio_top_tb/audio_top_inst/w_i2s_to_buffer_valid
add wave -noupdate -expand -group DUT /audio_top_tb/audio_top_inst/w_audio_buffer_draining
add wave -noupdate -group i2s_deser /audio_top_tb/audio_top_inst/i2s_deser_inst/clk_25
add wave -noupdate -group i2s_deser /audio_top_tb/audio_top_inst/i2s_deser_inst/i_lrclk
add wave -noupdate -group i2s_deser /audio_top_tb/audio_top_inst/i2s_deser_inst/i_bclk
add wave -noupdate -group i2s_deser /audio_top_tb/audio_top_inst/i2s_deser_inst/i_serial_data
add wave -noupdate -group i2s_deser /audio_top_tb/audio_top_inst/i2s_deser_inst/i_en
add wave -noupdate -group i2s_deser /audio_top_tb/audio_top_inst/i2s_deser_inst/o_data
add wave -noupdate -group i2s_deser /audio_top_tb/audio_top_inst/i2s_deser_inst/o_valid
add wave -noupdate -group i2s_deser /audio_top_tb/audio_top_inst/i2s_deser_inst/s_deser_state
add wave -noupdate -group i2s_deser /audio_top_tb/audio_top_inst/i2s_deser_inst/r_lrclk
add wave -noupdate -group i2s_deser /audio_top_tb/audio_top_inst/i2s_deser_inst/r_bclk
add wave -noupdate -group i2s_deser /audio_top_tb/audio_top_inst/i2s_deser_inst/w_left
add wave -noupdate -group i2s_deser /audio_top_tb/audio_top_inst/i2s_deser_inst/w_right
add wave -noupdate -group i2s_deser /audio_top_tb/audio_top_inst/i2s_deser_inst/w_bclk_re
add wave -noupdate -group i2s_deser /audio_top_tb/audio_top_inst/i2s_deser_inst/r_bit_cntr
add wave -noupdate -group i2s_deser /audio_top_tb/audio_top_inst/i2s_deser_inst/r_ldata
add wave -noupdate -group i2s_deser /audio_top_tb/audio_top_inst/i2s_deser_inst/r_rdata
add wave -noupdate -expand -group audio_buffer /audio_top_tb/audio_top_inst/audio_buffer_inst/clk_25
add wave -noupdate -expand -group audio_buffer /audio_top_tb/audio_top_inst/audio_buffer_inst/i_capture_en
add wave -noupdate -expand -group audio_buffer /audio_top_tb/audio_top_inst/audio_buffer_inst/i_pdata
add wave -noupdate -expand -group audio_buffer /audio_top_tb/audio_top_inst/audio_buffer_inst/i_valid
add wave -noupdate -expand -group audio_buffer -format Analog-Step -height 80 -min -1.0 /audio_top_tb/audio_top_inst/audio_buffer_inst/o_tdata
add wave -noupdate -expand -group audio_buffer /audio_top_tb/audio_top_inst/audio_buffer_inst/o_tvalid
add wave -noupdate -expand -group audio_buffer /audio_top_tb/audio_top_inst/audio_buffer_inst/o_tlast
add wave -noupdate -expand -group audio_buffer /audio_top_tb/audio_top_inst/audio_buffer_inst/i_tready
add wave -noupdate -expand -group audio_buffer /audio_top_tb/audio_top_inst/audio_buffer_inst/s_buffer_state
add wave -noupdate -expand -group audio_buffer -radix unsigned /audio_top_tb/audio_top_inst/audio_buffer_inst/r_addr
add wave -noupdate -expand -group audio_buffer /audio_top_tb/audio_top_inst/audio_buffer_inst/r_tvalid
add wave -noupdate -expand -group audio_buffer /audio_top_tb/audio_top_inst/audio_buffer_inst/r_tlast
add wave -noupdate -expand -group audio_buffer /audio_top_tb/audio_top_inst/audio_buffer_inst/r_we
add wave -noupdate -expand -group audio_buffer /audio_top_tb/audio_top_inst/audio_buffer_inst/r_din
add wave -noupdate -expand -group audio_buffer /audio_top_tb/audio_top_inst/audio_buffer_inst/w_tdata
add wave -noupdate -expand -group tb /audio_top_tb/tb_iis_state
add wave -noupdate -expand -group tb /audio_top_tb/tb_bit_cntr
add wave -noupdate -expand -group tb /audio_top_tb/tb_serial_value
add wave -noupdate -expand -group tb /audio_top_tb/main/tb_i2s_ovalid
add wave -noupdate -expand -group tb /audio_top_tb/tb_fft_stall
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {84121979009 ps} 0} {Trace {27035380000 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 216
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
WaveRestoreZoom {0 ps} {22396850388 ps}
