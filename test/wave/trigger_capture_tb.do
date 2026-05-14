onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group TB /trigger_capture_tb/clk
add wave -noupdate -expand -group TB /trigger_capture_tb/i_audio_tdata
add wave -noupdate -expand -group TB /trigger_capture_tb/i_audio_tvalid
add wave -noupdate -expand -group TB /trigger_capture_tb/i_video_raddr
add wave -noupdate -expand -group TB /trigger_capture_tb/o_video_rdata
add wave -noupdate -expand -group TB /trigger_capture_tb/tb_ms_cnt
add wave -noupdate -expand -group TB /trigger_capture_tb/tb_ms_strobe
add wave -noupdate -expand -group TB /trigger_capture_tb/tb_sin_tdata
add wave -noupdate -expand -group TB /trigger_capture_tb/tb_sin_tvalid
add wave -noupdate -expand -group TB /trigger_capture_tb/tb_sin_freq
add wave -noupdate -expand -group TB /trigger_capture_tb/tb_noise_amp
add wave -noupdate -expand -group TB /trigger_capture_tb/tb_hcount
add wave -noupdate -expand -group TB /trigger_capture_tb/tb_vcount
add wave -noupdate -radix decimal /trigger_capture_tb/G_DATA_WIDTH
add wave -noupdate -radix decimal /trigger_capture_tb/G_DATA_DEPTH
add wave -noupdate -radix decimal /trigger_capture_tb/C_THRESH_HI
add wave -noupdate -radix decimal /trigger_capture_tb/C_THRESH_LO
add wave -noupdate -radix decimal /trigger_capture_tb/C_MS_COUNT
add wave -noupdate -expand -group {Trigger Capture} -radix unsigned /trigger_capture_tb/trigger_capture_inst/clk
add wave -noupdate -expand -group {Trigger Capture} -radix unsigned /trigger_capture_tb/trigger_capture_inst/i_ms_strobe
add wave -noupdate -expand -group {Trigger Capture} -format Analog-Step -height 84 -max 32767.0 -min -32767.0 -radix decimal /trigger_capture_tb/trigger_capture_inst/i_audio_data
add wave -noupdate -expand -group {Trigger Capture} -radix decimal /trigger_capture_tb/trigger_capture_inst/i_audio_data
add wave -noupdate -expand -group {Trigger Capture} -radix unsigned /trigger_capture_tb/trigger_capture_inst/i_audio_valid
add wave -noupdate -expand -group {Trigger Capture} -radix unsigned /trigger_capture_tb/trigger_capture_inst/i_video_raddr
add wave -noupdate -expand -group {Trigger Capture} -format Analog-Step -height 84 -max 32767.0 -min -32767.0 -radix decimal /trigger_capture_tb/trigger_capture_inst/o_video_rdata
add wave -noupdate -expand -group {Trigger Capture} -radix decimal /trigger_capture_tb/trigger_capture_inst/o_video_rdata
add wave -noupdate -expand -group {Trigger Capture} -radix unsigned /trigger_capture_tb/trigger_capture_inst/s_capture_state
add wave -noupdate -expand -group {Trigger Capture} -radix unsigned /trigger_capture_tb/trigger_capture_inst/r_audio_valid
add wave -noupdate -expand -group {Trigger Capture} -radix decimal /trigger_capture_tb/trigger_capture_inst/r_sample_curr
add wave -noupdate -expand -group {Trigger Capture} -radix decimal /trigger_capture_tb/trigger_capture_inst/r_sample_prev
add wave -noupdate -expand -group {Trigger Capture} -radix unsigned /trigger_capture_tb/trigger_capture_inst/r_mem_sel
add wave -noupdate -expand -group {Trigger Capture} -radix unsigned /trigger_capture_tb/trigger_capture_inst/r_trigger_addr
add wave -noupdate -expand -group {Trigger Capture} -radix unsigned /trigger_capture_tb/trigger_capture_inst/r_raddr_start_addr
add wave -noupdate -expand -group {Trigger Capture} -radix unsigned /trigger_capture_tb/trigger_capture_inst/r_circ_buf_waddr
add wave -noupdate -expand -group {Trigger Capture} -radix unsigned /trigger_capture_tb/trigger_capture_inst/r_circ_buf_raddr
add wave -noupdate -expand -group {Trigger Capture} -radix unsigned /trigger_capture_tb/trigger_capture_inst/r_sample_cnt
add wave -noupdate -expand -group {Trigger Capture} -radix unsigned /trigger_capture_tb/trigger_capture_inst/r_ms_cnt
add wave -noupdate -expand -group {Trigger Capture} -radix unsigned /trigger_capture_tb/trigger_capture_inst/w_circ_buf_a_we
add wave -noupdate -expand -group {Trigger Capture} -radix unsigned /trigger_capture_tb/trigger_capture_inst/w_circ_buf_b_we
add wave -noupdate -expand -group {Trigger Capture} -radix decimal /trigger_capture_tb/trigger_capture_inst/r_video_rdata
add wave -noupdate -expand -group {Trigger Capture} -radix decimal /trigger_capture_tb/trigger_capture_inst/w_circ_buf_a_rdata
add wave -noupdate -expand -group {Trigger Capture} -radix decimal /trigger_capture_tb/trigger_capture_inst/w_circ_buf_b_rdata
add wave -noupdate -expand -group {Circ Buf A} -radix unsigned /trigger_capture_tb/trigger_capture_inst/circular_bram_inst_0/clk
add wave -noupdate -expand -group {Circ Buf A} -radix unsigned /trigger_capture_tb/trigger_capture_inst/circular_bram_inst_0/i_we
add wave -noupdate -expand -group {Circ Buf A} -radix decimal /trigger_capture_tb/trigger_capture_inst/circular_bram_inst_0/i_wdata
add wave -noupdate -expand -group {Circ Buf A} -radix unsigned /trigger_capture_tb/trigger_capture_inst/circular_bram_inst_0/i_waddr
add wave -noupdate -expand -group {Circ Buf A} -radix unsigned /trigger_capture_tb/trigger_capture_inst/circular_bram_inst_0/i_re
add wave -noupdate -expand -group {Circ Buf A} -radix unsigned /trigger_capture_tb/trigger_capture_inst/circular_bram_inst_0/i_raddr
add wave -noupdate -expand -group {Circ Buf A} -radix decimal /trigger_capture_tb/trigger_capture_inst/circular_bram_inst_0/o_rdata
add wave -noupdate -expand -group {Circ Buf A} -radix unsigned /trigger_capture_tb/trigger_capture_inst/circular_bram_inst_0/r_memory
add wave -noupdate -expand -group {Circ Buf A} -radix unsigned /trigger_capture_tb/trigger_capture_inst/circular_bram_inst_0/r_output_data_shreg
add wave -noupdate -expand -group {Circ Buf A} -radix decimal /trigger_capture_tb/trigger_capture_inst/circular_bram_inst_0/r_rdata
add wave -noupdate -expand -group {Circ Buf B} -radix unsigned /trigger_capture_tb/trigger_capture_inst/circular_bram_inst_1/clk
add wave -noupdate -expand -group {Circ Buf B} -radix unsigned /trigger_capture_tb/trigger_capture_inst/circular_bram_inst_1/i_we
add wave -noupdate -expand -group {Circ Buf B} -radix decimal /trigger_capture_tb/trigger_capture_inst/circular_bram_inst_1/i_wdata
add wave -noupdate -expand -group {Circ Buf B} -radix unsigned /trigger_capture_tb/trigger_capture_inst/circular_bram_inst_1/i_waddr
add wave -noupdate -expand -group {Circ Buf B} -radix unsigned /trigger_capture_tb/trigger_capture_inst/circular_bram_inst_1/i_re
add wave -noupdate -expand -group {Circ Buf B} -radix unsigned /trigger_capture_tb/trigger_capture_inst/circular_bram_inst_1/i_raddr
add wave -noupdate -expand -group {Circ Buf B} -radix decimal /trigger_capture_tb/trigger_capture_inst/circular_bram_inst_1/o_rdata
add wave -noupdate -expand -group {Circ Buf B} -radix unsigned /trigger_capture_tb/trigger_capture_inst/circular_bram_inst_1/r_memory
add wave -noupdate -expand -group {Circ Buf B} -radix unsigned /trigger_capture_tb/trigger_capture_inst/circular_bram_inst_1/r_output_data_shreg
add wave -noupdate -expand -group {Circ Buf B} -radix decimal /trigger_capture_tb/trigger_capture_inst/circular_bram_inst_1/r_rdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4252500 ps} 0}
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
WaveRestoreZoom {0 ps} {8922375 ps}
