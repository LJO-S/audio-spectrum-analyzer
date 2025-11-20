onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group TB /ping_pong_memory_tb/clk_25
add wave -noupdate -expand -group TB /ping_pong_memory_tb/i_fft_data_magn
add wave -noupdate -expand -group TB /ping_pong_memory_tb/i_fft_data_last
add wave -noupdate -expand -group TB /ping_pong_memory_tb/i_fft_data_valid
add wave -noupdate -expand -group TB /ping_pong_memory_tb/i_xk_index
add wave -noupdate -expand -group TB /ping_pong_memory_tb/i_rd_addr
add wave -noupdate -expand -group TB /ping_pong_memory_tb/o_rd_data
add wave -noupdate -expand -group TB /ping_pong_memory_tb/tb_start_data
add wave -noupdate -expand -group TB /ping_pong_memory_tb/tb_clk_strobe
add wave -noupdate -expand -group TB /ping_pong_memory_tb/tb_use_slow_readout
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/clk_25
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/i_fft_data_magn
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/i_fft_data_valid
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/i_fft_data_last
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/i_xk_index
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/i_rd_addr
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/o_rd_data
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/r_fft_data_valid
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/r_xk_index
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/r_fft_data_magn
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/r_fft_data_last
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/r_rd_addr
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/r_pingpong
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/r_pingpong_d1
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/r_pingpong_d2
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -divider {BRAM 0}
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/r_addr_bram0
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/r_rd_data_bram0
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/r_wr_data_bram0
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/r_wr_en_bram0
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -divider {BRAM 1}
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/r_addr_bram1
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/r_rd_data_bram1
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/r_wr_data_bram1
add wave -noupdate -height 50 -expand -group {PING PONG MEM} -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/r_wr_en_bram1
add wave -noupdate -height 50 -expand -group BRAM0 /ping_pong_memory_tb/ping_pong_memory_inst/BRAM0_inst/clk
add wave -noupdate -height 50 -expand -group BRAM0 -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/BRAM0_inst/i_addra
add wave -noupdate -height 50 -expand -group BRAM0 /ping_pong_memory_tb/ping_pong_memory_inst/BRAM0_inst/i_dina
add wave -noupdate -height 50 -expand -group BRAM0 /ping_pong_memory_tb/ping_pong_memory_inst/BRAM0_inst/i_wea
add wave -noupdate -height 50 -expand -group BRAM0 /ping_pong_memory_tb/ping_pong_memory_inst/BRAM0_inst/o_douta
add wave -noupdate -height 50 -expand -group BRAM0 -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/BRAM0_inst/addra
add wave -noupdate -height 50 -expand -group BRAM0 -radix decimal /ping_pong_memory_tb/ping_pong_memory_inst/BRAM0_inst/dina
add wave -noupdate -height 50 -expand -group BRAM0 /ping_pong_memory_tb/ping_pong_memory_inst/BRAM0_inst/wea
add wave -noupdate -height 50 -expand -group BRAM0 /ping_pong_memory_tb/ping_pong_memory_inst/BRAM0_inst/regcea
add wave -noupdate -height 50 -expand -group BRAM0 /ping_pong_memory_tb/ping_pong_memory_inst/BRAM0_inst/douta
add wave -noupdate -height 50 -expand -group BRAM0 /ping_pong_memory_tb/ping_pong_memory_inst/BRAM0_inst/douta_reg
add wave -noupdate -height 50 -expand -group BRAM0 /ping_pong_memory_tb/ping_pong_memory_inst/BRAM0_inst/ram_data
add wave -noupdate -height 50 -expand -group BRAM1 /ping_pong_memory_tb/ping_pong_memory_inst/BRAM1_inst/clk
add wave -noupdate -height 50 -expand -group BRAM1 -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/BRAM1_inst/i_addra
add wave -noupdate -height 50 -expand -group BRAM1 -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/BRAM1_inst/i_dina
add wave -noupdate -height 50 -expand -group BRAM1 -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/BRAM1_inst/i_wea
add wave -noupdate -height 50 -expand -group BRAM1 -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/BRAM1_inst/o_douta
add wave -noupdate -height 50 -expand -group BRAM1 -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/BRAM1_inst/addra
add wave -noupdate -height 50 -expand -group BRAM1 -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/BRAM1_inst/dina
add wave -noupdate -height 50 -expand -group BRAM1 -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/BRAM1_inst/wea
add wave -noupdate -height 50 -expand -group BRAM1 -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/BRAM1_inst/regcea
add wave -noupdate -height 50 -expand -group BRAM1 -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/BRAM1_inst/douta
add wave -noupdate -height 50 -expand -group BRAM1 -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/BRAM1_inst/douta_reg
add wave -noupdate -height 50 -expand -group BRAM1 -radix unsigned /ping_pong_memory_tb/ping_pong_memory_inst/BRAM1_inst/ram_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14016493 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 180
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
WaveRestoreZoom {0 ps} {43438500 ps}
