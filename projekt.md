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
- Kolla hur FFT-ip fungerar? Vadå re/im för audio-data??
    Svar: Vi sätter IM hårt till '0' och använder bara RE.
- måste vi sätta upp audio-codec?
    Svar: Ja. Vi kan nyttja PS och audio codec drivers. Kod kan tas från Zynq-bok tutorials.

- vad ska evaluator limit vara?
- SINC MAX: 816 242 585
- SIN MAX: 1 070 736 097
- MULTI: 717 045 101
- PINK: 474 575 933

- Idé: vi kan köra en full pass vara för att hämta maximum-värde. Sedan delar vi det med 512 (right-shift 9 ggr).

## ########################################################
## TODO
- Snygga till layout:
    - Fixa en mindre ruta X:[0,300] Y[0-300].
    - Fixa INTERNAL/CAPTURE, samt LPF/HPF/BPF
    - Fixa X-axel
    - Fixa BPF fcLo, fcHi
- Fixa folder structure att använda subdirs
- Kolla om modelsim kan simulera XilIP?
- Skriv egen FFT istället för IP


## ########################################################
## Design
När vi använder RealFFT rekommenderar Xilinx att vi nyttjar (N/2 + 1) to (N) av output-spektrumet. Detta pga mer brus från algoritmen hamnar i de låga binsen.





+----------+       +----------+      +--------+     +----------+     +----------+     
|          |       |          |      | Data   |---->|          |     | Data     |
|    PS    |--??-->|   DMA    |----->| Parser |     |  FFT IP  |---->| Splitter |       
|          |       |          |      |        |--0->|          |     |          |
+----------+       +----------+      +--------+     +----------+     +----------+       
      A |                                                             |        |
      | |                                                             V        V
 data | | conf                                                      +---+    +---+        
      | V                                                           | M |    | M |      
+----------+                                                        | U |    | U |      
|  Audio   |                                                        | L |    | L |      
|  Codec   |                                                        +---+    +---+         
|  SSM2603 |                                                          |        |
+----------+                                                          +-> [+]<-+     
                                                                           |
                                                                           |
                                                                           V
                                                    +----------+      +----------+
                                                    | DVI      |<-----| PingPong |
                                        OUT<--------| Module   |      | BRAM     |
                                                    |          |<--X--|          |
                                                    +----------+      +----------+ 
                                                               
                                                               



                            
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
              40| |         |         |          |        |       |   45| CREATOR:     | |
                V |         10        20         30       40      | LJOS         | |
                V |_______________________________________________|______________| V_ 480
                        106         213.33      320      426.66667
                        104         216         320      424
                








sp
