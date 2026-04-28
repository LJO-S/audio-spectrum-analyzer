# ===================================================================
# Utilities
# ===================================================================
import math
import numpy as np
from matplotlib import pyplot as plt
from scipy.signal import freqz
from pathlib import Path


def generate_sine(a_frequency: float):
    pass


def format_as_bstring(a_val_fixed: int, a_data_width: int):

    if a_data_width <= 0:
        raise ValueError(f"Invalid width: {a_data_width}")

    # produce two's-complement bit pattern of 'width' bits
    mask = (1 << a_data_width) - 1
    val_masked = mask & a_val_fixed
    bstring = format(val_masked, f"0{a_data_width}b")

    if len(bstring) != a_data_width:
        raise ValueError(
            "Binary string was longer than allowed depth! Actual=",
            len(bstring),
            "vs Expected=",
            1 << a_data_width,
        )
    return bstring


def compare_value(a_actual, a_reference):
    if a_reference is not None:
        match = math.isclose(a=a_actual, b=a_reference, rel_tol=0.01, abs_tol=1e-3)
        diff_rel = abs(a_actual - a_reference) / (a_reference + 1e-9)
        if not match:
            print(
                f"Mismatch! Reference={a_reference} vs Actual={a_actual} <===> %diff={diff_rel}"
            )
            return False
        else:
            print(
                f"Pass!! Reference={a_reference} vs Actual={a_actual} <===> %diff={diff_rel}"
            )
    return True

def save_postcheck_plot(a_input_data: list, 
                        a_output_data: list, 
                        a_reference_data: list, 
                        a_sampling_freq: float,
                        a_multirate_factor: int,
                        a_atten_db: float,
                        a_taps_polyphase: list,
                        a_save_plot: bool,
                        a_output_path: str
                        ):
    # Input data
    fig = plt.figure()
    ax1 = fig.add_subplot(231)
    ax1.plot(a_input_data)
    ax1.grid(True)
    ax1.set_title(f"Input & Output data")
    # Output & reference data
    ax2 = fig.add_subplot(234)
    ax2.plot(a_output_data, label="out")
    ax2.plot(a_reference_data, label="ref")
    ax2.legend(loc="lower right")
    ax2.grid(True)
    # Input spectrum
    ax3 = fig.add_subplot(232)
    x_axis_freq = np.fft.rfftfreq(len(a_input_data), 1 / a_sampling_freq)
    fft_input = np.fft.rfft(a_input_data)
    magnitude = np.maximum(np.abs(fft_input), 1e-12)
    magnitudeDB = 20 * np.log10(magnitude)
    ax3.plot(x_axis_freq, magnitudeDB)
    ax3.set_ylim(-10, 100)
    ax3.grid(True)
    ax3.set_title(f"Input & Output spectrum")
    # Output spectrum
    ax4 = fig.add_subplot(235)
    x_axis_freq = np.fft.rfftfreq(len(a_output_data), 1 / (a_sampling_freq * a_multirate_factor))
    fft_output = np.fft.rfft(a_output_data)
    magnitude = np.maximum(np.abs(fft_output), 1e-12)
    magnitudeDB = 20 * np.log10(magnitude)
    ax4.plot(x_axis_freq, magnitudeDB)
    ax4.set_ylim(-10, 100)
    ax4.grid(True)
    # Coefficients
    ax5 = fig.add_subplot(233)
    w, h = freqz(a_taps_polyphase, [1], worN=2000, fs=(a_sampling_freq * a_multirate_factor))
    ax5.plot(w, 20 * np.log10(np.abs(h)))
    ax5.set_ylim(-a_atten_db, 5)
    ax5.grid(True)
    ax5.set_xlabel("Frequency (Hz)")
    ax5.set_ylabel("Gain (dB)")
    ax5.set_title(f"Coeff Freq Resp & Coeffs")
    ax6 = fig.add_subplot(236)
    ax6.plot(a_taps_polyphase)
    ax6.grid(True)
    ax6.set_xlabel("Coefficient Index")
    ax6.set_ylabel("N/A")
    if a_save_plot:
        fig.set_size_inches(32, 18)
        plt.savefig(
            str(Path(a_output_path))
            + "/"
            + f"results.svg",
            # bbox_inches="tight",
            dpi=1000
        )
    else:
        plt.show()

