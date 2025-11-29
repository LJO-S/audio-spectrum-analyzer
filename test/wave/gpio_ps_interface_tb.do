onerror {resume}
quietly virtual function -install /gpio_ps_interface_tb/gpio_ps_interface_inst -env /gpio_ps_interface_tb/gpio_ps_interface_inst { ((((1'b0 xor w_fir_ctrl[3] ) xor w_fir_ctrl[2] ) xor w_fir_ctrl[1] ) xor w_fir_ctrl[0] )} dbgTemp0_11
quietly virtual function -install /gpio_ps_interface_tb/gpio_ps_interface_inst -env /gpio_ps_interface_tb/gpio_ps_interface_inst { ((bool)dbgTemp0_11  ? w_fir_ctrl[3:0] : 4'b0000)} dbgTemp1_r_fir_ctrl_latch_2
quietly WaveActivateNextPane {} 0
add wave -noupdate /gpio_ps_interface_tb/gpio_ps_interface_inst/clk_100
add wave -noupdate -expand -group {From GPIO} /gpio_ps_interface_tb/gpio_ps_interface_inst/i_lpf_incr
add wave -noupdate -expand -group {From GPIO} /gpio_ps_interface_tb/gpio_ps_interface_inst/i_lpf_decr
add wave -noupdate -expand -group {From GPIO} /gpio_ps_interface_tb/gpio_ps_interface_inst/i_hpf_incr
add wave -noupdate -expand -group {From GPIO} /gpio_ps_interface_tb/gpio_ps_interface_inst/i_hpf_decr
add wave -noupdate -expand -group {To PS} -expand /gpio_ps_interface_tb/gpio_ps_interface_inst/o_fir_ctrl
add wave -noupdate -expand -group {To Video} /gpio_ps_interface_tb/gpio_ps_interface_inst/o_lpf_incr
add wave -noupdate -expand -group {To Video} /gpio_ps_interface_tb/gpio_ps_interface_inst/o_lpf_decr
add wave -noupdate -expand -group {To Video} /gpio_ps_interface_tb/gpio_ps_interface_inst/o_hpf_incr
add wave -noupdate -expand -group {To Video} /gpio_ps_interface_tb/gpio_ps_interface_inst/o_hpf_decr
add wave -noupdate -expand -group {To Filters} -color Salmon /gpio_ps_interface_tb/gpio_ps_interface_inst/o_new_data_strobe_lpf
add wave -noupdate -expand -group {To Filters} -color Salmon /gpio_ps_interface_tb/gpio_ps_interface_inst/o_new_data_strobe_hpf
add wave -noupdate -expand -group {From Filters} -color {Cornflower Blue} /gpio_ps_interface_tb/gpio_ps_interface_inst/i_updating_coeffs_lpf
add wave -noupdate -expand -group {From Filters} -color {Cornflower Blue} /gpio_ps_interface_tb/gpio_ps_interface_inst/i_updating_coeffs_hpf
add wave -noupdate -expand -group {From PS} -color Yellow /gpio_ps_interface_tb/gpio_ps_interface_inst/i_new_data_strobe_lpf
add wave -noupdate -expand -group {From PS} -color Yellow /gpio_ps_interface_tb/gpio_ps_interface_inst/i_new_data_strobe_hpf
add wave -noupdate -expand -group {From PS} -color Yellow /gpio_ps_interface_tb/gpio_ps_interface_inst/i_ps_ack
add wave -noupdate /gpio_ps_interface_tb/gpio_ps_interface_inst/s_STATE
add wave -noupdate -expand /gpio_ps_interface_tb/gpio_ps_interface_inst/w_fir_ctrl
add wave -noupdate /gpio_ps_interface_tb/gpio_ps_interface_inst/r_fir_ctrl_request
add wave -noupdate /gpio_ps_interface_tb/gpio_ps_interface_inst/r_fir_ctrl_store
add wave -noupdate /gpio_ps_interface_tb/gpio_ps_interface_inst/r_fir_ctrl_video
add wave -noupdate /gpio_ps_interface_tb/gpio_ps_interface_inst/w_ps_ack_strobe
add wave -noupdate /gpio_ps_interface_tb/gpio_ps_interface_inst/r_ps_ack
add wave -noupdate /gpio_ps_interface_tb/gpio_ps_interface_inst/w_new_data_strobe_lpf
add wave -noupdate /gpio_ps_interface_tb/gpio_ps_interface_inst/r_new_data_strobe_lpf
add wave -noupdate /gpio_ps_interface_tb/gpio_ps_interface_inst/w_new_data_strobe_hpf
add wave -noupdate /gpio_ps_interface_tb/gpio_ps_interface_inst/r_new_data_strobe_hpf
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {259402 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 184
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
WaveRestoreZoom {0 ps} {810810 ps}
