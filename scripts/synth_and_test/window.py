import numpy as np
from pathlib import Path
from bitstring import BitArray
import matplotlib.pyplot as plt

from scripts.synth_and_test.utils import (
    format_as_bstring,
    compare_value,
)
from ..models.window.window import Window


def save_postcheck_plot_window(
    a_input_data: list,
    a_output_data: list,
    a_reference_data: list,
    a_window_length: int,
    a_sampling_freq: float,
    a_save_plot: bool,
    a_output_path: str,
):
    # Input data
    fig = plt.figure()
    ax1 = fig.add_subplot(221)
    ax1.plot(a_input_data[0], label="input I")
    ax1.plot(a_input_data[1], label="input Q")
    ax1.legend(loc="lower right")
    ax1.set_title(f"Input Data")
    ax1.grid(True)
    # Output & reference data
    ax2 = fig.add_subplot(223)
    ax2.plot(a_reference_data[0], label="reference I")
    # ax2.plot(a_reference_data[1], label="reference Q")
    ax2.plot(a_output_data[0], label="output I")
    # ax2.plot(a_output_data[1], label="output Q")
    ax2.legend(loc="lower right")
    ax2.set_title(f"Output Data")
    ax2.grid(True)
    # FFT Input
    ax3 = fig.add_subplot(222)
    # Fetch first a_window_length samples for FFT
    input_data = a_input_data[0][:a_window_length] + 1j * np.array(
        a_input_data[1][:a_window_length]
    )
    # Perform FFT
    fft_result = np.fft.fft(input_data)
    x_axis_freq = np.fft.fftfreq(len(input_data), 1 / a_sampling_freq)
    magnitude = np.maximum(np.abs(fft_result), 1e-12)
    magnitude /= np.max(magnitude)
    magnitudeDB = 20 * np.log10(magnitude)
    ax3.plot(np.fft.fftshift(x_axis_freq), np.fft.fftshift(magnitudeDB))
    ax3.set_ylim(-150, 10)
    ax3.legend(loc="lower right")
    ax3.grid(True)
    ax3.set_title(f"Input FFT")
    # FFT Output
    ax4 = fig.add_subplot(224)
    # Fetch first a_window_length samples for FFT
    output_data = a_output_data[0][:a_window_length] + 1j * np.array(
        a_output_data[1][:a_window_length]
    )
    reference_data = a_reference_data[0][:a_window_length] + 1j * np.array(
        a_reference_data[1][:a_window_length]
    )
    # Perform FFT
    fft_result_output = np.fft.fft(output_data)
    fft_result_reference = np.fft.fft(reference_data)
    x_axis_freq = np.fft.fftfreq(len(output_data), 1 / a_sampling_freq)
    magnitude_output = np.maximum(np.abs(fft_result_output), 1e-12)
    magnitude_output /= np.max(magnitude_output)
    magnitudeDB_output = 20 * np.log10(magnitude_output)
    ax4.plot(
        np.fft.fftshift(x_axis_freq),
        np.fft.fftshift(magnitudeDB_output),
        label="output",
    )
    magnitude_reference = np.maximum(np.abs(fft_result_reference), 1e-12)
    magnitude_reference /= np.max(magnitude_reference)
    magnitudeDB_reference = 20 * np.log10(magnitude_reference)
    ax4.plot(
        np.fft.fftshift(x_axis_freq),
        np.fft.fftshift(magnitudeDB_reference),
        label="reference",
    )
    ax4.set_ylim(-150, 10)
    ax4.grid(True)
    ax4.legend(loc="lower right")
    ax4.set_title(f"Output FFT")
    if a_save_plot:
        fig.set_size_inches(32, 18)
        plt.savefig(str(Path(a_output_path)) + "/" + f"results.svg", dpi=1000)
    else:
        plt.show()


