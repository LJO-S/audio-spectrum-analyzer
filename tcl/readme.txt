build.tcl:
	- En projektbyggar TCL som bygger upp projektet.

xfft_mag.tcl: 
	- skapar xfft med magnitudberäkning. Förväntar sig extern klocka.

top_bd_wrapper.tcl:
	- skapar en BD med PS-kärna med I2C konfigurerat, XGPIO, en clk wiz (25M + 250M), samt RTL block med XFFT.
	
z7_i2c_setup.tcl (obsolete):
	- Skapar PS-kärna med I2C konfigurerat. Använd ps_pl_wrapper.tcl istället.


xfft_clk_wiz_mag (obsolete): 
	- skapar xfft med magnitudberäkning. Har intern clk wiz (25M + 250M).

sig_gen_with_mem (obsolete):
	- ungefär samma som xfft_clk_wiz_mag

ps_pl_wrapper.tcl (obsolete)
	- en föregångare till top_bd_wrapper.tcl. 