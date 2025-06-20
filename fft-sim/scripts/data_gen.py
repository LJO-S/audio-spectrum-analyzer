import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
import argparse
import copy
from bitstring import BitArray
from pathlib import Path

# [X] Generate data (sine wave?)
# [X] Truncate data
# [] Write to file


class generateData:
    def __init__(self, a_freq: int, a_length: int, a_numBits: int, a_type: str):
        # Sampling freq (SSM2603 uses 96kHz)
        self.fs = 96e3
        # Length of signal
        self.length = a_length
        # Number of bits to truncate data to
        self.numBits = a_numBits
        # Desired center frequency
        self.freq = a_freq
        # Type of generated signal
        self.type = a_type

        self.data = np.zeros(a_length)
        self.dataTruncBits = []

        self.fftData = np.zeros(a_length)
        self.fftDataTrunc = np.zeros(a_length)

        self._generateData(a_type)

        if args.type not in (
            "sin",
            "square",
            "sinc",
            "multi",
            "chirp",
            "am",
            "fm",
            "pink",
        ):
            raise ValueError(f"Type {args.type} not in allowed types!")

    def _generateData(self, a_type: str):
        tEnd = self.length * (1 / self.fs)
        time = np.arange(0, tEnd, 1 / self.fs)
        omega = 2 * np.pi * self.freq
        if a_type == "sin":
            self.data = np.sin(omega * time)
        elif a_type == "square":
            self.data = signal.square(omega * time)
        elif a_type == "sinc":
            self.data = np.sinc(self.freq * (time - tEnd / 2))
        elif a_type == "multi":
            freqs = [
                np.random.randint(low=1e3, high=45e3)
                for _ in range(np.random.randint(25))
            ]
            ampls = [np.random.uniform(low=0, high=1) for _ in range(len(freqs))]
            phases = np.random.rand(len(freqs)) * 2 * np.pi
            composite = np.zeros_like(time)
            for f, A, phi in zip(freqs, ampls, phases):
                composite += A * np.sin(2 * np.pi * f * time + phi)
            self.data = composite / max(abs(composite))
        elif a_type == "chirp":
            # Bandwidth is 50% of carrier frequency
            B = 0.5 * self.freq
            # Linear chirp formula: f(t) = f0 + (f1 - f0)*(t/T)
            freqChirp = self.freq + (B / 2) * time / time[-1]
            self.data = np.sin(2 * np.pi * freqChirp * time)
        elif a_type == "am":
            carrier = np.sin(2 * np.pi * self.freq * time)
            modulator = 0.5 * np.sin(2 * np.pi * 0.2 * self.freq * time)
            amSignal = carrier * (1 + modulator)
            self.data = amSignal / max(abs(amSignal))
        elif a_type == "fm":
            beta = 10
            phase = 2 * np.pi * self.freq * time + beta * np.sin(
                2 * np.pi * (0.1 * self.freq) * time
            )
            self.data = np.cos(phase)
        elif a_type == "pink":
            whiteNoise = np.random.randn(self.length)

            freqBins = np.fft.rfftfreq(n=self.length, d=1 / self.fs)
            freqData = np.fft.rfft(whiteNoise)
            # acquire pink noise by scaling with 1/sqrt(freq)
            freqData[0] = 0
            freqData[1:] = freqData[1:] / np.sqrt(freqBins[1:])
            # ifft
            pinkNoise = np.fft.irfft(freqData, self.length)
            self.data = pinkNoise / max(abs(pinkNoise))

        # Acquire FFT data with real FFT
        self.fftData = np.fft.rfft(self.data, n=self.length)

        # Center data
        # mid = 0.5 * (self.data.max() + self.data.min())
        # half_span = 0.5 * (self.data.max() - self.data.min())
        # self.data = (self.data - mid) / half_span  # now ∈ [−1, +1]
        # Truncate data
        # 1. Scale data to #numBits signed
        maxBitValue = 2.0 ** (self.numBits - 1) - 1
        dataTruncated = copy.deepcopy(self.data)
        dataTruncated = dataTruncated * maxBitValue
        # 2. Confine to [-max, +max]
        dataTruncated = np.clip(
            dataTruncated,
            -maxBitValue,
            maxBitValue,
        )
        # 3. Round values
        dataTruncated = np.floor(dataTruncated).astype(np.int64)
        # 4. Convert to numBits twos-complement
        self.dataTruncBits = []
        # acquires (numBits - 1) downto 0
        mask = (1 << self.numBits) - 1
        for val in dataTruncated:
            # Interpret val as an unsigned x‐bit integer:
            uVal = int(val & mask)
            # Format with leading zeros to exactly 'bits' length:
            binStr = format(uVal, f"0{self.numBits}b")
            self.dataTruncBits.append(binStr)

    def plotData(self, saveFig=False):
        tEnd = self.length * (1 / self.fs)
        time = np.arange(0, tEnd, 1 / self.fs)
        fig, axs = plt.subplots(2, 2)

        # Float64 generate data
        axs[0, 0].plot(time, self.data, marker=".")
        axs[0, 0].set_xlabel("Time [s]")
        axs[0, 0].set_ylabel("Amplitude")
        axs[0, 0].set_title(f"Plot: {self.type}")

        # rFFT of float64 generate data
        eps = 1e-12
        magnitude = np.maximum(np.abs(self.fftData), eps)
        magnitudeDB = 20 * np.log10(magnitude)
        xAxisFrequency = np.fft.rfftfreq(len(time), 1 / self.fs)
        axs[1, 0].plot(xAxisFrequency, magnitudeDB, "r")
        axs[1, 0].set_xlabel("Frequency [Hz]")
        axs[1, 0].set_ylabel("Magnitude [dB]")
        axs[1, 0].set_title(f"FFT")
        axs[1, 0].set_ylim([magnitudeDB.max() - 50, magnitudeDB.max() + 5])
        axs[1, 0].grid(True)

        # x-bit truncated data
        # parse x-bit signed into ints
        dataTruncInts = []
        for signedBin in self.dataTruncBits:
            dataTruncInts.append(BitArray(bin=signedBin).int)
        axs[0, 1].plot(time, dataTruncInts, marker=".")
        axs[0, 1].set_xlabel("Time [s]")
        axs[0, 1].set_title(f"Plot: {self.type} {self.numBits}-bits")

        #  rFFT of ints from x-bit signed data
        self.fftDataTrunc = np.fft.rfft(dataTruncInts, n=len(dataTruncInts))
        magnitude = np.maximum(np.abs(self.fftDataTrunc), eps)
        magnitudeDB = 20 * np.log10(magnitude)
        axs[1, 1].plot(xAxisFrequency, magnitudeDB, "green")
        axs[1, 1].set_xlabel("Frequency [Hz]")
        axs[1, 1].set_title(f"FFT")
        axs[1, 1].set_ylim([magnitudeDB.max() - 50, magnitudeDB.max() + 5])
        axs[1, 1].grid(True)

        if saveFig:
            plt.savefig(
                str(Path("data"))
                + "/"
                + f"{self.type}_{int(self.freq/1000)}khz_{self.numBits}bits.png",
                bbox_inches="tight",
            )
        plt.show()

    def writeToFile(self):
        outputPath = (
            str(Path("data"))
            + "/"
            + f"{self.type}_{int(self.freq/1000)}khz_{self.numBits}bits.txt"
        )
        file = open(outputPath, "w")
        for data in self.dataTruncBits:
            file.write(f"{data}\n")
        file.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--type", type=str, required=True)
    parser.add_argument("--bits", type=int, required=False, default=16)
    parser.add_argument("--store", action="store_true")
    args = parser.parse_args()

    obj = generateData(
        a_freq=15e3, a_length=1024, a_numBits=args.bits, a_type=args.type
    )
    if args.store:
        obj.writeToFile()
    obj.plotData(saveFig=args.store)
