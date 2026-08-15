
# Audio Spectrum Analyzer on a Zybo Z7-10

Click for video demonstration:
<p align="center">
  <a href="[https://www.youtube.com/watch?v=OWQmLbjGhkA](https://www.youtube.com/watch?v=XASKmPDUobE)">
    <img src="https://github.com/user-attachments/assets/3fdea9d1-b1d0-4540-86a3-05621593b919" width="900" alt="Watch the video">
  </a>
</p>

Hackster.io article:
https://www.hackster.io/ljo-s/spectrum-analyzer-on-a-zybo-z710-fpga-a72c1b

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
  
## Introduction

A spectrum analyzer is one of those devices that not only is a very handy tool but also makes use of some fascinating digital signal processing. Pick up a DSP book and I bet that you could incorporate most of the subjects into a spectrum analyzer. This project implements a handful of those, such as the Fast Fourier Transform, FIR filtering and sampling. Moreover, this project will implement HDMI protocols, PS-to-PL communication, spectrum waterfalls, GPIO and a GUI.

The goal was to create a pocket-sized spectrum analyzer, mostly to see if I could. Another goal was to view interesting sounds on the spectrum, like music and sonar pings.

## Hardware
First off, what is an FPGA? A Field Programmable Gate Array (FPGA) is an integrated circuit with a digital architecture that can be reprogrammed after manufacture. In short, this means that a user can describe a digital architecture using a Hardware Description Language, burn it onto the FPGA and run it. Theoretically, this can go on infintely, in turn making the FPGA a perfect device for RnD and low-quantity production. The parallel nature of these circuits means that FPGAs excel at executing parallelizable tasks. Thus, many sectors make use of FPGAs for high signal processing requirements. In recent years System-on-Chips (SoC) have grown in popularity. A SoC in this context means that a CPU is tightly integrated alongside the FPGA. The CPU is often referred to as the Processing System (PS), whereas the FPGA is the Programmable Logic (PL). The CPU/FPGA pairup allows the developer to partition parts of an implemention to run on either the PS, PL or both. One could let a Machine Vision algorithm run on the PS, and stream input data to the PL where it computes fast matrix math and then sends it back to the PS for classification etc.

The Digilent Zybo Z7-10 is a development board from Digilent featuring a Zynq 7010 SoC FPGA from Xilinx. The dev board features a bunch of gadgets, such as PMOD connectors, SD card input, HDMI connector, Audio Codec and more. Since it's an Xilinx product (in turn owned by AMD) it makes use of Vivado to program the FPGA. The dev board, USB cable, HDMI cable and two AUX cables (one Rx from a sound source, one optional Tx to a speaker) is all that's required for this project.

## Implementation
Here is a general overview of the project:

<img width="740" height="355" alt="image" src="https://github.com/user-attachments/assets/942ef664-4e25-4ced-80a7-125fb5268bd2" />

The legend in the bottom right explains what we're looking at. The orange lines are configuration data, whereas the blue contain signal data.

Let's start with the video display.

## Part 1: Video/Display
An HDMI connector is readily available on the Zybo, so why not use it. HDMI is a beast of a protocol, so I did quite some research to understand the intrinsics of it. After some digging around I found that DVI and HDMI are generally interoperable. That means displays with HDMI inputs can be driven by DVI signaling. Besides, DVI uses a subset of the HDMI so it's easier to implement. I won't get into the details of the protocol, but the main thing about DVI is TMDS and 8b10b encoding.

Transition Minimized Differential Signaling (TMDS) is a standard that sends uncompressed data over a digital interface. It uses differential signaling to reduce EMI, so there's a P and N pair to every signal. Three TMDS pairs are used to transmit RGB data. The Red, Green and Blue color signals to the display are 8 bits each. The RGB data gets encoded using 8b10b encoding before the batch is transmitted serially.

Now, what is 8b10b? One might mix it up with IBM's 8b10b, but that's a different encoding. In our case, 8b10b is a common encoding in TMDS with some favorable characteristics. First, the encoding minimizes the number of bit transitions in the serial transfer by using XOR or XNOR encoding; the 9th bit says which operation was used. Moreover, the first 8 bits can be inverted to even out the balance between 1s and 0s to not cause any DC bias on the TMDS line; whether the data was inverted or not is represented by the 10th bit. Below is a diagram showing the encoding:

