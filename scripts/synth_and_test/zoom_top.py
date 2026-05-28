import numpy as np
from pathlib import Path
from bitstring import BitArray
import matplotlib.pyplot as plt

from scripts.synth_and_test.utils import format_as_bstring
from scripts.models.dds.dds import dds as DdsModel

# Effective testbench sample rate: 100 MHz system clock / 2 clocks per audio sample
# (mirrors the 1-valid + 1-idle pattern in tb_zoom_top.vhd)
_TB_CLK_HZ = 100_000_000
_TB_CLKS_PER_SAMPLE = 2
_TB_FS = _TB_CLK_HZ // _TB_CLKS_PER_SAMPLE  # 50 000 000 Hz


def _save_plot(output_i, output_q, decimation_factor, f_signal_hz, output_path):
    fs_out = _TB_FS / decimation_factor
    n = len(output_i)

    fig, axes = plt.subplots(2, 2, figsize=(18, 10))

    axes[0, 0].plot(output_i, label="I")
    axes[0, 0].plot(output_q, label="Q")
    axes[0, 0].set_title(f"VHDL output (time domain, /{decimation_factor})")
    axes[0, 0].legend()
    axes[0, 0].grid(True)

    freqs = np.fft.fftfreq(n, 1.0 / fs_out)
    sig = np.array(output_i) + 1j * np.array(output_q)
    mag_db = 20 * np.log10(np.maximum(np.abs(np.fft.fft(sig)), 1e-12))
    axes[0, 1].plot(np.fft.fftshift(freqs), np.fft.fftshift(mag_db))
    axes[0, 1].set_title(f"VHDL output spectrum (/{decimation_factor})")
    axes[0, 1].set_xlabel("Frequency (Hz)")
    axes[0, 1].grid(True)

    # Input reconstruction for reference
    axes[1, 0].set_title(f"Input tone: {f_signal_hz} Hz @ TB FS={_TB_FS/1e6:.0f} MHz")
    t = np.arange(min(n * decimation_factor, 512)) / _TB_FS
    axes[1, 0].plot(t * 1e3, np.cos(2 * np.pi * f_signal_hz * t), label="I (cos)")
    axes[1, 0].plot(t * 1e3, np.sin(2 * np.pi * f_signal_hz * t), label="Q (sin)")
    axes[1, 0].set_xlabel("Time (ms)")
    axes[1, 0].legend()
    axes[1, 0].grid(True)

    axes[1, 1].axis("off")
    axes[1, 1].text(
        0.5,
        0.5,
        f"Decimation: /{decimation_factor}\n"
        f"Input freq: {f_signal_hz} Hz\n"
        f"TB FS: {_TB_FS/1e6:.0f} MHz\n"
        f"Output FS: {fs_out/1e3:.1f} kHz\n"
        f"Output samples: {n}",
        ha="center",
        va="center",
        fontsize=12,
    )

    plt.tight_layout()
    fig.set_size_inches(18, 10)
    plt.savefig(str(Path(output_path) / "results.svg"), dpi=150)
    plt.close(fig)


