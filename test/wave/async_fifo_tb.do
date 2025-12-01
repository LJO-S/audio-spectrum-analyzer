onerror {resume}
quietly virtual signal -install /async_fifo_tb/async_fifo_inst { /async_fifo_tb/async_fifo_inst/i_wr_data(9 downto 0)} wr_seg_1
quietly virtual signal -install /async_fifo_tb/async_fifo_inst { /async_fifo_tb/async_fifo_inst/i_wr_data(9 downto 0)} wr_seg_3
quietly virtual signal -install /async_fifo_tb/async_fifo_inst { /async_fifo_tb/async_fifo_inst/i_wr_data(19 downto 10)} wr_seg_2
quietly virtual signal -install /async_fifo_tb/async_fifo_inst { /async_fifo_tb/async_fifo_inst/i_wr_data(29 downto 20)} wr_seg_1001
quietly virtual signal -install /async_fifo_tb/async_fifo_inst { /async_fifo_tb/async_fifo_inst/o_rd_data(29 downto 20)} rd_seg_1
quietly virtual signal -install /async_fifo_tb/async_fifo_inst { /async_fifo_tb/async_fifo_inst/o_rd_data(19 downto 10)} rd_seg_2
quietly virtual signal -install /async_fifo_tb/async_fifo_inst { /async_fifo_tb/async_fifo_inst/o_rd_data(9 downto 0)} rd_seg_3
quietly WaveActivateNextPane {} 0
add wave -noupdate -group tb /async_fifo_tb/i_wr_clk
add wave -noupdate -group tb /async_fifo_tb/i_wr_rst
add wave -noupdate -group tb /async_fifo_tb/i_wr_en
add wave -noupdate -group tb /async_fifo_tb/i_wr_data
add wave -noupdate -group tb /async_fifo_tb/o_full
add wave -noupdate -group tb /async_fifo_tb/i_rd_clk
add wave -noupdate -group tb /async_fifo_tb/i_rd_rst
add wave -noupdate -group tb /async_fifo_tb/i_rd_en
add wave -noupdate -group tb /async_fifo_tb/o_rd_data
add wave -noupdate -group tb /async_fifo_tb/o_empty
add wave -noupdate -expand -group async_fifo -divider -height 38 Write
add wave -noupdate -expand -group async_fifo /async_fifo_tb/async_fifo_inst/i_wr_clk
add wave -noupdate -expand -group async_fifo /async_fifo_tb/async_fifo_inst/i_wr_rst
add wave -noupdate -expand -group async_fifo /async_fifo_tb/async_fifo_inst/i_wr_en
add wave -noupdate -expand -group async_fifo -color {Dark Green} -radix unsigned /async_fifo_tb/async_fifo_inst/wr_seg_1001
add wave -noupdate -expand -group async_fifo -color {Dark Green} -radix unsigned /async_fifo_tb/async_fifo_inst/wr_seg_2
add wave -noupdate -expand -group async_fifo -color {Dark Green} -radix unsigned /async_fifo_tb/async_fifo_inst/wr_seg_3
add wave -noupdate -expand -group async_fifo -radix decimal -childformat {{/async_fifo_tb/async_fifo_inst/i_wr_data(29) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(28) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(27) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(26) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(25) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(24) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(23) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(22) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(21) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(20) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(19) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(18) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(17) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(16) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(15) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(14) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(13) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(12) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(11) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(10) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(9) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(8) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(7) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(6) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(5) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(4) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(3) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(2) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(1) -radix decimal} {/async_fifo_tb/async_fifo_inst/i_wr_data(0) -radix decimal}} -subitemconfig {/async_fifo_tb/async_fifo_inst/i_wr_data(29) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(28) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(27) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(26) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(25) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(24) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(23) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(22) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(21) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(20) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(19) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(18) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(17) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(16) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(15) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(14) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(13) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(12) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(11) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(10) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(9) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(8) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(7) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(6) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(5) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(4) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(3) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(2) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(1) {-radix decimal} /async_fifo_tb/async_fifo_inst/i_wr_data(0) {-radix decimal}} /async_fifo_tb/async_fifo_inst/i_wr_data
add wave -noupdate -expand -group async_fifo /async_fifo_tb/async_fifo_inst/o_full
add wave -noupdate -expand -group async_fifo -radix unsigned /async_fifo_tb/async_fifo_inst/r_wr_ptr_bin
add wave -noupdate -expand -group async_fifo -radix binary /async_fifo_tb/async_fifo_inst/r_wr_ptr_bin
add wave -noupdate -expand -group async_fifo -radix binary /async_fifo_tb/async_fifo_inst/r_wr_ptr_gray
add wave -noupdate -expand -group async_fifo -radix unsigned /async_fifo_tb/async_fifo_inst/r_rd_gray_sync_to_wr
add wave -noupdate -expand -group async_fifo -radix unsigned /async_fifo_tb/async_fifo_inst/r_rd_gray_sync_to_wr_d1
add wave -noupdate -expand -group async_fifo -radix unsigned /async_fifo_tb/async_fifo_inst/r_rd_bin_sync_in_wr
add wave -noupdate -expand -group async_fifo -divider -height 38 Read
add wave -noupdate -expand -group async_fifo /async_fifo_tb/async_fifo_inst/i_rd_clk
add wave -noupdate -expand -group async_fifo /async_fifo_tb/async_fifo_inst/i_rd_rst
add wave -noupdate -expand -group async_fifo /async_fifo_tb/async_fifo_inst/i_rd_en
add wave -noupdate -expand -group async_fifo -color {Dark Green} -radix unsigned /async_fifo_tb/async_fifo_inst/rd_seg_1
add wave -noupdate -expand -group async_fifo -color {Dark Green} -radix unsigned /async_fifo_tb/async_fifo_inst/rd_seg_2
add wave -noupdate -expand -group async_fifo -color {Dark Green} -radix unsigned /async_fifo_tb/async_fifo_inst/rd_seg_3
add wave -noupdate -expand -group async_fifo -radix decimal -childformat {{/async_fifo_tb/async_fifo_inst/o_rd_data(29) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(28) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(27) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(26) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(25) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(24) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(23) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(22) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(21) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(20) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(19) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(18) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(17) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(16) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(15) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(14) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(13) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(12) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(11) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(10) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(9) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(8) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(7) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(6) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(5) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(4) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(3) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(2) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(1) -radix decimal} {/async_fifo_tb/async_fifo_inst/o_rd_data(0) -radix decimal}} -subitemconfig {/async_fifo_tb/async_fifo_inst/o_rd_data(29) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(28) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(27) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(26) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(25) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(24) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(23) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(22) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(21) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(20) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(19) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(18) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(17) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(16) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(15) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(14) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(13) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(12) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(11) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(10) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(9) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(8) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(7) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(6) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(5) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(4) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(3) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(2) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(1) {-radix decimal} /async_fifo_tb/async_fifo_inst/o_rd_data(0) {-radix decimal}} /async_fifo_tb/async_fifo_inst/o_rd_data
add wave -noupdate -expand -group async_fifo /async_fifo_tb/async_fifo_inst/o_empty
add wave -noupdate -expand -group async_fifo -radix unsigned /async_fifo_tb/async_fifo_inst/r_rd_ptr_bin
add wave -noupdate -expand -group async_fifo -radix binary /async_fifo_tb/async_fifo_inst/r_rd_ptr_bin
add wave -noupdate -expand -group async_fifo -radix binary /async_fifo_tb/async_fifo_inst/r_rd_ptr_gray
add wave -noupdate -expand -group async_fifo -radix unsigned /async_fifo_tb/async_fifo_inst/r_wr_gray_sync_to_rd
add wave -noupdate -expand -group async_fifo -radix unsigned /async_fifo_tb/async_fifo_inst/r_wr_gray_sync_to_rd_d1
add wave -noupdate -expand -group async_fifo -radix unsigned /async_fifo_tb/async_fifo_inst/r_wr_bin_sync_in_rd
add wave -noupdate -divider -height 38 Memory
add wave -noupdate -radix decimal -childformat {{/async_fifo_tb/async_fifo_inst/r_memory(0) -radix decimal} {/async_fifo_tb/async_fifo_inst/r_memory(1) -radix decimal} {/async_fifo_tb/async_fifo_inst/r_memory(2) -radix decimal} {/async_fifo_tb/async_fifo_inst/r_memory(3) -radix decimal} {/async_fifo_tb/async_fifo_inst/r_memory(4) -radix decimal} {/async_fifo_tb/async_fifo_inst/r_memory(5) -radix decimal} {/async_fifo_tb/async_fifo_inst/r_memory(6) -radix decimal} {/async_fifo_tb/async_fifo_inst/r_memory(7) -radix decimal}} -expand -subitemconfig {/async_fifo_tb/async_fifo_inst/r_memory(0) {-height 15 -radix decimal} /async_fifo_tb/async_fifo_inst/r_memory(1) {-height 15 -radix decimal} /async_fifo_tb/async_fifo_inst/r_memory(2) {-height 15 -radix decimal} /async_fifo_tb/async_fifo_inst/r_memory(3) {-height 15 -radix decimal} /async_fifo_tb/async_fifo_inst/r_memory(4) {-height 15 -radix decimal} /async_fifo_tb/async_fifo_inst/r_memory(5) {-height 15 -radix decimal} /async_fifo_tb/async_fifo_inst/r_memory(6) {-height 15 -radix decimal} /async_fifo_tb/async_fifo_inst/r_memory(7) {-height 15 -radix decimal}} /async_fifo_tb/async_fifo_inst/r_memory
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {306302 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 210
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
WaveRestoreZoom {0 ps} {1050 ns}
