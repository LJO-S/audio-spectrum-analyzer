onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group TB -radix unsigned /spectrum_framebuffer_tb/clk
add wave -noupdate -group TB -radix unsigned /spectrum_framebuffer_tb/i_waterfall_en
add wave -noupdate -group TB -radix unsigned /spectrum_framebuffer_tb/i_tdata
add wave -noupdate -group TB -radix unsigned /spectrum_framebuffer_tb/i_tvalid
add wave -noupdate -group TB -radix unsigned /spectrum_framebuffer_tb/i_tlast
add wave -noupdate -group TB -radix unsigned /spectrum_framebuffer_tb/i_rd_addr_X
add wave -noupdate -group TB -radix unsigned /spectrum_framebuffer_tb/i_rd_addr_Y
add wave -noupdate -group TB -radix unsigned /spectrum_framebuffer_tb/o_rd_data
add wave -noupdate -group TB -radix unsigned /spectrum_framebuffer_tb/tb_enable
add wave -noupdate -group TB -radix unsigned /spectrum_framebuffer_tb/tb_random_data_enable
add wave -noupdate -group TB -radix unsigned /spectrum_framebuffer_tb/tb_data_idx
add wave -noupdate -group TB -radix unsigned /spectrum_framebuffer_tb/tb_X_counter
add wave -noupdate -group TB -radix unsigned /spectrum_framebuffer_tb/tb_Y_counter
add wave -noupdate -expand -group {Spectrum Framebuffer} -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/clk
add wave -noupdate -expand -group {Spectrum Framebuffer} -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/i_waterfall_en
add wave -noupdate -expand -group {Spectrum Framebuffer} -color Yellow -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/i_tdata
add wave -noupdate -expand -group {Spectrum Framebuffer} -color Yellow -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/i_tvalid
add wave -noupdate -expand -group {Spectrum Framebuffer} -color Yellow -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/i_tlast
add wave -noupdate -expand -group {Spectrum Framebuffer} -color {Cornflower Blue} -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/i_rd_addr_X
add wave -noupdate -expand -group {Spectrum Framebuffer} -color {Cornflower Blue} -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/i_rd_addr_Y
add wave -noupdate -expand -group {Spectrum Framebuffer} -color {Cornflower Blue} -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/o_rd_data
add wave -noupdate -expand -group {Spectrum Framebuffer} -divider Write
add wave -noupdate -expand -group {Spectrum Framebuffer} -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/r_wr_row_head
add wave -noupdate -expand -group {Spectrum Framebuffer} -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/r_wr_row_head_prev
add wave -noupdate -expand -group {Spectrum Framebuffer} -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/r_wr_col_head
add wave -noupdate -expand -group {Spectrum Framebuffer} -color Orange -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/r_wr_addr
add wave -noupdate -expand -group {Spectrum Framebuffer} -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/r_wr_data
add wave -noupdate -expand -group {Spectrum Framebuffer} -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/w_wr_en
add wave -noupdate -expand -group {Spectrum Framebuffer} -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/r_wr_en
add wave -noupdate -expand -group {Spectrum Framebuffer} -divider Read
add wave -noupdate -expand -group {Spectrum Framebuffer} -color {Slate Blue} -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/r_rd_addr
add wave -noupdate -expand -group {Spectrum Framebuffer} -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/w_rd_data
add wave -noupdate -expand -group {Spectrum Framebuffer} -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/C_DATA_DEPTH_X_UNS
add wave -noupdate -expand -group {Spectrum Framebuffer} -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/C_DATA_DEPTH_Y_UNS
add wave -noupdate -expand -group {Spectrum Framebuffer} -divider Misc
add wave -noupdate -expand -group {Spectrum Framebuffer} -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/r_update_row_strobe
add wave -noupdate -height 65 -expand -group BRAM -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/dpmem_bram_inst/clk
add wave -noupdate -height 65 -expand -group BRAM -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/dpmem_bram_inst/i_addra
add wave -noupdate -height 65 -expand -group BRAM -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/dpmem_bram_inst/i_dina
add wave -noupdate -height 65 -expand -group BRAM -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/dpmem_bram_inst/i_wea
add wave -noupdate -height 65 -expand -group BRAM -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/dpmem_bram_inst/o_douta
add wave -noupdate -height 65 -expand -group BRAM -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/dpmem_bram_inst/i_addrb
add wave -noupdate -height 65 -expand -group BRAM -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/dpmem_bram_inst/i_dinb
add wave -noupdate -height 65 -expand -group BRAM -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/dpmem_bram_inst/i_web
add wave -noupdate -height 65 -expand -group BRAM -radix unsigned /spectrum_framebuffer_tb/spectrum_framebuffer_inst/dpmem_bram_inst/o_doutb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5193253 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 183
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
WaveRestoreZoom {5138720 ps} {5316056 ps}
