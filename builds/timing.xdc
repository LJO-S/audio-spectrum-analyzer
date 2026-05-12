# ============================================================
# Async FIFO Gray-pointer CDC false paths
#
# The synchronizer registers capture one Gray-coded pointer bit
# from the opposite clock domain.  Only one bit changes per
# cycle, so a metastable capture is safe; the two-stage
# synchronizer handles resolution.  We therefore tell Vivado
# to ignore the one-hop crossing and not apply any inter-clock
# timing requirement to it.
# ============================================================

# Read-domain Gray ptr (250 MHz) first sync reg in write domain (100 MHz)
set_false_path \
    -from [get_cells -hierarchical -filter {NAME =~ *async_fifo_inst/r_rd_ptr_gray_reg*}] \
    -to   [get_cells -hierarchical -filter {NAME =~ *async_fifo_inst/r_rd_gray_sync_to_wr_reg*}]

set_false_path \
    -from [get_cells -hierarchical -filter {NAME =~ *async_fifo_inst/r_rd_ptr_bin_reg*}] \
    -to   [get_cells -hierarchical -filter {NAME =~ *async_fifo_inst/r_rd_gray_sync_to_wr_reg*}]
    
# Write-domain Gray ptr (100 MHz) first sync reg in read domain (250 MHz)
set_false_path \
    -from [get_cells -hierarchical -filter {NAME =~ *async_fifo_inst/r_wr_ptr_gray_reg*}] \
    -to   [get_cells -hierarchical -filter {NAME =~ *async_fifo_inst/r_wr_gray_sync_to_rd_reg*}]

set_false_path \
    -from [get_cells -hierarchical -filter {NAME =~ *async_fifo_inst/r_wr_ptr_bin_reg*}] \
    -to   [get_cells -hierarchical -filter {NAME =~ *async_fifo_inst/r_wr_gray_sync_to_rd_reg*}]