def save_postcheck_plot_halfband(a_input_data: list, 
                        a_output_data: list, 
                        a_reference_data: list, 
                        a_sampling_freq: float,
                        a_multirate_factor: float,
                        a_atten_db: float,
                        a_taps_halfband_list: list,
                        a_save_plot: bool,
                        a_output_path: str
                        ):
    # Figure out how many columns needed
    num_cols = len(a_taps_halfband_list) + 2  # +2 for input/output data and spectrum
    # Input data
    fig = plt.figure()
    ax1 = fig.add_subplot(2, num_cols, 1)
    ax1.plot(a_input_data)
    ax1.grid(True)
    ax1.set_title(f"Input & Output data")
    # Output & reference data
    ax2 = fig.add_subplot(2, num_cols, num_cols + 1)
    ax2.plot(a_output_data, label="out")
    ax2.plot(a_reference_data, label="ref")
    ax2.legend(loc="lower right")
    ax2.grid(True)
    # Input spectrum
    ax3 = fig.add_subplot(2, num_cols, 2)
    x_axis_freq = np.fft.rfftfreq(len(a_input_data), 1 / a_sampling_freq)
    fft_input = np.fft.rfft(a_input_data)
    magnitude = np.maximum(np.abs(fft_input), 1e-12)
    magnitudeDB = 20 * np.log10(magnitude)
    ax3.plot(x_axis_freq, magnitudeDB)
    ax3.set_ylim(-10, 100)
    ax3.grid(True)
    ax3.set_title(f"Input & Output spectrum")
    # Output spectrum
    ax4 = fig.add_subplot(2, num_cols, num_cols + 2)
    x_axis_freq = np.fft.rfftfreq(len(a_output_data), 1 / (a_sampling_freq * a_multirate_factor))
    fft_output = np.fft.rfft(a_output_data)
    magnitude = np.maximum(np.abs(fft_output), 1e-12)
    magnitudeDB = 20 * np.log10(magnitude)
    ax4.plot(x_axis_freq, magnitudeDB)
    ax4.set_ylim(-10, 100)
    ax4.grid(True)
    # Coefficients
    for i, coeff_set in enumerate(a_taps_halfband_list):
        print(coeff_set)
        ax = fig.add_subplot(2, num_cols, 3 + i)
        w, h = freqz(coeff_set, [1], worN=2000, fs=(a_sampling_freq * (2 ** (i+1))))
        ax.plot(w, 20 * np.log10(np.abs(h)))
        ax.set_ylim(-a_atten_db)
        ax.grid(True)
        ax.set_xlabel("Frequency (Hz)")
        ax.set_ylabel("Gain (dB)")
        ax.set_title(f"Coeff Freq Resp & Coeffs")
        ax = fig.add_subplot(2, num_cols, num_cols + 3 + i)
        ax.plot(coeff_set)
        ax.grid(True)
        ax.set_xlabel("Coefficient Index")
        ax.set_ylabel("N/A")
    if a_save_plot:
        fig.set_size_inches(32, 18)
        plt.savefig(
            str(Path(a_output_path))
            + "/"
            + f"results.svg",
            # bbox_inches="tight",
            dpi=1000
        )
    else:
        plt.show()

