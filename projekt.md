
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
# Building the project
- bla bla bla tcl scripts bla bla vivado 2022.2


## ########################################################
Idéen är följande:

- Vi nyttjar Zybons audio codec för att koppla mot:
    - input: t.ex. dators AUX-sladd
- Vi kör en IP FFT och gör om resultatet till frekvensdata
    - Reell audio-data till reell port, kvadraturdata till '0'. 
    - Hälften av utdatan går förlorad.
- Vi tar resultatet och mappar över till 640x480p format på något snyggt sätt
    - Output från FFT skrivs till BRAM0, videodata hämtas från BRAM1. När BRAM0 är fylld, gör en r_pingpong='1' och byt write till BRAM1 och läs till BRAM0. Ping-pong!
    - Output skrivs med magnitud, t.ex. |Re| + |Im| till varje element, så i element 0 i BRAMX, så finns data för bin 0 osv. BRAM är lika stort som antalet binnar.
    - if BRAM(bin0) > ((480 + FFT_data_offset) - curr_Y_pos) '1' else '0'
        - Måste typ kolla lite på resultatet vilket storlek vi får...
- Resultatet visas på HDMI/VGA protokoll på skärmen i realtid

## ########################################################
## Growth 
- Window-funktion
## ########################################################
## Notes

## ########################################################
# 125 MHZ!
- [DONE] signal_generator 
- [DONE] ping_Pong_memory  OBS kör TB
- [DONE] Video Driver
- [DONE] GPIO Ctrl
- [DONE] GPIO PS IF
- TMDS_TOP
- Audio Top
    - SRC [DONE]
    - TEST [DONE]
    - Audio Buffer [DONE]
    - I2S Deser
        - SRC [DONE]
        - TEST [DONE]
    - I2S Ser 
        - SRC [DONE]
        - TEST [DONE]
    - Filter Bank
        - SRC [DONE]
        - TEST [DONE: TODO should be tested]
    - Fir_filter
        - SRC [DONE]
        - TEST [DONE: TODO should be tested]


- Kör video-testbänkar och se CE beteende
    - Kör ASCII Gen
    - Skapa TB Video Top
        - Kolla på /master/ om tmds 250 och i_pxlclk är unaligned

- Skapa constraints for r_pixclk



## ########################################################
## TODO
- Klocka upp till 125 MHz
- Fixa waterfall
    - Behöver magnitude (32bit) -> log10 (12/8bit)
    - Minneshantering (ett 480x120x12/8 bit minne)
    - LUT i Video Driver som gör om till vattenfallshantering
- Ta bort BPF och ersätt med Window



## ########################################################
## Design
När vi använder RealFFT rekommenderar Xilinx att vi nyttjar (N/2 + 1) to (N) av output-spektrumet. Detta pga mer brus från algoritmen hamnar i de låga binsen.




                     
+----------+     +-----+   +-------+    +--------+        +------+          +----------+     +----------+     
|          |     |AXI  |   | Coeff |    | Audio  |------->|Signal \         |    FFT   |     | Data     |
|    PS    |---->|BRAM |-->| BRAM  |    | Top    |        |Mux     |------->|I         |---->| Splitter |       
|          |     |Ctrl |   |       |    |        |    +-->|       /      +->|Q         |     |          |
+----------+     +-----+   +-------+    |---/\---|    |   +------+       |  +----------+     +----------+       
      |                       |         | 2x FIR |    |                  |                     |        |
      |                       +-------->| Filter |    |                 GND                    V        V
      | conf                            |---/\---|    |                                      +---+    +---+        
      V                                 |        |    |                                      | M |    | M |      
+----------+                            | I2S    |  +----------+                             | U |    | U |      
|  Audio   |--------------------------->| Deser  |  | Signal   |                             | L |    | L |      
|  Codec   |                            +--------+  | Gen      |                             +---+    +---+         
|  SSM2603 |--------------------------------+       +----------+                               |        |
+----------+                                |                                                  +-> [+]<-+     
      /\                                    |                                                       |
       |                                +--------+                                                  |
       |                                | I2S    |                                                  V
       |                                | Ser    |                            +----------+      +----------+
    LINE IN                             +--------+                            | DVI      |<-----| PingPong |
                                            |                  SCREEN<--------| Module   |      | BRAM     |
                                            |                                 |          |<--X--|          |
                                            V                                 +----------+      +----------+ 
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
