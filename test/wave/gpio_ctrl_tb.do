onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/clk_100
add wave -noupdate -radix binary /gpio_ctrl_tb/gpio_ctrl_inst/i_pb_vector
add wave -noupdate -radix binary /gpio_ctrl_tb/gpio_ctrl_inst/i_dip_vector
add wave -noupdate -radix binary /gpio_ctrl_tb/gpio_ctrl_inst/o_sig_gen_src_sel
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/o_lpf_en
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/o_lpf_incr
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/o_lpf_decr
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/o_hpf_en
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/o_hpf_incr
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/o_hpf_decr
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/o_ema_en
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/o_sel_up_lo
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/o_capture_en
add wave -noupdate -radix binary /gpio_ctrl_tb/gpio_ctrl_inst/w_pb_debounce
add wave -noupdate -radix binary /gpio_ctrl_tb/gpio_ctrl_inst/w_dip_debounce
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/w_sel_up_lo
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/w_ema_en
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/w_lpf_en
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/w_lpf_incr
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/r_lpf_incr
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/w_lpf_incr_re
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/w_lpf_decr
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/r_lpf_decr
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/w_lpf_decr_re
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/w_hpf_en
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/w_hpf_incr
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/r_hpf_incr
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/w_hpf_incr_re
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/w_hpf_decr
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/r_hpf_decr
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/w_hpf_decr_re
add wave -noupdate /gpio_ctrl_tb/gpio_ctrl_inst/w_capture_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {270320 ps} 0}
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
WaveRestoreZoom {0 ps} {20916 ns}