def save_postcheck_plot_cic(a_input_data: list,
                        a_output_data: list,
                        a_reference_data: list,
                        a_cic_object,
                        a_sampling_freq: float,
                        a_multirate_factor: float,
                        a_fpass: float,
                        a_atten_db: float,
                        a_save_plot: bool,
                        a_output_path: str
                        ):
    fig = plt.figure()
    # ----------------------------------------------------------
    # Input data
    ax1 = fig.add_subplot(2, 4, 1)
    ax1.plot(a_input_data)
    ax1.grid(True)
    ax1.set_title("Input & Output data")
    # Output & reference data
    ax2 = fig.add_subplot(2, 4, 5)
    ax2.plot(a_output_data, label="out")
    ax2.plot(a_reference_data, label="ref")
    ax2.legend(loc="lower right")
    ax2.grid(True)
    # ----------------------------------------------------------
    # Input spectrum
    ax3 = fig.add_subplot(2, 4, 2)
    x_axis_freq = np.fft.rfftfreq(len(a_input_data), 1 / a_sampling_freq)
    fft_input = np.fft.rfft(a_input_data)
    magnitude = np.maximum(np.abs(fft_input), 1e-12)
    magnitudeDB = 20 * np.log10(magnitude)
    ax3.plot(x_axis_freq, magnitudeDB)
    ax3.set_ylim(-10, 100)
    ax3.grid(True)
    ax3.set_title("Input & Output spectrum")
    # Output spectrum
    ax4 = fig.add_subplot(2, 4, 6)
    x_axis_freq = np.fft.rfftfreq(len(a_output_data), 1 / (a_sampling_freq * a_multirate_factor))
    fft_output = np.fft.rfft(a_output_data)
    magnitude = np.maximum(np.abs(fft_output), 1e-12)
    magnitudeDB = 20 * np.log10(magnitude)
    ax4.plot(x_axis_freq, magnitudeDB)
    ax4.set_ylim(-10, 100)
    ax4.grid(True)
    # ----------------------------------------------------------
    # Compensation FIR frequency response
    fs_low = a_sampling_freq * min(a_multirate_factor, 1.0)
    w, h = freqz(a_cic_object.compensation_filter.coefficients, worN=2048, fs=fs_low)
    ax5 = fig.add_subplot(2, 4, 3)
    ax5.plot(w, 20 * np.log10(np.abs(h)))
    ax5.set_title("Compensation FIR Response")
    ax5.set_xlabel("Frequency (Hz)")
    ax5.set_ylabel("Magnitude (dB)")
    ax5.grid(True)
    # Compensation FIR coefficients
    ax6 = fig.add_subplot(2, 4, 7)
    ax6.plot(a_cic_object.compensation_filter.coefficients, marker="o")
    ax6.set_title("Compensation FIR Coefficients")
    ax6.set_xlabel("Coefficient Index")
    ax6.set_ylabel("Coefficient Value")
    ax6.grid(True)
    # ----------------------------------------------------------
    # CIC frequency response
    n = np.linspace(-0.5, 0.5, 1000)
    n[n == 0] = 1e-12
    alias_freq_normalized = 1.0 / a_cic_object.R
    if a_multirate_factor > 1.0:
        # Interpolate
        fpass_normalized = a_fpass / (a_sampling_freq * a_multirate_factor)
    else:
        # Decimate or no rate change
        fpass_normalized = a_fpass / a_sampling_freq
    cic_response = np.abs(np.sin(n * np.pi * a_cic_object.D) / np.sin(n * np.pi)) ** a_cic_object.order
    cic_response_compare = cic_response / np.max(cic_response)
    alias_band = (n > (alias_freq_normalized - fpass_normalized)) & (n < alias_freq_normalized)
    min_val = np.min(20 * np.log10(cic_response_compare[alias_band]))
    ax7 = fig.add_subplot(2, 4, 4)
    ax7.plot(n, 20 * np.log10(cic_response_compare), label=f"CIC Order {a_cic_object.order}")
    for i in range(5):
        ax7.fill_between(n, min_val - 30, 20 * np.log10(cic_response_compare),
                         where=(n > alias_freq_normalized * i - fpass_normalized) & (n < alias_freq_normalized * i + fpass_normalized),
                         color='r', alpha=0.3, label="Aliasing Band" if i == 0 else None)
    ax7.fill_between(n, min_val - 30, 20 * np.log10(cic_response_compare),
                     where=(np.abs(n) < fpass_normalized), color='g', alpha=0.3, label="Passband")
    ax7.axhline(-a_atten_db, color='k', linestyle='--', label=f"-{a_atten_db} dB")
    ax7.set_xlabel("Normalized Frequency")
    ax7.set_ylabel("Magnitude (dB)")
    ax7.set_title("CIC Filter Response")
    ax7.set_ylim(min_val - 30, 5)
    ax7.legend()
    ax7.grid(True)
    # ----------------------------------------------------------
    if a_save_plot:
        fig.set_size_inches(32, 18)
        plt.savefig(
            str(Path(a_output_path)) + "/results.svg",
            dpi=1000
        )
    else:
        plt.show()