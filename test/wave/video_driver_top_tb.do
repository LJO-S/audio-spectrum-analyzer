onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group TB /video_driver_top_tb/clk_100
add wave -noupdate -group TB /video_driver_top_tb/clk_tmds_250
add wave -noupdate -group TB /video_driver_top_tb/i_100ms_strb
add wave -noupdate -group TB /video_driver_top_tb/i_capture_en
add wave -noupdate -group TB /video_driver_top_tb/i_lpf_en
add wave -noupdate -group TB /video_driver_top_tb/i_hpf_en
add wave -noupdate -group TB /video_driver_top_tb/i_ema_en
add wave -noupdate -group TB /video_driver_top_tb/i_lpf_incr
add wave -noupdate -group TB /video_driver_top_tb/i_lpf_decr
add wave -noupdate -group TB /video_driver_top_tb/i_hpf_incr
add wave -noupdate -group TB /video_driver_top_tb/i_hpf_decr
add wave -noupdate -group TB /video_driver_top_tb/o_rd_addr
add wave -noupdate -group TB /video_driver_top_tb/i_rd_data
add wave -noupdate -group TB /video_driver_top_tb/o_TMDS_clk_p
add wave -noupdate -group TB /video_driver_top_tb/o_TMDS_clk_n
add wave -noupdate -group TB /video_driver_top_tb/o_video_0_p
add wave -noupdate -group TB /video_driver_top_tb/o_video_0_n
add wave -noupdate -group TB /video_driver_top_tb/o_video_1_p
add wave -noupdate -group TB /video_driver_top_tb/o_video_1_n
add wave -noupdate -group TB /video_driver_top_tb/o_video_2_p
add wave -noupdate -group TB /video_driver_top_tb/o_video_2_n
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/clk_100
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/clk_tmds_250
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/i_100ms_strb
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/i_capture_en
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/i_lpf_en
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/i_hpf_en
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/i_ema_en
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/i_lpf_incr
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/i_lpf_decr
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/i_hpf_incr
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/i_hpf_decr
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/o_rd_addr
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/i_rd_data
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/o_TMDS_clk_p
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/o_TMDS_clk_n
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/o_video_0_p
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/o_video_0_n
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/o_video_1_p
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/o_video_1_n
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/o_video_2_p
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/o_video_2_n
add wave -noupdate -group {Video driver top} -radix binary /video_driver_top_tb/video_driver_top_inst/r_ce_counter
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/w_ce
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/r_ce
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/r_pixclk
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/r_comp_limit_value
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/r_subtract_value
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/w_HDMI_HPD
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/w_HSYNC
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/w_VSYNC
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/w_draw
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/w_video_red
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/w_video_grn
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/w_video_blu
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/w_video_0_p
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/w_video_0_n
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/w_video_1_p
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/w_video_1_n
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/w_video_2_p
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/w_video_2_n
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/w_TMDS_out_clk
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/w_TMDS_out_clk_p
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/w_TMDS_out_clk_n
add wave -noupdate -group {Video driver top} /video_driver_top_tb/video_driver_top_inst/w_TMDS
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/i_clk_25
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/i_clk_100
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/i_clk_250
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/i_25m_ce
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/i_HSYNC
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/i_VSYNC
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/i_draw
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/i_video_red
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/i_video_grn
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/i_video_blu
add wave -noupdate -expand -group TMDS_top -radix binary -childformat {{/video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/o_TMDS(2) -radix binary} {/video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/o_TMDS(1) -radix binary} {/video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/o_TMDS(0) -radix binary}} -subitemconfig {/video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/o_TMDS(2) {-radix binary} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/o_TMDS(1) {-radix binary} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/o_TMDS(0) {-radix binary}} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/o_TMDS
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/o_TMDS_clk
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/o_HDMI_HPD
add wave -noupdate -expand -group TMDS_top -divider Encode
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/i_25m_ce
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_TMDS_red
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_TMDS_grn
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_TMDS_blu
add wave -noupdate -expand -group TMDS_top -divider FIFO
add wave -noupdate -expand -group TMDS_top -color Gold /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/i_clk_100
add wave -noupdate -expand -group TMDS_top -color Gold /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/r_fifo_wr_en
add wave -noupdate -expand -group TMDS_top -color Gold -subitemconfig {/video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(29) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(28) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(27) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(26) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(25) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(24) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(23) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(22) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(21) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(20) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(19) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(18) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(17) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(16) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(15) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(14) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(13) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(12) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(11) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(10) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(9) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(8) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(7) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(6) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(5) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(4) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(3) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(2) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(1) {-color Gold} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data(0) {-color Gold}} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_wr_data
add wave -noupdate -expand -group TMDS_top -color Gold /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_full
add wave -noupdate -expand -group TMDS_top -color {Cornflower Blue} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/i_clk_250
add wave -noupdate -expand -group TMDS_top -color {Cornflower Blue} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/r_fifo_rd_en
add wave -noupdate -expand -group TMDS_top -color {Cornflower Blue} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_rd_data
add wave -noupdate -expand -group TMDS_top -color {Cornflower Blue} /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/w_fifo_empty
add wave -noupdate -expand -group TMDS_top -divider Out
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/r_sync_TMDS_red
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/r_sync_TMDS_grn
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/r_sync_TMDS_blu
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/r_TMDS_mod10
add wave -noupdate -expand -group TMDS_top -radix binary /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/r_TMDS_shift_red
add wave -noupdate -expand -group TMDS_top -radix binary /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/r_TMDS_shift_grn
add wave -noupdate -expand -group TMDS_top -radix binary /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/r_TMDS_shift_blu
add wave -noupdate -expand -group TMDS_top /video_driver_top_tb/video_driver_top_inst/TMDS_top_inst/r_TMDS_shift_load
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/clk_100
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/i_ce
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/i_compare_limit
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/i_compare_subtractor
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/i_fft_data
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/o_rd_addr
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/i_100ms_strb
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/i_capture_on
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/i_lpf_on
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/i_lpf_incr
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/i_lpf_decr
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/i_bpf_on
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/i_bpf_cutoff
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/i_hpf_on
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/i_hpf_incr
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/i_hpf_decr
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/i_ema_on
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/o_HSYNC
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/o_VSYNC
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/o_draw
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/o_video_red
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/o_video_grn
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/o_video_blu
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_counter_X
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_counter_Y
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_HSYNC
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_VSYNC
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_draw
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_counter_X_d1
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_counter_Y_d1
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_HSYNC_d1
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_VSYNC_d1
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_draw_d1
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_fft_data
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_compare_value
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_draw_spectrum
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_video_red_spectrum
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_video_grn_spectrum
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_video_blu_spectrum
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_curr_freq
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_max_freq
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_max_value
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_lpf_cutoff
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_hpf_cutoff
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/w_freq_lpf_1000s
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/w_freq_hpf_1000s
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_lpf_x_axis
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_hpf_x_axis
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/w_ascii_draw
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/w_video_red_ascii
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/w_video_grn_ascii
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/w_video_blu_ascii
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_gui_draw
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_video_red_gui
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_video_grn_gui
add wave -noupdate -group {Image Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/r_video_blu_gui
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/clk_100
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_ce
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_counter_X
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_counter_Y
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_max_freq
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_capture_on
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_lpf_on
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_lpf_cutoff
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_bpf_on
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_bpf_cutoff
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_hpf_on
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_hpf_cutoff
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_ema_on
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/o_freq_lpf_1000s
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/o_freq_hpf_1000s
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/o_glyph_active
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/o_video_red
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/o_video_grn
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/o_video_blu
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/w_col_count_div_1_2
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/w_row_count_div_1_2
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/w_col_addr
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_col_addr
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/w_col_addr_1_8
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/w_col_addr_1_8_half
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/w_col_addr_1_8_eighth
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/w_row_addr
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_draw
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_draw_lpf
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_draw_bpf
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_draw_hpf
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_draw_ema
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_draw_capture
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_draw_internal
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_tilemap_freq_max
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_freq_max_1000s
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_tilemap_freq_lpf
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_freq_lpf_1000s
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_tilemap_freq_bpf
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_freq_bpf_1000s
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_tilemap_freq_hpf
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_freq_hpf_1000s
add wave -noupdate -group {Ascii Generator} /video_driver_top_tb/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_font_line
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 4} {49857 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 162
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {155304 ps}