class zoom_top_checker:
    """
    Checker for zoom_top_tb.

    The DDS mixer is configured with a *negative* frequency shift equal to
    -f_signal_hz so that the complex input tone at +f_signal_hz is
    frequency-shifted to DC (bin 0) before decimation.

    Pre-config:
      - Writes dds_lut.txt (used by zoom_top G_DDS_INIT_FILE).
      - Writes input_data.txt: complex I/Q tone at +f_signal_hz Hz
        (relative to the effective testbench sample rate _TB_FS).

    Post-check:
      - Verifies the FFT peak of the VHDL output is within 2 bins of DC.
      - Verifies output sample count is within 10 % of n_samples/decimation_factor.
    """

    def __init__(
        self,
        a_f_signal_hz: int,
        a_data_width: int = 16,
    ):
        self.f_signal_hz = a_f_signal_hz
        self.data_width = a_data_width

        # Only used to generate the sine LUT via dump_to_text(); a_clk_freq does not
        # affect LUT content (it is a pure quarter-sine table).
        self._dds = DdsModel(
            a_amp_width=a_data_width,
            a_data_width=a_data_width,
            a_lut_addr_width=10,
            a_accumulator_width=32,
            a_clk_freq=_TB_CLK_HZ,
        )

    def pre_config_wrapper(self, a_n_samples: int = 8192):
        def pre_config(output_path) -> bool:
            out = Path(output_path)
            out.mkdir(exist_ok=True, parents=True)

            # 1. Write DDS LUT (sine quarter-wave table for zoom_top's DDS)
            self._dds.dump_to_text(out)  # produces dds_lut.txt

            # 2. Write complex input tone at +f_signal_hz (relative to TB FS).
            #    The testbench sends G_MIXER_FREQUENCY_SHIFT = -f_signal_hz,
            #    so the DDS runs at -f and the product lands at DC.
            with open(out / "input_data.txt", "w") as f:
                for n in range(a_n_samples):
                    phase = 2.0 * np.pi * self.f_signal_hz * n / _TB_FS
                    i_val = np.cos(phase)
                    q_val = np.sin(phase)
                    i_fixed = int(i_val * (2 ** (self.data_width - 1) - 1))
                    q_fixed = int(q_val * (2 ** (self.data_width - 1) - 1))
                    f.write(
                        f"{format_as_bstring(i_fixed, self.data_width)} "
                        f"{format_as_bstring(q_fixed, self.data_width)}\n"
                    )
            return True

        return pre_config

    def post_check_wrapper(self, a_decimation_factor: int, a_n_samples: int = 8192):
        def post_check(output_path: str) -> bool:
            out = Path(output_path)
            output_i, output_q = [], []
            with open(out / "output_data.txt", "r") as fh:
                for line in fh:
                    parts = line.split()
                    output_i.append(
                        BitArray(bin=parts[0]).int / (2.0 ** (self.data_width - 1))
                    )
                    output_q.append(
                        BitArray(bin=parts[1]).int / (2.0 ** (self.data_width - 1))
                    )

            n = len(output_i)
            if n < 16:
                print(f"[zoom_top] Too few output samples: {n}")
                return False

            checker = True

            # --- Length check --------------------------------------------------
            expected_len = a_n_samples // a_decimation_factor
            tol = max(5, int(expected_len * 0.15))
            if abs(n - expected_len) > tol:
                print(
                    f"[zoom_top] Output length mismatch: "
                    f"expected ~{expected_len}, got {n}"
                )
                checker = False

            # --- Spectral peak check -------------------------------------------
            # After mixing the +f_signal tone with DDS at -f_signal, the output
            # should be a constant complex value (DC).  The FFT peak must be at
            # or very near bin 0.
            sig = np.array(output_i) + 1j * np.array(output_q)
            mag = np.abs(np.fft.fft(sig))
            # Only look at one half (signal is complex so full FFT is used, but
            # the DC alias wraps – check the first few positive bins and the last
            # few negative bins).
            peak_bin = int(np.argmax(mag))
            # Map to a ±n/2 range so negative-frequency aliases near DC are counted
            if peak_bin > n // 2:
                peak_bin = peak_bin - n
            peak_bin_abs = abs(peak_bin)

            if peak_bin_abs > 2:
                print(
                    f"[zoom_top] Spectral peak NOT near DC: "
                    f"bin {peak_bin} (|{peak_bin_abs}|), expected ≤ 2"
                )
                checker = False
            else:
                print(
                    f"[zoom_top] Spectral peak near DC: "
                    f"bin {peak_bin} (|{peak_bin_abs}|) OK"
                )

            _save_plot(
                output_i,
                output_q,
                a_decimation_factor,
                self.f_signal_hz,
                output_path,
            )
            return checker

        return post_check


if __name__ == "__main__":
    print("zoom_top checker")
