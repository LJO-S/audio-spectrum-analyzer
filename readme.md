# FPGA Audio Spectrum Analyzer
This project implements an audio spectrum analyzer on a Zybo Z7-10. It has two modes: 
- Magnitude vs Frequency (Classical view) 
- Time vs Frequency (Spectrogram)
To aid the spectrum analysis there are LP & HP filters that can be enabled at will. They have configurable cut-off frequencies that are runtime configurable. The spectrum analyzer can generate internal "test signals" such as chirps and square waves to mess around with. It also has a mode where it reads the ADC on the Zybo to capture audio in real time.  
All DSP cores are custom and written by yours truly. Some DSP implementations I found described in articles online such as from MIT's online courses and forum posts. There is communication with the Arm core and the tasks are divided between PS & PL as I saw fit. 

How-to:
- DIP0: toggle INTERNAL/CAPTURE mode
- DIP1: CAPTURE: Enable LPF
        INTERNAL: Enable spectrogram
- DIP2: CAPTURE: Enable HPF
        INTERNAL: Enable spectrogram
- DIP2: CAPTURE: Enable spectrogram
        INTERNAL: Signal generator example page 0/1

Pushbuttons:
- INTERNAL: PB0-3 selects signal generator examples
- CAPTURE: PB0-1 incr/decr LPF cutoff. PB2-3 incr/decr HPF cutoff

## ########################################################
# Cloning the project
The project uses git submodules. There's 2 ways to clone the project:

A. 
- git clone <URL>
- git submodule init
- git submodule update

OR

B. 
- git clone --recurse-submodules <URL> 

## ########################################################
# Structure
- constraints: contains timing and pin-mapping .xdc files

- scripts: a bunch of neat Python scripts I used to generate filter coefficients, colormaps, fixed-point maths etc. Also contains the data that the VHDL files grabs when building the project.

- software: the .C files run on the Arm core in PS

- src: the VHDL files used in PL. The top entity is "project_top" 

- tcl: Build scripts used in Vivado

- test: a full Vunit testsuite I used to develop this project. Has a bunch of automatic post_checks along with plotting capabilities for select tests.

## ########################################################

# Equipment & Tools
- Zybo Z7-10 & programming cable
- 2x AUX cables (LINE_IN & HPH_OUT)
- HDMI cable
- HDMI capable screen
- (Optional) AUX capable speaker
- AUX capable audio source

# Setup
0. Set relevant jumpers. I use a wall socket and set boot mode to programmable
1. Connect the USB to the Zybo's UART programming port
2. Connect the LINE_IN port via AUX cable to an audio source of your choice
3. Connect the HPH_OUT port via AUX cable to an audio speaker of your choice
4. Connect the HDMI TX port via HDMI cable to an screen of your choice
5. Build and run as described below


# Building & running the project
1. Open Vivado 2022.1 and create a project
2. Add all the files in /src/ and the .xdc file in /builds/
3. In the TCL console: "source /PATH/build.tcl"
4. Generate bitstream and export .xsa file
5. Open Vitis and create an application project
6. Import all the files in /software/ and run Build Project
7. Power on the FPGA
8. Program the FPGA with the bitstream
(9. Optional: open a Terminal via e.g. Putty and run Telnet serial 115200 Baudrate to appropriate COM port)
10. Launch application on hardware (Single Debug)
11. Enjoy!


## ########################################################
## Growth 
- Window-funktion
- UART comms från PS (ta emot keyboard press) för att styra e.g. Window, filter incr/decr
## ########################################################
## Notes

## ########################################################
## TODO
- Ta bort BPF och ersätt med Window
- Fixa större FFT för att 25k --> 12.5k (1024p --> 2048p)
- Speed upp 100ms counter (10 ms counter)
- Gör en ny folder med constraints


## ########################################################
## Design
När vi använder RealFFT rekommenderar Xilinx att vi nyttjar (N/2 + 1) to (N) av output-spektrumet. Detta pga mer brus från algoritmen hamnar i de låga binsen.




                     
+----------+     +-----+   +-------+    +--------+        +------+          +----------+     +------+    +------+   +-------------+   +----------+
|          |     |AXI  |   | Coeff |    | Audio  |------->|Signal \         |    FFT   |     | Mag  |    | Log2 |   | FrameBuffer |   | Video    |
|    PS    |---->|BRAM |-->| BRAM  |    | Top    |        |Mux     |------->|I         |---->| Calc |--> | Calc |-->| Memory      |-->| Driver   |---> DISPLAY      
|          |     |Ctrl |   |       |    |        |    +-->|       /      +->|Q         |     |      |    |      |   |             |   |          |
+----------+     +-----+   +-------+    |---/\---|    |   +------+       |  +----------+     +------+    +------+   +-------------+   +----------+  
      |                       |         | 2x FIR |    |                  |                 
      |                       +-------->| Filter |    |                 GND                
      | config                          |---/\---|    |                                              
      V                                 |        |    |                                            
+----------+                            | I2S    |  +----------+                                   
|  Audio   |--------------------------->| Deser  |  | Signal   |                                   
|  Codec   |                            +--------+  | Gen      |                                      
|  SSM2603 |--------------------------------+       +----------+                           
+----------+                                |                                                   
      /\                                    |                                          
       |                                +--------+                                     
       |                                | I2S    |                                                  
       |                                | Ser    |                                  
    LINE IN                             +--------+         
                                            |                    
                                            |              
                                            V                                        
                                        HEADPHONES                     
                                                               



                            
DISPLAY 
                                        240                               80
                  <-----------------------------------------------><------------>
                  _______________________________________________________________
                A |                                               |   CAPTURE    | |
                | |                                               |______________| |_ 48
                | |/\                                             |   INTERNAL   | |
                | |  \                                            |______________| |_ 96
                | |   \                                           | MAX:  00 KHZ | |
                | |    \  /\                                      |______________| |_ 144
             200| |     \/  \                                     | LPF:  00 KHZ | |
                | |          \_/\                                 |______________| |_ 192
                | |              |                                | HPF:  00 KHZ | |
                | |              |                                |_____________ | |_ 240
                | |              |/\                /\            | WIN:  HANN   | |
                | |                 |            /\/  \           |______________| |_ 288
                | |                  \          /      \          | EMA          |~~~
                X |___________________\________/________\_________|_MISC_________| |_ 400
              40| |         |         |          |        |       | CREATOR:     | |
                V |         10        20         30       40      | LJOS         | |
                V |_______________________________________________|______________| V_ 480
                            106     213.33      320      426.66667
                            104     216         320      424
                








sp
