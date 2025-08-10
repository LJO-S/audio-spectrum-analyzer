build.tcl:
	- Generates project and calls upon the other TCL scripts to generate wrappers etc.
	
top_bd_wrapper.tcl:
	- Generates .bd with PS7 (+I2C EMIO configured), XGPIO, Clocking Wizard (25M + 250M) and RTL block (containing XFFT block)

xfft_mag.tcl: 
	- Generates .bd with XFFT and magnitude calculation. Expects external clock
