import numpy as np
from pathlib import Path
from bitstring import BitArray
import matplotlib.pyplot as plt

from scripts.synth_and_test.utils import format_as_bstring
from ..models.zoom.decimation_bank.decimation_bank import Decimation_bank


def save_postcheck_plot_decimation(
    a_input_data_i: list,
    a_input_data_q: list,
    a_output_data_i: list,
    a_output_data_q: list,
    a_reference_data_i: list,
    a_reference_data_q: list,
    a_fs: float,
    a_decimation_factor: int,
    a_save_plot: bool,
    a_output_path: str,
):
    fs_out = a_fs / a_decimation_factor
    n = min(len(a_output_data_i), len(a_reference_data_i))

    fig, axes = plt.subplots(2, 2, figsize=(18, 10))

    # Time domain
    axes[0, 0].plot(a_input_data_i, label="I")
    axes[0, 0].plot(a_input_data_q, label="Q")
    axes[0, 0].set_title("Input (time domain)")
    axes[0, 0].legend()
    axes[0, 0].grid(True)

    axes[0, 1].plot(a_output_data_i[:n], label="VHDL I")
    axes[0, 1].plot(a_reference_data_i[:n], label="ref I", linestyle="--")
    axes[0, 1].plot(a_output_data_q[:n], label="VHDL Q")
    axes[0, 1].plot(a_reference_data_q[:n], label="ref Q", linestyle="--")
    axes[0, 1].set_title(f"Output IQ (/{a_decimation_factor})")
    axes[0, 1].legend()
    axes[0, 1].grid(True)

    # Spectra
    sig_in = np.array(a_input_data_i) + 1j * np.array(a_input_data_q)
    freqs_in = np.fft.fftfreq(len(sig_in), 1.0 / a_fs)
    mag_in_db = 20 * np.log10(np.maximum(np.abs(np.fft.fft(sig_in)), 1e-12))
    axes[1, 0].plot(np.fft.fftshift(freqs_in), np.fft.fftshift(mag_in_db))
    axes[1, 0].set_title("Input spectrum")
    axes[1, 0].set_xlabel("Frequency (Hz)")
    axes[1, 0].grid(True)

    freqs_out = np.fft.fftfreq(n, 1.0 / fs_out)
    sig_out = np.array(a_output_data_i[:n]) + 1j * np.array(a_output_data_q[:n])
    mag_out_db = 20 * np.log10(np.maximum(np.abs(np.fft.fft(sig_out)), 1e-12))
    sig_ref = np.array(a_reference_data_i[:n]) + 1j * np.array(a_reference_data_q[:n])
    mag_ref_db = 20 * np.log10(np.maximum(np.abs(np.fft.fft(sig_ref)), 1e-12))
    axes[1, 1].plot(
        np.fft.fftshift(freqs_out), np.fft.fftshift(mag_out_db), label="VHDL"
    )
    axes[1, 1].plot(
        np.fft.fftshift(freqs_out),
        np.fft.fftshift(mag_ref_db),
        label="Reference",
        linestyle="--",
    )
    axes[1, 1].set_title(f"VHDL output spectrum (/{a_decimation_factor})")
    axes[1, 1].set_xlabel("Frequency (Hz)")
    axes[1, 1].legend()
    axes[1, 1].grid(True)

    plt.tight_layout()
    if a_save_plot:
        fig.set_size_inches(32, 18)
        plt.savefig(str(Path(a_output_path) / "results.svg"), dpi=300)
    else:
        plt.show()
    plt.close(fig)


