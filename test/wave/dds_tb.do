onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group TB -radix decimal /dds_tb/clk
add wave -noupdate -expand -group TB -radix decimal /dds_tb/i_cfg_freq
add wave -noupdate -expand -group TB -radix decimal /dds_tb/i_cfg_valid
add wave -noupdate -expand -group TB -radix decimal /dds_tb/o_data_i
add wave -noupdate -expand -group TB -radix decimal /dds_tb/o_data_q
add wave -noupdate -expand -group TB -radix decimal /dds_tb/o_valid
add wave -noupdate -expand -group TB -radix decimal /dds_tb/auto_freq_input
add wave -noupdate -expand -group TB -radix decimal /dds_tb/auto_freq_valid
add wave -noupdate -expand -group TB -radix decimal /dds_tb/tb_output_data_i_float
add wave -noupdate -expand -group TB -radix decimal /dds_tb/tb_output_data_q_float
add wave -noupdate -expand -group TB -radix decimal /dds_tb/tb_auto_set
add wave -noupdate -expand -group TB -radix decimal /dds_tb/tb_auto_set_done
add wave -noupdate -expand -group TB -radix decimal /dds_tb/tb_auto_test_done
add wave -noupdate -expand -group TB -radix decimal /dds_tb/tb_nbr_of_samples
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/clk
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/i_cfg_freq
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/i_cfg_valid
add wave -noupdate -expand -group DDS -expand -group Analog -format Analog-Step -height 84 -max 32766.0 -min -32766.0 -radix decimal /dds_tb/dds_inst/o_data_i
add wave -noupdate -expand -group DDS -expand -group Analog -format Analog-Step -height 84 -max 32765.000000000004 -min -32765.0 -radix decimal /dds_tb/dds_inst/o_data_q
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/o_data_i
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/o_data_q
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/o_valid
add wave -noupdate -expand -group DDS -divider {Calc Tuning Word}
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/r_cfg_freq
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/r_cfg_valid
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/r_cfg_valid_d1
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/r_tuning_word_product
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/r_tuning_word_shifted
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/r_cfg_valid_d2
add wave -noupdate -expand -group DDS -divider {Phase Acc}
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/r_phase_accumulator
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/r_phase_acc_valid
add wave -noupdate -expand -group DDS -divider {LUT Adresses 0}
add wave -noupdate -expand -group DDS -radix unsigned /dds_tb/dds_inst/r_quadrant_sel_i
add wave -noupdate -expand -group DDS -radix unsigned /dds_tb/dds_inst/r_lut_addr_i
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/r_phase_accumulator_q
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/r_lut_addr_valid
add wave -noupdate -expand -group DDS -divider {LUT Adresses 1}
add wave -noupdate -expand -group DDS -radix unsigned /dds_tb/dds_inst/r_lut_addr_i_d1
add wave -noupdate -expand -group DDS -radix unsigned /dds_tb/dds_inst/r_quadrant_sel_i_d1
add wave -noupdate -expand -group DDS -radix unsigned /dds_tb/dds_inst/r_quadrant_sel_q
add wave -noupdate -expand -group DDS -radix unsigned /dds_tb/dds_inst/r_lut_addr_q
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/r_lut_addr_valid_d1
add wave -noupdate -expand -group DDS -divider {LUT Adresses 2}
add wave -noupdate -expand -group DDS -radix unsigned /dds_tb/dds_inst/r_quadrant_sel_i_d2
add wave -noupdate -expand -group DDS -radix unsigned /dds_tb/dds_inst/r_quadrant_sel_q_d1
add wave -noupdate -expand -group DDS -radix unsigned /dds_tb/dds_inst/r_lut_addr_i_effective
add wave -noupdate -expand -group DDS -radix unsigned /dds_tb/dds_inst/r_lut_addr_q_effective
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/r_lut_addr_valid_d2
add wave -noupdate -expand -group DDS -divider {LUT Adresses 3}
add wave -noupdate -expand -group DDS -radix unsigned /dds_tb/dds_inst/r_quadrant_sel_i_d3
add wave -noupdate -expand -group DDS -radix unsigned /dds_tb/dds_inst/r_quadrant_sel_q_d2
add wave -noupdate -expand -group DDS -divider {LUT Adresses 4}
add wave -noupdate -expand -group DDS -radix unsigned /dds_tb/dds_inst/r_quadrant_sel_i_d4
add wave -noupdate -expand -group DDS -radix unsigned /dds_tb/dds_inst/r_quadrant_sel_q_d3
add wave -noupdate -expand -group DDS -divider LUTs
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/w_lut_data_out_i
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/w_lut_data_out_q
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/w_lut_valid_out_i
add wave -noupdate -expand -group DDS -divider {Map Output}
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/r_valid_out
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/r_data_out_i
add wave -noupdate -expand -group DDS -radix decimal /dds_tb/dds_inst/r_data_out_q
add wave -noupdate -expand -group {DDS Lut I} -radix unsigned /dds_tb/dds_inst/dds_lut_inst_i/clk
add wave -noupdate -expand -group {DDS Lut I} -radix unsigned /dds_tb/dds_inst/dds_lut_inst_i/i_raddr
add wave -noupdate -expand -group {DDS Lut I} -radix unsigned /dds_tb/dds_inst/dds_lut_inst_i/i_valid
add wave -noupdate -expand -group {DDS Lut I} -radix decimal /dds_tb/dds_inst/dds_lut_inst_i/o_data
add wave -noupdate -expand -group {DDS Lut I} -radix unsigned /dds_tb/dds_inst/dds_lut_inst_i/o_valid
add wave -noupdate -expand -group {DDS Lut Q} -radix unsigned /dds_tb/dds_inst/dds_lut_inst_q/clk
add wave -noupdate -expand -group {DDS Lut Q} -radix unsigned /dds_tb/dds_inst/dds_lut_inst_q/i_raddr
add wave -noupdate -expand -group {DDS Lut Q} -radix unsigned /dds_tb/dds_inst/dds_lut_inst_q/i_valid
add wave -noupdate -expand -group {DDS Lut Q} -radix decimal /dds_tb/dds_inst/dds_lut_inst_q/o_data
add wave -noupdate -expand -group {DDS Lut Q} -radix unsigned /dds_tb/dds_inst/dds_lut_inst_q/o_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3897500 ps} 0} {Trace {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 202
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
WaveRestoreZoom {0 ps} {1277720 ps}
