onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group TOP /project_top_tb/project_top_inst/i_clk_100
add wave -noupdate -group TOP /project_top_tb/project_top_inst/i_clk_250
add wave -noupdate -group TOP /project_top_tb/project_top_inst/i_i2c_cfg_done
add wave -noupdate -group TOP /project_top_tb/project_top_inst/i_new_data_strobe_lpf
add wave -noupdate -group TOP /project_top_tb/project_top_inst/i_new_data_strobe_hpf
add wave -noupdate -group TOP /project_top_tb/project_top_inst/i_ps_fir_ctrl_ack
add wave -noupdate -group TOP /project_top_tb/project_top_inst/o_fir_ctrl
add wave -noupdate -group TOP /project_top_tb/project_top_inst/o_raddr_hpf
add wave -noupdate -group TOP /project_top_tb/project_top_inst/i_rdata_hpf
add wave -noupdate -group TOP /project_top_tb/project_top_inst/o_raddr_lpf
add wave -noupdate -group TOP /project_top_tb/project_top_inst/i_rdata_lpf
add wave -noupdate -group TOP /project_top_tb/project_top_inst/i_pb_vector
add wave -noupdate -group TOP /project_top_tb/project_top_inst/i_dip_vector
add wave -noupdate -group TOP /project_top_tb/project_top_inst/i_sdata
add wave -noupdate -group TOP /project_top_tb/project_top_inst/o_mclk
add wave -noupdate -group TOP /project_top_tb/project_top_inst/o_rec_lrclk
add wave -noupdate -group TOP /project_top_tb/project_top_inst/o_bclk
add wave -noupdate -group TOP /project_top_tb/project_top_inst/o_pb_lrclk
add wave -noupdate -group TOP /project_top_tb/project_top_inst/o_pbdat
add wave -noupdate -group TOP /project_top_tb/project_top_inst/o_dac_muten
add wave -noupdate -group TOP /project_top_tb/project_top_inst/o_TMDS_clk_p
add wave -noupdate -group TOP /project_top_tb/project_top_inst/o_TMDS_clk_n
add wave -noupdate -group TOP /project_top_tb/project_top_inst/o_video_0_p
add wave -noupdate -group TOP /project_top_tb/project_top_inst/o_video_0_n
add wave -noupdate -group TOP /project_top_tb/project_top_inst/o_video_1_p
add wave -noupdate -group TOP /project_top_tb/project_top_inst/o_video_1_n
add wave -noupdate -group TOP /project_top_tb/project_top_inst/o_video_2_p
add wave -noupdate -group TOP /project_top_tb/project_top_inst/o_video_2_n
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_m_axis_data_tlast
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_FFT_mag
add wave -noupdate -group TOP -radix unsigned /project_top_tb/project_top_inst/w_xk_index
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_axis_tready_xfft_out
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_axis_tdata_xfft_in
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_axis_tvalid_xfft_in
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_axis_tlast_xfft_in
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_fft_tvalid_out
add wave -noupdate -group TOP -radix decimal /project_top_tb/project_top_inst/w_fft_tdata_out_re
add wave -noupdate -group TOP -radix decimal /project_top_tb/project_top_inst/w_fft_tdata_out_im
add wave -noupdate -group TOP -divider {magnitude calc start}
add wave -noupdate -group TOP /project_top_tb/project_top_inst/r_fft_tvalid_out
add wave -noupdate -group TOP /project_top_tb/project_top_inst/r_fft_tlast_out
add wave -noupdate -group TOP /project_top_tb/project_top_inst/r_fft_tlast_out_d1
add wave -noupdate -group TOP /project_top_tb/project_top_inst/r_fft_tvalid_out_d1
add wave -noupdate -group TOP -radix unsigned /project_top_tb/project_top_inst/r_fft_tdata_pow2_re
add wave -noupdate -group TOP -radix unsigned /project_top_tb/project_top_inst/r_fft_tdata_pow2_im
add wave -noupdate -group TOP -radix decimal -childformat {{/project_top_tb/project_top_inst/r_fft_magnitude(32) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(31) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(30) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(29) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(28) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(27) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(26) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(25) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(24) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(23) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(22) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(21) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(20) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(19) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(18) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(17) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(16) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(15) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(14) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(13) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(12) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(11) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(10) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(9) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(8) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(7) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(6) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(5) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(4) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(3) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(2) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(1) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(0) -radix decimal}} -subitemconfig {/project_top_tb/project_top_inst/r_fft_magnitude(32) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(31) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(30) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(29) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(28) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(27) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(26) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(25) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(24) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(23) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(22) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(21) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(20) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(19) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(18) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(17) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(16) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(15) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(14) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(13) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(12) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(11) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(10) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(9) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(8) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(7) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(6) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(5) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(4) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(3) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(2) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(1) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(0) {-height 15 -radix decimal}} /project_top_tb/project_top_inst/r_fft_magnitude
add wave -noupdate -group TOP -divider {magnitude calc end}
add wave -noupdate -group TOP -format Analog-Step -height 74 -max 183450000.0 -radix decimal -childformat {{/project_top_tb/project_top_inst/r_fft_magnitude(32) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(31) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(30) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(29) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(28) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(27) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(26) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(25) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(24) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(23) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(22) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(21) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(20) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(19) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(18) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(17) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(16) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(15) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(14) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(13) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(12) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(11) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(10) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(9) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(8) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(7) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(6) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(5) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(4) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(3) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(2) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(1) -radix decimal} {/project_top_tb/project_top_inst/r_fft_magnitude(0) -radix decimal}} -subitemconfig {/project_top_tb/project_top_inst/r_fft_magnitude(32) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(31) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(30) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(29) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(28) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(27) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(26) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(25) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(24) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(23) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(22) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(21) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(20) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(19) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(18) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(17) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(16) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(15) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(14) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(13) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(12) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(11) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(10) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(9) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(8) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(7) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(6) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(5) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(4) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(3) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(2) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(1) {-height 15 -radix decimal} /project_top_tb/project_top_inst/r_fft_magnitude(0) {-height 15 -radix decimal}} /project_top_tb/project_top_inst/r_fft_magnitude
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_100ms_strb
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_axis_tready_xfft_to_sig_gen
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_axis_tdata_sig_gen_to_xfft
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_axis_tvalid_sig_gen_to_xfft
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_axis_tlast_sig_gen_to_xfft
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_axis_tready_xfft_to_audio
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_axis_tdata_audio_to_xfft
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_axis_tvalid_audio_to_xfft
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_axis_tlast_audio_to_xfft
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_waddr_lpf
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_wdata_lpf
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_we_lpf
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_waddr_hpf
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_wdata_hpf
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_we_hpf
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_rd_addr
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_rd_data
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_sig_gen_src_sel
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_lpf_en
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_lpf_incr
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_lpf_incr_to_video
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_lpf_decr
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_lpf_decr_to_video
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_hpf_en
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_hpf_incr
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_hpf_incr_to_video
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_hpf_decr
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_hpf_decr_to_video
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_ema_en
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_sel_up_lo
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_capture_en
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_capture_en_drain_guard
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_updating_coeffs_lpf
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_updating_coeffs_hpf
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_new_data_strobe_lpf
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_new_data_strobe_hpf
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_raddr_hpf
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_rdata_hpf
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_raddr_lpf
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_rdata_lpf
add wave -noupdate -group TOP /project_top_tb/project_top_inst/s_state_drain_guard
add wave -noupdate -group TOP /project_top_tb/project_top_inst/w_lrclk
add wave -noupdate -group {Ping Pong Memory} /project_top_tb/project_top_inst/ping_pong_memory_inst/clk_25
add wave -noupdate -group {Ping Pong Memory} -format Analog-Step -height 74 -max 91725000.0 -radix decimal /project_top_tb/project_top_inst/ping_pong_memory_inst/i_fft_data_magn
add wave -noupdate -group {Ping Pong Memory} /project_top_tb/project_top_inst/ping_pong_memory_inst/i_fft_data_valid
add wave -noupdate -group {Ping Pong Memory} /project_top_tb/project_top_inst/ping_pong_memory_inst/i_fft_data_last
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/i_xk_index
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/i_rd_addr
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data
add wave -noupdate -group {Ping Pong Memory} -format Analog-Step -height 74 -max 91725000.0 -radix unsigned -childformat {{/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(31) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(30) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(29) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(28) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(27) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(26) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(25) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(24) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(23) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(22) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(21) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(20) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(19) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(18) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(17) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(16) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(15) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(14) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(13) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(12) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(11) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(10) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(9) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(8) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(7) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(6) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(5) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(4) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(3) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(2) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(1) -radix decimal} {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(0) -radix decimal}} -subitemconfig {/project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(31) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(30) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(29) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(28) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(27) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(26) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(25) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(24) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(23) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(22) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(21) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(20) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(19) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(18) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(17) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(16) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(15) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(14) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(13) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(12) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(11) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(10) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(9) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(8) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(7) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(6) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(5) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(4) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(3) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(2) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(1) {-height 15 -radix decimal} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data(0) {-height 15 -radix decimal}} /project_top_tb/project_top_inst/ping_pong_memory_inst/o_rd_data
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/r_rd_addr
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/r_addr_bram0
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/r_addr_bram1
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/r_rd_data_bram0
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/r_rd_data_bram1
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/r_wr_data_bram0
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/r_wr_data_bram1
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/r_wr_en_bram0
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/r_wr_en_bram1
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/r_xk_index
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/r_xk_index_d1
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/r_fft_data_valid
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/r_fft_data_valid_d1
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/r_fft_data_last
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/r_fft_data_last_d1
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/r_fft_data_magn
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/r_pingpong
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/r_pingpong_d1
add wave -noupdate -group {Ping Pong Memory} -radix unsigned /project_top_tb/project_top_inst/ping_pong_memory_inst/r_pingpong_d2
add wave -noupdate -divider Video
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/clk_25
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/clk_tmds_250
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/i_100ms_strb
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/i_capture_en
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/i_lpf_en
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/i_hpf_en
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/i_ema_en
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/i_lpf_incr
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/i_lpf_decr
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/i_hpf_incr
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/i_hpf_decr
add wave -noupdate -group {Video Driver} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/o_rd_addr
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/i_rd_data
add wave -noupdate -group {Video Driver} -format Analog-Step -height 74 -max 91725000.0 -radix decimal /project_top_tb/project_top_inst/video_driver_top_inst/i_rd_data
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/o_TMDS_clk_p
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/o_TMDS_clk_n
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/o_video_0_p
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/o_video_0_n
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/o_video_1_p
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/o_video_1_n
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/o_video_2_p
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/o_video_2_n
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/w_comp_limit_value
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/w_subtract_value
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/w_HDMI_HPD
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/w_HSYNC
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/w_VSYNC
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/w_draw
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/w_video_red
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/w_video_grn
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/w_video_blu
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/w_video_0_p
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/w_video_0_n
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/w_video_1_p
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/w_video_1_n
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/w_video_2_p
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/w_video_2_n
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/w_TMDS_out_clk
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/w_TMDS_out_clk_p
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/w_TMDS_out_clk_n
add wave -noupdate -group {Video Driver} /project_top_tb/project_top_inst/video_driver_top_inst/w_TMDS
add wave -noupdate -expand -group {Image Generator} -radix decimal /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/clk_25
add wave -noupdate -expand -group {Image Generator} -radix decimal /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/i_compare_limit
add wave -noupdate -expand -group {Image Generator} -radix decimal /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/i_compare_subtractor
add wave -noupdate -expand -group {Image Generator} -format Analog-Step -height 74 -max 91725000.0 -radix decimal /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/i_fft_data
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/o_rd_addr
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/i_100ms_strb
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/i_capture_on
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/i_lpf_on
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/i_lpf_incr
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/i_lpf_decr
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/i_bpf_on
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/i_bpf_cutoff
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/i_hpf_on
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/i_hpf_incr
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/i_hpf_decr
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/i_ema_on
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/o_HSYNC
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/o_VSYNC
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/o_draw
add wave -noupdate -expand -group {Image Generator} -radix hexadecimal /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/o_video_red
add wave -noupdate -expand -group {Image Generator} -radix hexadecimal /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/o_video_grn
add wave -noupdate -expand -group {Image Generator} -radix hexadecimal /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/o_video_blu
add wave -noupdate -expand -group {Image Generator} -divider non-pipe
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_counter_X
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_counter_Y
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_HSYNC
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_VSYNC
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_draw
add wave -noupdate -expand -group {Image Generator} -expand -group piping -divider {PIPE 1}
add wave -noupdate -expand -group {Image Generator} -expand -group piping -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_counter_X_d1
add wave -noupdate -expand -group {Image Generator} -expand -group piping -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_counter_Y_d1
add wave -noupdate -expand -group {Image Generator} -expand -group piping -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_HSYNC_d1
add wave -noupdate -expand -group {Image Generator} -expand -group piping -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_VSYNC_d1
add wave -noupdate -expand -group {Image Generator} -expand -group piping -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_draw_d1
add wave -noupdate -expand -group {Image Generator} -expand -group piping -divider {PIPE 2}
add wave -noupdate -expand -group {Image Generator} -expand -group piping -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_counter_X_d2
add wave -noupdate -expand -group {Image Generator} -expand -group piping -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_counter_Y_d2
add wave -noupdate -expand -group {Image Generator} -expand -group piping -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_HSYNC_d2
add wave -noupdate -expand -group {Image Generator} -expand -group piping -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_VSYNC_d2
add wave -noupdate -expand -group {Image Generator} -expand -group piping -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_draw_d2
add wave -noupdate -expand -group {Image Generator} -expand -group piping -divider {PIPE 3}
add wave -noupdate -expand -group {Image Generator} -expand -group piping -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_counter_X_d3
add wave -noupdate -expand -group {Image Generator} -expand -group piping -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_counter_Y_d3
add wave -noupdate -expand -group {Image Generator} -expand -group piping -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_HSYNC_d3
add wave -noupdate -expand -group {Image Generator} -expand -group piping -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_VSYNC_d3
add wave -noupdate -expand -group {Image Generator} -expand -group piping -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_draw_d3
add wave -noupdate -expand -group {Image Generator} -expand -group piping -divider {PIPE 4}
add wave -noupdate -expand -group {Image Generator} -expand -group piping -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_counter_X_d4
add wave -noupdate -expand -group {Image Generator} -expand -group piping -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_counter_Y_d4
add wave -noupdate -expand -group {Image Generator} -expand -group piping -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_HSYNC_d4
add wave -noupdate -expand -group {Image Generator} -expand -group piping -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_VSYNC_d4
add wave -noupdate -expand -group {Image Generator} -expand -group piping -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_draw_d4
add wave -noupdate -expand -group {Image Generator} -divider misc
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_debug_color_on
add wave -noupdate -expand -group {Image Generator} -radix unsigned -childformat {{/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(31) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(30) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(29) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(28) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(27) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(26) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(25) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(24) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(23) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(22) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(21) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(20) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(19) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(18) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(17) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(16) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(15) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(14) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(13) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(12) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(11) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(10) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(9) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(8) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(7) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(6) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(5) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(4) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(3) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(2) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(1) -radix decimal} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(0) -radix decimal}} -subitemconfig {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(31) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(30) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(29) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(28) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(27) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(26) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(25) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(24) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(23) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(22) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(21) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(20) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(19) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(18) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(17) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(16) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(15) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(14) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(13) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(12) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(11) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(10) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(9) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(8) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(7) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(6) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(5) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(4) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(3) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(2) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(1) {-height 15 -radix decimal} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value(0) {-height 15 -radix decimal}} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_compare_value
add wave -noupdate -expand -group {Image Generator} -color {Cornflower Blue} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_draw_spectrum
add wave -noupdate -expand -group {Image Generator} -color {Cornflower Blue} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_video_red_spectrum
add wave -noupdate -expand -group {Image Generator} -color {Cornflower Blue} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_video_grn_spectrum
add wave -noupdate -expand -group {Image Generator} -color {Cornflower Blue} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_video_blu_spectrum
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_curr_freq
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_freq
add wave -noupdate -expand -group {Image Generator} -radix unsigned -childformat {{/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(31) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(30) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(29) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(28) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(27) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(26) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(25) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(24) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(23) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(22) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(21) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(20) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(19) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(18) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(17) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(16) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(15) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(14) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(13) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(12) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(11) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(10) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(9) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(8) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(7) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(6) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(5) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(4) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(3) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(2) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(1) -radix unsigned} {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(0) -radix unsigned}} -subitemconfig {/project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(31) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(30) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(29) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(28) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(27) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(26) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(25) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(24) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(23) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(22) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(21) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(20) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(19) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(18) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(17) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(16) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(15) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(14) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(13) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(12) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(11) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(10) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(9) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(8) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(7) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(6) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(5) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(4) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(3) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(2) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(1) {-height 15 -radix unsigned} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value(0) {-height 15 -radix unsigned}} /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_max_value
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_lpf_cutoff
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_hpf_cutoff
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/w_freq_lpf_1000s
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/w_freq_hpf_1000s
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_lpf_x_axis
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_hpf_x_axis
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/w_ascii_draw
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/w_video_red_ascii
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/w_video_grn_ascii
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/w_video_blu_ascii
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_gui_draw
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_video_red_gui
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_video_grn_gui
add wave -noupdate -expand -group {Image Generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/r_video_blu_gui
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/clk_25
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_counter_X
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_counter_Y
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_max_freq
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_capture_on
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_lpf_on
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_lpf_cutoff
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_bpf_on
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_bpf_cutoff
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_hpf_on
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_hpf_cutoff
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/i_ema_on
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/o_freq_lpf_1000s
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/o_freq_hpf_1000s
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/o_glyph_active
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/o_video_red
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/o_video_grn
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/o_video_blu
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/w_col_count_div_1_2
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/w_row_count_div_1_2
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/w_col_addr
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_col_addr_d1
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/w_col_addr_1_8
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/w_col_addr_1_8_half
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/w_col_addr_1_8_eighth
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/w_row_addr
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_draw
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_draw_lpf
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_draw_bpf
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_draw_hpf
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_draw_ema
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_draw_capture
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_draw_internal
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_tilemap_freq_max
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_freq_max_1000s
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_tilemap_freq_lpf
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_freq_lpf_1000s
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_tilemap_freq_bpf
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_freq_bpf_1000s
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_tilemap_freq_hpf
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_freq_hpf_1000s
add wave -noupdate -group {ascii generator} -radix unsigned /project_top_tb/project_top_inst/video_driver_top_inst/image_generator_inst/ascii_generator_inst/r_font_line
add wave -noupdate -divider GPIO
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/clk_25
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/i_pb_vector
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/i_dip_vector
add wave -noupdate -group {Gpio Ctrl} -radix binary /project_top_tb/project_top_inst/gpio_ctrl_inst/o_sig_gen_src_sel
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/o_lpf_en
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/o_lpf_incr
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/o_lpf_decr
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/o_hpf_en
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/o_hpf_incr
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/o_hpf_decr
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/o_ema_en
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/o_sel_up_lo
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/o_capture_en
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/w_pb_debounce
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/w_dip_debounce
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/w_sel_up_lo
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/w_ema_en
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/w_lpf_en
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/w_lpf_incr
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/r_lpf_incr
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/w_lpf_incr_re
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/w_lpf_decr
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/r_lpf_decr
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/w_lpf_decr_re
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/w_hpf_en
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/w_hpf_incr
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/r_hpf_incr
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/w_hpf_incr_re
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/w_hpf_decr
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/r_hpf_decr
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/w_hpf_decr_re
add wave -noupdate -group {Gpio Ctrl} /project_top_tb/project_top_inst/gpio_ctrl_inst/w_capture_en
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/clk_25
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/i_lpf_incr
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/i_lpf_decr
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/i_hpf_incr
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/i_hpf_decr
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/o_lpf_incr
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/o_lpf_decr
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/o_hpf_incr
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/o_hpf_decr
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/o_new_data_strobe_lpf
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/o_new_data_strobe_hpf
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/i_updating_coeffs_lpf
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/i_updating_coeffs_hpf
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/i_new_data_strobe_lpf
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/i_new_data_strobe_hpf
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/i_ps_ack
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/o_fir_ctrl
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/s_STATE
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/w_fir_ctrl
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/r_fir_ctrl_request
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/r_fir_ctrl_store
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/r_fir_ctrl_video
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/w_ps_ack_strobe
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/r_ps_ack
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/w_new_data_strobe_lpf
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/r_new_data_strobe_lpf
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/w_new_data_strobe_hpf
add wave -noupdate -group {Gpio PS IF} /project_top_tb/project_top_inst/gpio_ps_interface_inst/r_new_data_strobe_hpf
add wave -noupdate -divider {Signal Generators}
add wave -noupdate -group {Signal Gen Wrapper} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/clk_25
add wave -noupdate -group {Signal Gen Wrapper} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/i_sig_gen_src_sel
add wave -noupdate -group {Signal Gen Wrapper} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/i_sel_up_lo
add wave -noupdate -group {Signal Gen Wrapper} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/o_reset
add wave -noupdate -group {Signal Gen Wrapper} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/o_100ms_strb
add wave -noupdate -group {Signal Gen Wrapper} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/i_s_axis_tready
add wave -noupdate -group {Signal Gen Wrapper} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/o_m_axis_tdata
add wave -noupdate -group {Signal Gen Wrapper} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/o_m_axis_tvalid
add wave -noupdate -group {Signal Gen Wrapper} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/o_m_axis_tlast
add wave -noupdate -group {Sig Gen Top} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/clk_25
add wave -noupdate -group {Sig Gen Top} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/i_pbuttons
add wave -noupdate -group {Sig Gen Top} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/i_sel_up_lo
add wave -noupdate -group {Sig Gen Top} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/o_100ms_strb
add wave -noupdate -group {Sig Gen Top} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/o_reset
add wave -noupdate -group {Sig Gen Top} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/i_s_axis_tready
add wave -noupdate -group {Sig Gen Top} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/o_m_axis_tdata
add wave -noupdate -group {Sig Gen Top} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/o_m_axis_tvalid
add wave -noupdate -group {Sig Gen Top} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/o_m_axis_tlast
add wave -noupdate -group {Sig Gen Top} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/r_STATE_GPIO
add wave -noupdate -group {Sig Gen Top} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/r_pbuttons
add wave -noupdate -group {Sig Gen Top} -radix unsigned /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/r_100ms_counter
add wave -noupdate -group {Sig Gen Top} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/r_sig_gen_reset
add wave -noupdate -group {Sig Gen Top} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/r_start_strobe
add wave -noupdate -group {Sig Gen Top} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/r_start_strobe_d1
add wave -noupdate -group {Sig Gen Top} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/r_tlast_pending
add wave -noupdate -group {Sig Gen Top} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/w_sig_gen_tvalid
add wave -noupdate -group {Sig Gen Top} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/w_sig_gen_tlast
add wave -noupdate -group {Sig Gen Top} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/w_sig_gen_tdata
add wave -noupdate -group {Sig Gen Top} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/r_sig_gen_idx
add wave -noupdate -group {Sig Gen Top} /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/r_sig_gen_idx_pending
add wave -noupdate -group {Sig Gen Top} -expand /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/w_tdata_array
add wave -noupdate -group {Sig Gen Top} -radix binary /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/w_start_vector
add wave -noupdate -group {Sig Gen Top} -radix binary /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/w_tvalid_vector
add wave -noupdate -group {Sig Gen Top} -radix binary /project_top_tb/project_top_inst/g_signalgen_build_or_debug/signal_generator_wrapper_inst/signal_generator_top_inst/w_tlast_vector
add wave -noupdate -divider FFT
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/clk
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/reset
add wave -noupdate -group FFT -radix decimal /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/i_tdata_re
add wave -noupdate -group FFT -radix decimal /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/i_tdata_im
add wave -noupdate -group FFT -format Analog-Step -height 74 -max 32767.0 -min -32767.0 -radix decimal /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/i_tdata_re
add wave -noupdate -group FFT -format Analog-Step -height 74 -max 70.0 -radix decimal /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/i_tdata_im
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/i_tvalid
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/o_tready
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/o_tdata_re
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/o_tdata_im
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/o_xk_index
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/o_tvalid
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/r_wr_addr_mem_a_pipe
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/r_wr_addr_mem_b_pipe
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/r_wr_en_mem_pipe
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/s_fft_state
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_agu_start
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_agu_done
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_agu_wr_en
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_agu_rd_addr_a
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_agu_rd_addr_b
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_agu_rd_addr_tw
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/r_agu_wr_en
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/r_rd_addr_mem_a
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/r_rd_addr_mem_b
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/r_rd_addr_twiddle
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/r_rd_addr_twiddle_d1
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/r_rd_addr_twiddle_d2
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/r_mem_select
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_wr_en_1
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_wr_en_2
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_stored_xr
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_stored_xi
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_stored_yr
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_stored_yi
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_calculated_xr
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_calculated_xi
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_calculated_yr
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_calculated_yi
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_br_to_mb_tdata_re
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_br_to_mb_tdata_im
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_br_to_mb_addr_reversed
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_br_to_mb_addr_normal
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_br_tvalid_out
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_twiddle_tr
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_twiddle_ti
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_buffer_tvalid_in
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/r_input_buf_addr
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_buffer_re_im_in
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_buffer_re_im_out
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_buffer_re_out
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_buffer_im_out
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/r_buffer_tvalid_out
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_agu_wr_rising_edge
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_wr_en_mem_ab
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_wr_addr_mem_a
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_wr_addr_mem_b
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/r_hold_counter
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/w_tready_out
add wave -noupdate -group FFT /project_top_tb/project_top_inst/g_fft_build_or_debug/fft_inst/r_tvalid_out_pipeline
add wave -noupdate -divider Audio
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/clk_25
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/i_i2c_cfg_done
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/i_new_data_strobe_lpf
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/o_updating_coeffs_lpf
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/o_raddr_lpf
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/i_rdata_lpf
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/i_new_data_strobe_hpf
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/o_updating_coeffs_hpf
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/o_raddr_hpf
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/i_rdata_hpf
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/i_capture_en
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/i_lpf_en
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/i_hpf_en
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/i_sdata
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/o_mclk
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/o_lrclk
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/o_bclk
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/o_pbdat
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/o_tdata
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/o_tvalid
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/o_tlast
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/i_tready
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/r_clk_counter
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/w_lrclk
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/w_bclk
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/w_i2s_to_filter_data
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/w_i2s_to_filter_valid
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/w_filter_to_buffer_data
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/w_filter_to_buffer_valid
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/w_buffer_to_top_data
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/w_audio_buffer_draining
add wave -noupdate -group {Audio Top} /project_top_tb/project_top_inst/audio_top_inst/w_capture_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3735140000 ps} 0} {Trace {937845575 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 198
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
WaveRestoreZoom {0 ps} {4200420 ns}
