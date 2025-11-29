onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group TB /ascii_generator_tb/clk_100
add wave -noupdate -group TB /ascii_generator_tb/i_counter_X
add wave -noupdate -group TB /ascii_generator_tb/i_counter_Y
add wave -noupdate -group TB /ascii_generator_tb/i_max_freq
add wave -noupdate -group TB /ascii_generator_tb/i_capture_on
add wave -noupdate -group TB /ascii_generator_tb/i_lpf_on
add wave -noupdate -group TB /ascii_generator_tb/i_lpf_cutoff
add wave -noupdate -group TB /ascii_generator_tb/i_bpf_on
add wave -noupdate -group TB /ascii_generator_tb/i_bpf_cutoff
add wave -noupdate -group TB /ascii_generator_tb/i_hpf_on
add wave -noupdate -group TB /ascii_generator_tb/i_hpf_cutoff
add wave -noupdate -group TB /ascii_generator_tb/i_ema_on
add wave -noupdate -group TB /ascii_generator_tb/o_glyph_active
add wave -noupdate -group TB /ascii_generator_tb/o_video_red
add wave -noupdate -group TB /ascii_generator_tb/o_video_grn
add wave -noupdate -group TB /ascii_generator_tb/o_video_blu
add wave -noupdate -group TB /ascii_generator_tb/tb_HSYNC
add wave -noupdate -group TB /ascii_generator_tb/tb_VSYNC
add wave -noupdate -group TB /ascii_generator_tb/tb_screen_active
add wave -noupdate -group TB /ascii_generator_tb/tb_counter
add wave -noupdate -group TB /ascii_generator_tb/tb_ce
add wave -noupdate -group TB /ascii_generator_tb/tb_ce_d1
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/clk_100
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/i_ce
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/i_counter_X
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/i_counter_Y
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/i_max_freq
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/i_capture_on
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/i_lpf_on
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/i_lpf_cutoff
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/i_bpf_on
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/i_bpf_cutoff
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/i_hpf_on
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/i_hpf_cutoff
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/i_ema_on
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/o_freq_lpf_1000s
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/o_freq_hpf_1000s
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/o_glyph_active
add wave -noupdate -expand -group {ascii generator} -radix hexadecimal /ascii_generator_tb/ascii_generator_inst/o_video_red
add wave -noupdate -expand -group {ascii generator} -radix hexadecimal /ascii_generator_tb/ascii_generator_inst/o_video_grn
add wave -noupdate -expand -group {ascii generator} -radix hexadecimal /ascii_generator_tb/ascii_generator_inst/o_video_blu
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/w_col_count_div_1_2
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/w_row_count_div_1_2
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/w_col_addr
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/r_col_addr
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/w_col_addr_1_8
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/w_col_addr_1_8_half
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/w_col_addr_1_8_eighth
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/w_row_addr
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/r_draw
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/r_draw_lpf
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/r_draw_bpf
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/r_draw_hpf
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/r_draw_ema
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/r_draw_capture
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/r_draw_internal
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/r_tilemap_freq_max
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/r_freq_max_1000s
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/r_tilemap_freq_lpf
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/r_freq_lpf_1000s
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/r_tilemap_freq_bpf
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/r_freq_bpf_1000s
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/r_tilemap_freq_hpf
add wave -noupdate -expand -group {ascii generator} -radix unsigned /ascii_generator_tb/ascii_generator_inst/r_freq_hpf_1000s
add wave -noupdate -expand -group {ascii generator} -radix binary /ascii_generator_tb/ascii_generator_inst/r_font_line
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {767931169 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 181
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
WaveRestoreZoom {767825651 ps} {768210671 ps}
