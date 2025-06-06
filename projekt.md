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


## Growth
- Ta in RAW-I2S/FFT-datan i PS och göra någon behandling. Resultatet muxas med en GPIO, typ PBUTTON.
- Låta en GPIO m interrupt aktivera ett FIR-filter i PL (interrupten via PS)

## Notes
- Kolla hur FFT-ip fungerar? Vadå re/im för audio-data??
    Svar: Vi sätter IM hårt till '0' och använder bara RE.
- måste vi sätta upp audio-codec?
    Svar: Ja. Vi kan nyttja PS och audio codec drivers. Kod kan tas från Zynq-bok tutorials.


## TODO
- Simulera Xilinx FFT IP. Generera input från Python/Matlab och se beteendet. Skapa simpel
  AXIS modul i VHDL för att leverera datan, valid och last. Splitta utdata (32->16Im, 16Re), sen kan man om man vill beräkna ampl osv... Hursom kan vi studera utdata i Vivado XSim. Kom ihåg att binda fft:s tready till '1' för att få ut data.



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
                                                               
                                                               
                                                               
                                                               
                                                                    
                                                                    




