<img width="389" height="555" alt="image" src="https://github.com/user-attachments/assets/30071b25-f925-49e5-858b-644584ea1f7d" />

From that diagram we can implement the the protocol. The pixel clock determines the screen resolution. Here are a few test runs I did to try out my implementation. Lo and behold, a smiley and some white noise!

<img width="740" height="555" alt="image" src="https://github.com/user-attachments/assets/fb1fa0bd-0233-4f15-afd4-d987e0a0f2ff" />
<img width="740" height="555" alt="image" src="https://github.com/user-attachments/assets/fe547831-ba19-4cfb-a3d4-5283f3275ac7" />

## Part 2: Graphical User Interface
Now that we know how to drive a modern display using the HDMI/DVI protocol, we need a Graphical User Interface. I had a rough idea of what I wanted:

<img width="478" height="314" alt="image" src="https://github.com/user-attachments/assets/dbba8193-20c6-4b39-ace6-0756fb8f1d14" />

Now how does one go about implementing that in VHDL? For most screen applications, an X and Y counter runs on the system clock and determines when certain regions on the screen are supposed to be updated and so on. One could map out when select pixels should be active and with what color - then when the X/Y counter fulfills some criteria the pixel activates. That works for simple lines but would be VERY tedious for complex renderings, e.g. words. That's where a Font ROM and Tile-Scaling comes into play.

The Font ROM is just a read-only memory with 8x16 bits forming letters. It might look like this:

<img width="740" height="530" alt="image" src="https://github.com/user-attachments/assets/2bb028fd-19ce-4c85-b85a-5fe353da2ef3" />

Furthermore, to enlarge these words as to cover more space on the screen I was inclined to use tile scaling. Tile scaling works like this:

Say the X counter is 10 bits. The X counter is used as a column address (0-7) to the font row (0-15) selected by the Y counter. The X counter's LSB will change every clock tick, but if you use the upper 9 bits as the column address you will suddenly have decreased the LSB update count by 50%. In other words, you will have increased the font ROM bit by 50%, making 1 pixel worth 2 pixels. By splicing out parts of the X and Y counters you can scale objects on the display. There is no simple procedure to this, it's an art. Scale, view the results and re-iterate until you're satisfied!

Using the above described techniques I was able to implement most of the static GUI, like lines, axis ticks, configuration parameters on the right. To achieve the spectrum and waterfall display requires some more tricks, and we'll get into that later.

## Part 3: Signal Generator
The implementation is capable of selecting INTERNAL as shown on the GUI. This means that the FFT input data MUX selects internally generated samples. The signal generator is actually very simple. One might be tempted to use something smart, like a Direct Digital Synthesizer, but I opted for something even simpler.

A Python script initially generates the IQ data, converts it to fixed-point binary and writes it to a.txt file. Upon synthesizing the design, eight memory wrappers initializes Block RAM using said.txt files. In other words, the signal generator samples are stored on the FPGA. Here's some snippets of the Python output:

<img width="640" height="480" alt="image" src="https://github.com/user-attachments/assets/0288d296-5dc1-49dd-9d27-0665628956dd" />

This works for sample sizes in the magnitude of thousands and appropriate bit widths. However, for larger batches this route is not optimal. My design only used the onboard signal generator to debug the FFT, so this worked just fine for my needs! Here's a couple of snapshots of the internally generated signals you see above:

<img width="740" height="555" alt="image" src="https://github.com/user-attachments/assets/a14df43b-3906-4089-b976-72e9b293b373" />

## Part 4: ADC & DAC
On the Zybo Z7-10 there is an SSM2603 Audio Codec. This IC is comprised of an ADC, DAC and some control logic. I won't get into the specifics as the datasheet can be found online. The codec is configured over I2C and I opted for using the PS core to handle all that communication. I wrote a C program to set up the SSM2603 for my needs, such as configuring the sample rate, the data width among many other things. Then I configured the PS core to handle I2C, allowing me call upon the "xiicps.h" header file in my C code. 
The keen reader will have noted that I wrote I2S data in the previous paragraph. What is that? It's simply a serial interface protocol transmitting digital audio as Linear Pulse-Code Modulation, meaning that the data has been sampled at regular intervals.

<img width="653" height="225" alt="image" src="https://github.com/user-attachments/assets/5f0eb54b-9639-4cda-9cc2-626ef31502cf" />

