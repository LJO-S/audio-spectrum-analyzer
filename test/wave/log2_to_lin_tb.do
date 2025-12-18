onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group TB -radix unsigned /log2_to_lin_tb/clk
add wave -noupdate -expand -group TB -radix unsigned /log2_to_lin_tb/i_tdata
add wave -noupdate -expand -group TB -radix unsigned /log2_to_lin_tb/i_tvalid
add wave -noupdate -expand -group TB -radix unsigned /log2_to_lin_tb/o_tdata
add wave -noupdate -expand -group TB -radix unsigned /log2_to_lin_tb/o_tvalid
add wave -noupdate -expand -group TB -radix decimal /log2_to_lin_tb/tb_linear_golden
add wave -noupdate -expand -group TB -radix decimal /log2_to_lin_tb/tb_linear_diff_percent
add wave -noupdate -expand -group log2_to_lin -radix unsigned /log2_to_lin_tb/log2_to_lin_inst/clk
add wave -noupdate -expand -group log2_to_lin -radix unsigned /log2_to_lin_tb/log2_to_lin_inst/i_tdata
add wave -noupdate -expand -group log2_to_lin -radix unsigned /log2_to_lin_tb/log2_to_lin_inst/i_tvalid
add wave -noupdate -expand -group log2_to_lin -radix unsigned /log2_to_lin_tb/log2_to_lin_inst/o_tdata
add wave -noupdate -expand -group log2_to_lin -radix unsigned /log2_to_lin_tb/log2_to_lin_inst/o_tvalid
add wave -noupdate -expand -group log2_to_lin -radix unsigned /log2_to_lin_tb/log2_to_lin_inst/r_frac_lut
add wave -noupdate -expand -group log2_to_lin -radix unsigned /log2_to_lin_tb/log2_to_lin_inst/r_frac_lut_val
add wave -noupdate -expand -group log2_to_lin -radix unsigned /log2_to_lin_tb/log2_to_lin_inst/r_int_raw
add wave -noupdate -expand -group log2_to_lin -radix unsigned /log2_to_lin_tb/log2_to_lin_inst/r_frac_raw
add wave -noupdate -expand -group log2_to_lin -radix unsigned /log2_to_lin_tb/log2_to_lin_inst/r_shifted
add wave -noupdate -expand -group log2_to_lin -radix unsigned /log2_to_lin_tb/log2_to_lin_inst/r_linear_value
add wave -noupdate -expand -group log2_to_lin -radix unsigned /log2_to_lin_tb/log2_to_lin_inst/r_valid
add wave -noupdate -expand -group log2_to_lin -radix unsigned /log2_to_lin_tb/log2_to_lin_inst/r_valid_d1
add wave -noupdate -expand -group log2_to_lin -radix unsigned /log2_to_lin_tb/log2_to_lin_inst/r_valid_d2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {212015 ps} 0}
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
WaveRestoreZoom {116495 ps} {227927 ps}