class window_checker:
    def __init__(self, a_window_type, a_window_length, a_data_width, a_sampling_freq):
        self.data_width = a_data_width
        self.fs = a_sampling_freq
        self.window_object = Window(a_window_type, a_window_length, a_data_width)

    def pre_config_wrapper(self, a_input_samples: int):
        def pre_config(output_path) -> bool:

            # 1. Dump Window values to text
            self.window_object.dump_to_txt(a_output_dir=Path(output_path))

            # 2. Generate complex input data & Dump to text
            input_path: Path = Path(output_path) / "input_data.txt"
            input_path.parent.mkdir(exist_ok=True, parents=True)
            with open(input_path, "w") as f:
                for i in range(int(a_input_samples)):
                    # 1. Generate input data
                    input_data_i = np.cos(
                        2 * np.pi * (self.fs / 4.223212) * i / self.fs
                    )
                    input_data_q = np.sin(
                        2 * np.pi * (self.fs / 4.223212) * i / self.fs
                    )

                    # 2. Convert to signed fixed-point
                    input_fixed_i = int(input_data_i * (2 ** (self.data_width - 1)) - 1)
                    input_fixed_q = int(input_data_q * (2 ** (self.data_width - 1)) - 1)

                    # 3. Format as binary string
                    input_fixed_bstring_i = format_as_bstring(
                        a_val_fixed=input_fixed_i, a_data_width=self.data_width
                    )
                    input_fixed_bstring_q = format_as_bstring(
                        a_val_fixed=input_fixed_q, a_data_width=self.data_width
                    )

                    # 4. Write data
                    f.write(f"{input_fixed_bstring_i} {input_fixed_bstring_q}\n")
            return True

        return pre_config

    def post_check_wrapper(self):
        def post_check(output_path: str):

            checker = True

            # 0. Loop for data output entries:
            input_data_path: Path = Path(output_path) / "input_data.txt"
            output_data_path: Path = Path(output_path) / "output_data.txt"

            plt_input_i = list()
            plt_input_q = list()
            plt_output_i = list()
            plt_output_q = list()
            plt_reference_i = list()
            plt_reference_q = list()

            with open(output_data_path, "r") as f_out, open(
                input_data_path, "r"
            ) as f_in:
                for _, line in enumerate(f_out):
                    # 1. Fetch input
                    input_data = f_in.readline()
                    input_data_parts = input_data.split()
                    input_data_i = BitArray(bin=input_data_parts[0]).int / (
                        (2.0 ** (self.data_width - 1))
                    )
                    input_data_q = BitArray(bin=input_data_parts[1]).int / (
                        (2.0 ** (self.data_width - 1))
                    )
                    plt_input_i.append(input_data_i)
                    plt_input_q.append(input_data_q)

                    # 2. Fetch output i & q
                    output_data_i, output_data_q = line.split()
                    output_data_i_f = BitArray(bin=output_data_i).int / (
                        (2.0 ** (self.data_width - 1))
                    )
                    output_data_q_f = BitArray(bin=output_data_q).int / (
                        (2.0 ** (self.data_width - 1))
                    )

                    # 3. Generate new reference data
                    output_ref_i, output_ref_q = self.window_object.tick(
                        a_sample_i=input_data_i, a_sample_q=input_data_q
                    )

                    comparison_i = compare_value(
                        a_actual=output_data_i_f,
                        a_reference=output_ref_i,
                    )
                    comparison_q = compare_value(
                        a_actual=output_data_q_f,
                        a_reference=output_ref_q,
                    )
                    plt_output_i.append(output_data_i_f)
                    plt_output_q.append(output_data_q_f)
                    plt_reference_i.append(output_ref_i)
                    plt_reference_q.append(output_ref_q)

                    # 4. Compare to data output entry
                    print()
                    print("input=", input_data_i, "+j", input_data_q)
                    print()
                    print("output=", output_data_i_f, "+j", output_data_q_f)
                    print()
                    print(f"reference=", output_ref_i, "+j", output_ref_q)
                    print()
                    print("=====================================================")
                    checker = checker and comparison_i and comparison_q

            # Plot
            save_postcheck_plot_window(
                a_input_data=(plt_input_i, plt_input_q),
                a_output_data=(plt_output_i, plt_output_q),
                a_reference_data=(plt_reference_i, plt_reference_q),
                a_window_length=self.window_object.window_length,
                a_sampling_freq=self.fs,
                a_save_plot=True,
                a_output_path=output_path,
            )
            return checker

        return post_check


if __name__ == "__main__":
    print("Hello world!")