For those of you that have implemented UART, this will be kind of similar. As can be seen on the datasheet, I needed a way of de-serializing the I2S data and storing it in a buffer, so that's what I did. Likewise, I wrote an I2S serializer to serialize 16-bit words being sent to the DAC, allowing me to listen to the audio being displayed on the spectrum.

## Part 5: Fast Fourier Transform

This deserves an article on its own, and the block diagram is almost as complex as that of the spectrum analyzer, so I'll keep it brief. The FFT in this project is a decimation-in-time radix-2 Cooley-Tukey architecture. I had never constructed an FFT before, so I had to do some research before having my own go at it. Below are some good resources I remembered to jot down:

    - Gao, Ying. (2015). Hardware Implementation of a 32-point Radix-2 FFT Architecture
    - Slade, George. (2013). The Fast Fourier Transform in Hardware: A Tutorial Based on an FPGA Implementation.
    - Correa et al. (2012). VHDL Implementation of a Flexible and Synthesizable FFT Processor.
    - Wikipedia, Fast Fourier Transform

And of course the OG paper, "An Algorithm for the Machine Calculation of Complex Fourier Series" by James W. Cooley and John W. Tukey! There are countless resources out there on FFTs. Go read a few and I bet you'll be able to code your own FFT processor in no time. My implementation was two-fold:

A. Python implementation

I built an FFT model in Python which I could experiment with to understand the FFT algorithm and later use as a reference when testing my VHDL implementation. It basically goes like this:

1. Compute the input permutation (via bit reversal)

2. Compute twiddle factors

3. Perform the Danienlson-Lanczos algorithm

The Danielson-Lancsoz algorithm is a divide-and-conquer approach to the Discrete Fourier Transform in which an N-point DFT (where N is a power-of-two) can be divided up into a sum of two even-numbered and odd-numbered terms. These can in turn be divided into their odd and even terms, and this keeps going for log2(N) levels. Here's a classic FFT diagram, showing the interleaved butterfly stages at work:

<img width="688" height="555" alt="image" src="https://github.com/user-attachments/assets/d095826f-df76-430e-9e10-7ddc5f139419" />

Below is the output from my script, showing the expected results from a 32-point FFT.

<img width="740" height="491" alt="image" src="https://github.com/user-attachments/assets/93ef1a26-798b-48ca-ae66-764d68c54c9c" />

B. VHDL Implementation

From the Python implementation it was pretty straightforward to implement the FFT. All the twiddle factors are generated from the Python model and the Twiddle Memory Wrapper just calls upon the generated.txt files to initialize its BRAM, whether for simulating or compiling for the FPGA.

I was hellbent on getting 16-bit IQ data as both input and output, so the most difficult part of the VHDL implementation was that I had to handle bit growth via scaling schemes. But I finally got it working, and starting running some testbenches on the design. Here's the output from a 22 kHz complex sinusoid signal as input:

<img width="660" height="555" alt="image" src="https://github.com/user-attachments/assets/fb387610-56ac-4b72-afdd-6e02d6588503" />

As can be seen from the figure above, we have a peak at the 58th bin of the 128-point FFT. That corresponds to f=58 * (48800/128) = 22.1 kHz. Close enough! My testbench accepts sampling frequency, data width and N-points as input parameters, allowing me to test a bunch of different configurations. The output from the testbench is then checked against the Python model. Neat, huh?

## Part 6: FIR Filters

No FPGA DSP project would be complete without at least a mention of FIR filters. Well, here you get an implementation too! The FIR filter, or Finite Impulse Response filter is a topic some of you might have been taught at college. It's convolution of an input signal with a filter response. Since we require the filter to be causal (if you have a non-causal solution, let me know) we use past input samples to perform the convolution. The FIR equation is shown below:

<img width="394" height="128" alt="image" src="https://github.com/user-attachments/assets/427433f6-aa23-4d78-bd7a-760cd0995ac4" />

We clearly see that a delay element is introduced, which is easily performed by just using a shift-register. The filter characteristics is determined by the number of delay elements, or taps, and the coefficient values. In general, a narrower transition band requires more taps. Moreover, the filter coefficients determine the filter behaviour, i.e. lowpass, bandpass or highpass.

For my application, I wanted a runtime adjustable bandpass filter, and opted to do it via the poor man's BPF, namely using a HPF in conjuction with a LPF. I also wanted to be able to change the cutoff frequency in steps of 1 kHz, so that's the resolution as we'll see later on.

