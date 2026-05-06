onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group TB /ramp_generator_tb/clk
add wave -noupdate -group TB /ramp_generator_tb/i_en
add wave -noupdate -group TB /ramp_generator_tb/i_cfg_fc_data
add wave -noupdate -group TB /ramp_generator_tb/i_cfg_bw_data
add wave -noupdate -group TB /ramp_generator_tb/i_cfg_sweep_duration_ms
add wave -noupdate -group TB /ramp_generator_tb/i_cfg_valid
add wave -noupdate -group TB /ramp_generator_tb/o_freq_data
add wave -noupdate -group TB /ramp_generator_tb/o_freq_valid
add wave -noupdate -group TB /ramp_generator_tb/w_ms_strobe
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/clk
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/i_en
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/i_ms_strobe
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/i_cfg_fc_data
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/i_cfg_bw_data
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/i_cfg_sweep_duration_ms
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/i_cfg_valid
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/o_freq_data
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/o_freq_valid
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/s_sweep_rate_state
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_cfg_bw_sign
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_cfg_fc_data
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_cfg_bw_data
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_cfg_duration_ms
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_div_valid_in
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/w_div_ready_out
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/w_div_quotient
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/w_div_remainder
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/w_div_valid_out
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_timeout_cntr
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_cfg_valid
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_delta_sign
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_delta_sign_d1
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_delta_sign_d2
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_freq_carrier
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_freq_delta
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_freq_next
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_freq_current
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_strobe
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_strobe_d1
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_add_freq
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_enable
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_enable_d1
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_enable_d2
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_neg_limit
add wave -noupdate -expand -group {Ramp Gen} -radix decimal /ramp_generator_tb/ramp_generator_inst/r_pos_limit
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {327278078 ps} 0}
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
WaveRestoreZoom {312256561 ps} {358727620 ps}