class decimation_checker:
    def __init__(
        self,
        a_fpass: float,
        a_atten_db: float,
        a_fs: int,
        a_data_width: int = 16,
    ):
        self.fpass = a_fpass
        self.atten_db = a_atten_db
        self.fs = a_fs
        self.data_width = a_data_width

    def pre_config_wrapper(self, a_n_samples: int = 4096):
        def pre_config(output_path) -> bool:
            # Tone well inside the passband so it survives all decimation factors
            f0 = self.fpass * 0.1
            input_path = Path(output_path) / "input_data.txt"
            input_path.parent.mkdir(exist_ok=True, parents=True)
            with open(input_path, "w") as f:
                for n in range(a_n_samples):
                    i_val = np.cos(2 * np.pi * f0 * n / self.fs)
                    q_val = np.sin(2 * np.pi * f0 * n / self.fs)
                    i_fixed = int(i_val * (2 ** (self.data_width - 1) - 1))
                    q_fixed = int(q_val * (2 ** (self.data_width - 1) - 1))
                    f.write(
                        f"{format_as_bstring(i_fixed, self.data_width)} "
                        f"{format_as_bstring(q_fixed, self.data_width)}\n"
                    )
            return True

        return pre_config

    def post_check_wrapper(self, a_decimation_factor: int):
        def post_check(output_path: str) -> bool:
            input_path = Path(output_path) / "input_data.txt"
            output_data_path = Path(output_path) / "output_data.txt"

            # Read VHDL output
            plt_output_i, plt_output_q = [], []
            with open(output_data_path, "r") as f_out:
                for line in f_out:
                    parts = line.split()
                    plt_output_i.append(
                        BitArray(bin=parts[0]).int / (2.0 ** (self.data_width - 1))
                    )
                    plt_output_q.append(
                        BitArray(bin=parts[1]).int / (2.0 ** (self.data_width - 1))
                    )

            # Read input and run reference model
            bank = Decimation_bank(
                a_atten_db=self.atten_db,
                a_fs=self.fs,
                a_data_width=self.data_width,
            )
            bank.configure(a_decimation_factor)

            plt_input_i, plt_input_q = [], []
            plt_reference_i, plt_reference_q = [], []
            with open(input_path, "r") as f_in:
                for line in f_in:
                    parts = line.split()
                    i_val = BitArray(bin=parts[0]).int / (2.0 ** (self.data_width - 1))
                    q_val = BitArray(bin=parts[1]).int / (2.0 ** (self.data_width - 1))
                    plt_input_i.append(i_val)
                    plt_input_q.append(q_val)
                    ref_i, ref_q = bank.tick(a_sample_i=i_val, a_sample_q=q_val)
                    if ref_i is not None:
                        plt_reference_i.append(ref_i)
                        plt_reference_q.append(ref_q)

            checker = True
            n = min(len(plt_output_i), len(plt_reference_i))

            if n < 16:
                print("Too few output samples for spectral comparison!")
                return False

            # Check output length is within 10% of expected (allow for pipeline flush)
            expected_len = len(plt_input_i) // a_decimation_factor
            actual_len = len(plt_output_i)
            tol = max(5, int(expected_len * 0.1))
            if abs(actual_len - expected_len) > tol:
                print(
                    f"Output length mismatch: expected {expected_len} vs actual {actual_len}"
                )
                checker = False

            # Spectral check: peak bin in VHDL output must match reference within ±1
            sig_out = np.array(plt_output_i[:n]) + 1j * np.array(plt_output_q[:n])
            sig_ref = np.array(plt_reference_i[:n]) + 1j * np.array(plt_reference_q[:n])
            peak_out = int(np.argmax(np.abs(np.fft.fft(sig_out)[: n // 2])))
            peak_ref = int(np.argmax(np.abs(np.fft.fft(sig_ref)[: n // 2])))

            if abs(peak_out - peak_ref) > 1:
                print(
                    f"Spectral peak mismatch: VHDL bin={peak_out}, ref bin={peak_ref}"
                )
                checker = False
            else:
                print(f"Spectral peak OK: VHDL bin={peak_out}, ref bin={peak_ref}")

            save_postcheck_plot_decimation(
                a_input_data_i=plt_input_i,
                a_input_data_q=plt_input_q,
                a_output_data_i=plt_output_i,
                a_output_data_q=plt_output_q,
                a_reference_data_i=plt_reference_i,
                a_reference_data_q=plt_reference_q,
                a_fs=float(self.fs),
                a_decimation_factor=a_decimation_factor,
                a_save_plot=True,
                a_output_path=output_path,
            )
            return checker

        return post_check


if __name__ == "__main__":
    print("Hello world!")
