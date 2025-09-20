onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ring_buffer_fifo_tb/tb_compare_data_arr
add wave -noupdate -expand -group ring_buffer_fifo /ring_buffer_fifo_tb/ring_buffer_fifo_inst/clk
add wave -noupdate -expand -group ring_buffer_fifo /ring_buffer_fifo_tb/ring_buffer_fifo_inst/reset
add wave -noupdate -expand -group ring_buffer_fifo /ring_buffer_fifo_tb/ring_buffer_fifo_inst/i_wr_en
add wave -noupdate -expand -group ring_buffer_fifo /ring_buffer_fifo_tb/ring_buffer_fifo_inst/i_wr_data
add wave -noupdate -expand -group ring_buffer_fifo /ring_buffer_fifo_tb/ring_buffer_fifo_inst/i_rd_en
add wave -noupdate -expand -group ring_buffer_fifo /ring_buffer_fifo_tb/ring_buffer_fifo_inst/o_rd_data
add wave -noupdate -expand -group ring_buffer_fifo /ring_buffer_fifo_tb/ring_buffer_fifo_inst/o_rd_valid
add wave -noupdate -expand -group ring_buffer_fifo -color {Cornflower Blue} /ring_buffer_fifo_tb/ring_buffer_fifo_inst/o_empty
add wave -noupdate -expand -group ring_buffer_fifo -color {Cornflower Blue} /ring_buffer_fifo_tb/ring_buffer_fifo_inst/o_empty_next
add wave -noupdate -expand -group ring_buffer_fifo -color Salmon /ring_buffer_fifo_tb/ring_buffer_fifo_inst/o_full
add wave -noupdate -expand -group ring_buffer_fifo -color Salmon /ring_buffer_fifo_tb/ring_buffer_fifo_inst/o_full_next
add wave -noupdate -expand -group ring_buffer_fifo /ring_buffer_fifo_tb/ring_buffer_fifo_inst/r_FIFO_DATA
add wave -noupdate -expand -group ring_buffer_fifo -color Cyan /ring_buffer_fifo_tb/ring_buffer_fifo_inst/r_head
add wave -noupdate -expand -group ring_buffer_fifo -color Magenta /ring_buffer_fifo_tb/ring_buffer_fifo_inst/r_tail
add wave -noupdate -expand -group ring_buffer_fifo /ring_buffer_fifo_tb/ring_buffer_fifo_inst/w_full
add wave -noupdate -expand -group ring_buffer_fifo /ring_buffer_fifo_tb/ring_buffer_fifo_inst/w_full_next
add wave -noupdate -expand -group ring_buffer_fifo /ring_buffer_fifo_tb/ring_buffer_fifo_inst/w_empty
add wave -noupdate -expand -group ring_buffer_fifo /ring_buffer_fifo_tb/ring_buffer_fifo_inst/w_empty_next
add wave -noupdate -expand -group ring_buffer_fifo -format Analog-Step -height 74 -max 8.0 /ring_buffer_fifo_tb/ring_buffer_fifo_inst/w_fill_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {121508 ps} 0}
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
WaveRestoreZoom {0 ps} {223125 ps}
