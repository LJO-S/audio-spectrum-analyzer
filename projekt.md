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
- Ta in RAW-I2S/FFT-datan i PS och göra någon behandling. Resultatet muxas med en GPIO, typ PBUTTON.
- Låta en GPIO m interrupt aktivera ett FIR-filter i PL (interrupten via PS)
## ########################################################
## Notes

## ########################################################
## TODO
- Ta bort BPF och ersätt med EMA
    - Kanske EMA-orig ska va en cursor? Men hur fan styr vi den...
- Kolla om 3rd party simulator kan simulera XilinxIP?
    - Jajemen, kör 'compile_simlibs ...' i TCL och få alla bibliotek. 
    - Exempelvis hade varit att låta python köra ett TCL-skript som bygger upp bd-blocket, sen kompilera simlibs och lägg till i Vunit. 
      ... Det finns ett Vunit-exempel som Asplund lagt upp i just detta syfte.
    - Går det med QuestaSim FSE? Ja, med detta fulhack: https://adaptivesupport.amd.com/s/question/0D52E00006q090LSAQ/failed-to-find-the-questasim-simulator-executable-when-i-try-to-compile-vivado-libraries-for-questasim?language=en_US
    - Problemet är att fulhacket bygger på att vcom är ett .sh-skript. Och inte en .exe. Så gör om detta vid tillfälle för dual-boot. 
- Skriv egen FFT istället för IP
- Gör en project_top som instansierar project_top_pl.vhd & project_top_ps.vhd. Låt klockorna komma från pl-delen. Då kan project_top PL simuleras på egen hand. 

### TODO-filter
- FFT
- Gör FFT och GUI dynamiskt så man kan se t.ex. 0-10 khz


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
                | |              |                                | BPF:  00 KHZ | |
                | |              |                                |_____________ | |_ 240
                | |              |/\                /\            | HPF:  00 KHZ | |
                | |                 |            /\/  \           |______________| |_ 288
                | |                  \          /      \          | EMA          |~~~
                X |___________________\________/________\_________|_MISC_________| |_ 400
              40| |         |         |          |        |       | CREATOR:     | |
                V |         10        20         30       40      | LJOS         | |
                V |_______________________________________________|______________| V_ 480
                            106     213.33      320      426.66667
                            104     216         320      424
                








sp