The LPF coefficients are generated via the Kaiser method. A Kaiser window is a tapering function that is multiplied onto the ideal (sinc) impulse response to generate a FIR from an IIR. By varying the parameter 'beta' we effectively vary the width of the Kaiser main lobe and the attentuation of the sidelobes. The 1st null is found at bin n=sqrt(1+beta^2). Note how increasing by 'beta', we increase the mainlobe width (the 1st null before the sidelobe is moved away). This creates a narrow transition band. BUT! A higher 'beta' causes lower stopband attenuation (seen with increased sidelobe levels). Usually a 'beta' of 5 can yield ≃60 dB attenuation in the stopband.

Playing around with parameters I settled for a 101-tap filter (note the odd number of taps, allowing coefficient symmetry to be utilized). Below are the results from the Kaiser method:

<img width="740" height="355" alt="image" src="https://github.com/user-attachments/assets/6a6a29a2-7978-40cc-91b8-409102d72d1a" />
<img width="740" height="354" alt="image" src="https://github.com/user-attachments/assets/1e7f8612-4887-438b-8fb6-1ed539f62e92" />

After that I can use spectral inversion from the LPF coefficients to generate the HPF coefficients. We have h_hp[n] = delta[n-M] - h_lp[n] where M=(N-1)/2. This can be shown using Euler's formula, but multiplying every other term by -1 is equal to shifting the frequency spectrum around half the sampling rate, moving the LP response into the HP response. Here's the output from that maneuver:

<img width="740" height="355" alt="image" src="https://github.com/user-attachments/assets/57e1dbfe-78be-4d4d-b046-1c3bc4021e03" />
<img width="740" height="354" alt="image" src="https://github.com/user-attachments/assets/e7dc4b45-1d4f-4b50-b725-1625acfb52ce" />

The coefficients are effectively handled by the PS and an Interrupt Request Handler manages when and what coefficients to write to PL when the user requests a cutoff increment/decrement. Information is sent over UART, which allowed me to check the terminal via PuTTy/TeraTerm when things went haywire - which they did at first! Reading Xilinx User Guides are heavily recommended when playing around with the PS core...
I simulated the FIR filter implementation with white noise input to view the actual cutoff acquired, and then compared with theoretical output. The results were very promising!

<img width="740" height="385" alt="image" src="https://github.com/user-attachments/assets/49028d49-a4d7-463e-9b5f-9e56624e8090" />
<img width="740" height="385" alt="image" src="https://github.com/user-attachments/assets/c4e0b79a-aad7-40c3-958f-55832e78f433" />
<img width="740" height="466" alt="image" src="https://github.com/user-attachments/assets/6feed1f9-fd63-4530-8e8f-5f7614ef12b4" />

## Part 7: Spectrum Display
I wanted to display the spectrum in two ways, allowing me to choose between the spectrum and the spectrogram. Let's start with the latter.

For the rolling waterfall effect you see in a spectrogram it is required to keep past information of spectral output. I chose to save previous samples onboard the FPGA BRAM. I chose to keep 480 of the 1024 complex output samples for each output batch, and save 200 of these batches. Now, given that the magnitude is 32 bits I have to store 480*200*(32/8) = 360 kB. The Zybo Z7-10 onboard BRAM is only 270 kB, so let's think of another way. First off, the LSBs of the magnitude aren't that important as they'll get obscured by noise either way. Therefore, I could do a log2() compression, i.e. perform log2 on the magnitude and save those values. A log2 is only a leading zero count followed by a LUT for the decimals. Log2 on a 32-bit number will give us a 5-bit number, and using 3 decimals we'll get 8 bits, or 1 byte. Thus we get: 480*200*1 = 96 kB. Much better!

The actual 8-bit value will also serve as an address to a 2⁸-element deep ROM containing RGB values to get the waterfall intensity display.

On top of this, we'll need some control logic to always update the column and row read/write heads.

For the 1D-display, I'll fetch the top row of the spectrum and use that. From those values it is easy to get a spectrum effect; just let the rasterized X/Y counter decrement a maximum value for each row, and if the current FFT output bin exceeds the value, set pixels on this X column down from this Y value to white. That's it!

<img width="740" height="449" alt="image" src="https://github.com/user-attachments/assets/d869eb03-0632-492e-aad4-8df971fae530" />

