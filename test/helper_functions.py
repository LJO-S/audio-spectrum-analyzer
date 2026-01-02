# ============================================================
# File which contains some helper functions for the run.py¨
# ============================================================

from vunit import VUnit
import numpy as np
from pathlib import Path
import matplotlib.pyplot as plt
import os
from os.path import join


def write_data(a_data: list, a_path: str) -> list:
    with open(file=a_path, mode="w+", encoding="UTF-8") as file:
        for elem in a_data:
            file.write(f"{elem}\n")


def read_data(a_path: str) -> list:
    with open(file=a_path, mode="r", encoding="UTF-8") as file:
        return [line.rstrip("\n") for line in file]


def to_signed_16(x):
    x &= 0xFFFF
    return (x - 0x10000) if (x & 0x8000) else x


class fir_data_checker:
    """
    Checks FIR output data from testbench
    """

    def __init__(self):
        self.Fs = 48828

    def do_fft(self, int16_list: list, window: np.ndarray, N: int):

        input_samples = int16_list[-N:]
        Y = np.fft.rfft(a=input_samples * window, n=N)
        freqBins = np.fft.rfftfreq(N, d=(1.0 / self.Fs))
        return freqBins, Y

    def get_signed(self, data: list):
        signed_ints = []
        for i, line in enumerate(data):
            try:
                unsigned_16b = int(line.replace(" ", ""), base=2)
                signed_ints.append(to_signed_16(unsigned_16b))
            except ValueError:
                print(f"Skipping invalid line {i}: {line}")
        return signed_ints

    def pre_config_wrapper(self, a_type: str) -> object:
        """
        This is a fun little trick I saw online on how to make pre_config
        accept more than the 'output_path' variable
        """

        def pre_config(output_path) -> bool:
            path_in = Path(os.getcwd()) / "filter" / "stimuli" / a_type
            input_data = read_data(path_in)
            write_data(input_data, join(output_path, "input_stimuli.txt"))
            return True

        return pre_config

    def post_check(self, output_path: str):
        def __get_ampl(fft_data, window):
            amplitude = (2.0 * np.abs(fft_data)) / np.sum(window)
            # correct DC
            amplitude[0] /= 2.0
            # correct Nyquist
            if len(fft_data) % 2 == 0:
                amplitude[-1] /= 2.0
            return 20.0 * np.log10(np.maximum(amplitude, 1e-12))

        # Fetch input/output data
        path_in = Path(output_path) / "input_stimuli.txt"
        input_data = read_data(path_in)

        path_out = Path(output_path) / "output_stimuli.txt"
        output_data = read_data(path_out)

        # Convert each sample to signed 16-bit
        signed_ints_in = self.get_signed(input_data)
        signed_ints_out = self.get_signed(output_data)

        # Acquire FFT data with real FFT
        N = 2048
        window = np.ones(N)

        # Normalize input/output
        signed_ints_in_norm = [
            float(elem) / max(signed_ints_in) for elem in signed_ints_in
        ]
        signed_ints_out_norm = [
            float(elem) / max(signed_ints_out) for elem in signed_ints_out
        ]

        # input
        freqBins, Y_in = self.do_fft(signed_ints_in_norm, window, N)

        # output
        _, Y_out = self.do_fft(signed_ints_out_norm, window, N)

        ampl_db_in = __get_ampl(Y_in, window)
        ampl_db_out = __get_ampl(Y_out, window)

        maxAmpl_idx_i = max(range(len(ampl_db_in)), key=ampl_db_in.__getitem__)
        maxFreq_in = maxAmpl_idx_i * (self.Fs / N)

        maxAmpl_idx_o = max(range(len(ampl_db_out)), key=ampl_db_out.__getitem__)
        maxFreq_out = maxAmpl_idx_o * (self.Fs / N)

        plt.subplot(2, 1, 1)
        plt.plot(signed_ints_in, label="input")
        plt.plot(signed_ints_out, color="orange", label="output")
        plt.ylim(-max(signed_ints_in), max(signed_ints_in))
        plt.title("Input/output samples")
        plt.legend(loc="upper right")
        plt.grid(True)

        plt.subplot(2, 1, 2)
        plt.plot(freqBins, ampl_db_in, label="input")
        plt.plot(freqBins, ampl_db_out, color="orange", label="output")
        plt.title("Output spectrum")
        plt.ylim(-125, 0)
        plt.annotate(
            f"fMax={maxFreq_in}",
            xy=(maxFreq_in, ampl_db_in[maxAmpl_idx_i]),
            xytext=(
                maxFreq_in + 0.1 * freqBins[-1],
                ampl_db_in[maxAmpl_idx_i] - 0.1 * max(ampl_db_in),
            ),
            arrowprops=dict(facecolor="red", shrink=0.05),
        )
        plt.annotate(
            f"fMax={maxFreq_out}",
            xy=(maxFreq_out, ampl_db_out[maxAmpl_idx_o]),
            xytext=(
                maxFreq_out + 0.1 * freqBins[-1],
                ampl_db_out[maxAmpl_idx_o] - 0.1 * max(ampl_db_out),
            ),
            arrowprops=dict(facecolor="red", shrink=0.05),
        )
        plt.title("Input/output spectrum")
        plt.legend(loc="lower right")
        plt.grid(True)

        plt.tight_layout()
        plt.show()

        return True
