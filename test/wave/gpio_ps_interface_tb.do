onerror {resume}
quietly virtual function -install /gpio_ps_interface_tb/gpio_ps_interface_inst -env /gpio_ps_interface_tb/gpio_ps_interface_inst { ((((1'b0 xor w_fir_ctrl[3] ) xor w_fir_ctrl[2] ) xor w_fir_ctrl[1] ) xor w_fir_ctrl[0] )} dbgTemp0_11
quietly virtual function -install /gpio_ps_interface_tb/gpio_ps_interface_inst -env /gpio_ps_interface_tb/gpio_ps_interface_inst { ((bool)dbgTemp0_11  ? w_fir_ctrl[3:0] : 4'b0000)} dbgTemp1_r_fir_ctrl_latch_2
quietly virtual function -install /gpio_ps_interface_tb/gpio_ps_interface_inst -env /gpio_ps_interface_tb/gpio_ps_interface_inst { (i_ps_ack  ? 4'b0000 : r_fir_ctrl_latch[3:0])} dbgTemp1_r_fir_ctrl_latch_3
quietly virtual function -install /gpio_ps_interface_tb/gpio_ps_interface_inst -env /gpio_ps_interface_tb/gpio_ps_interface_inst { (( !(bool)(s_STATE ) ) ? dbgTemp1_r_fir_ctrl_latch_2 : (s_STATE  ? dbgTemp1_r_fir_ctrl_latch_3 : r_fir_ctrl_latch[3:0]))} dbgTemp1_r_fir_ctrl_latch_4
quietly WaveActivateNextPane {} 0
add wave -noupdate /gpio_ps_interface_tb/gpio_ps_interface_inst/clk_25
add wave -noupdate /gpio_ps_interface_tb/gpio_ps_interface_inst/i_lpf_incr
add wave -noupdate /gpio_ps_interface_tb/gpio_ps_interface_inst/i_lpf_decr
add wave -noupdate /gpio_ps_interface_tb/gpio_ps_interface_inst/i_hpf_incr
add wave -noupdate /gpio_ps_interface_tb/gpio_ps_interface_inst/i_hpf_decr
add wave -noupdate /gpio_ps_interface_tb/gpio_ps_interface_inst/i_ps_ack
add wave -noupdate /gpio_ps_interface_tb/gpio_ps_interface_inst/i_updating_coeffs_lpf
add wave -noupdate /gpio_ps_interface_tb/gpio_ps_interface_inst/i_updating_coeffs_hpf
add wave -noupdate -radix binary -childformat {{/gpio_ps_interface_tb/gpio_ps_interface_inst/o_fir_ctrl(3) -radix binary} {/gpio_ps_interface_tb/gpio_ps_interface_inst/o_fir_ctrl(2) -radix binary} {/gpio_ps_interface_tb/gpio_ps_interface_inst/o_fir_ctrl(1) -radix binary} {/gpio_ps_interface_tb/gpio_ps_interface_inst/o_fir_ctrl(0) -radix binary}} -expand -subitemconfig {/gpio_ps_interface_tb/gpio_ps_interface_inst/o_fir_ctrl(3) {-radix binary} /gpio_ps_interface_tb/gpio_ps_interface_inst/o_fir_ctrl(2) {-radix binary} /gpio_ps_interface_tb/gpio_ps_interface_inst/o_fir_ctrl(1) {-radix binary} /gpio_ps_interface_tb/gpio_ps_interface_inst/o_fir_ctrl(0) {-radix binary}} /gpio_ps_interface_tb/gpio_ps_interface_inst/o_fir_ctrl
add wave -noupdate /gpio_ps_interface_tb/gpio_ps_interface_inst/s_STATE
add wave -noupdate -radix binary -childformat {{/gpio_ps_interface_tb/gpio_ps_interface_inst/r_fir_ctrl_latch(3) -radix binary} {/gpio_ps_interface_tb/gpio_ps_interface_inst/r_fir_ctrl_latch(2) -radix binary} {/gpio_ps_interface_tb/gpio_ps_interface_inst/r_fir_ctrl_latch(1) -radix binary} {/gpio_ps_interface_tb/gpio_ps_interface_inst/r_fir_ctrl_latch(0) -radix binary}} -expand -subitemconfig {/gpio_ps_interface_tb/gpio_ps_interface_inst/r_fir_ctrl_latch(3) {-radix binary} /gpio_ps_interface_tb/gpio_ps_interface_inst/r_fir_ctrl_latch(2) {-radix binary} /gpio_ps_interface_tb/gpio_ps_interface_inst/r_fir_ctrl_latch(1) {-radix binary} /gpio_ps_interface_tb/gpio_ps_interface_inst/r_fir_ctrl_latch(0) {-radix binary}} /gpio_ps_interface_tb/gpio_ps_interface_inst/r_fir_ctrl_latch
add wave -noupdate -radix binary -childformat {{/gpio_ps_interface_tb/gpio_ps_interface_inst/w_fir_ctrl(3) -radix binary} {/gpio_ps_interface_tb/gpio_ps_interface_inst/w_fir_ctrl(2) -radix binary} {/gpio_ps_interface_tb/gpio_ps_interface_inst/w_fir_ctrl(1) -radix binary} {/gpio_ps_interface_tb/gpio_ps_interface_inst/w_fir_ctrl(0) -radix binary}} -expand -subitemconfig {/gpio_ps_interface_tb/gpio_ps_interface_inst/w_fir_ctrl(3) {-radix binary} /gpio_ps_interface_tb/gpio_ps_interface_inst/w_fir_ctrl(2) {-radix binary} /gpio_ps_interface_tb/gpio_ps_interface_inst/w_fir_ctrl(1) {-radix binary} /gpio_ps_interface_tb/gpio_ps_interface_inst/w_fir_ctrl(0) {-radix binary}} /gpio_ps_interface_tb/gpio_ps_interface_inst/w_fir_ctrl
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {196280 ps} 0}
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {254625 ps}
