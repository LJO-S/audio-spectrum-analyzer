import numpy as np
from scipy.signal import firwin, freqz
from pathlib import Path
import shutil
import matplotlib.pyplot as plt
import math

# ==============================================================================
# Parameters
SAMPLING_FREQUENCY = 48800  # Hz
NUMBER_OF_TAPS = 101
Q_FORMAT = 15
FC_RESOLUTION = 1000  # Hz
# -- NUMBER_OF_BITS = 16 --
# ==============================================================================


def twos_complement(a_hexstr: str, a_bits: int) -> int:
    """Convert hexstr to signed n-bit number"""
    value = int(a_hexstr, a_bits)
    if value & (1 << (a_bits - 1)):
        # Negative
        value -= 1 << a_bits
    return value


class filter_coeff_gen:
    def __init__(self, a_fs: int, a_nTaps: int, a_qFormat: int) -> None:
        """
        Generates FIR coefficients using the window method. The coefficients
        are for LP and HP using a resolution of 1 kHz between (0,24000) Hz.

            Parameters:
                a_fs (int): sampling frequency of input data.
                a_nTaps (int): number of taps in FIR filter.
                a_qFormat (int): the number of fractional bits in a 16-bit number
            Returns:
                None
        """
        self.fs = a_fs
        self.nTaps = a_nTaps
        self.qFormat = a_qFormat

    def generateCoefficients(self, a_resolution: int):
        """
        Generate coefficients in .coe files between 0-(fs/2) with
        a resolution determined by a_resolution.

            Parameters:
                a_resolution [int]: resolution in Hz between filters
            Returns:
                None.

        """
        print("Calculating coefficients...")
        # Clear directory
        shutil.rmtree(Path("fir_filter_coefficients"))

        # For plotting
        cutoffs = []
        lp_float_coeffs = []
        hp_float_coeffs = []

        # Loop over cutoffs
        for fc in np.arange(1000, 24000, a_resolution):
            cutoffs.append(fc)
            # ===================================================================================
            # A Kaiser window is a tapering function that is multipled onto the ideal (sinc) impulse
            # response, to generate a FIR from an IIR. By varying beta (sometimes called alpha), we
            # effectively vary the width of the Kaiser main lobe and the attentuation of the sidelobes.
            # The 1st null is found at bin n=sqrt(1+b^2). Note how increasing beta, we increase the
            # mainlobe width (the 1st null before the sidelobe is moved away). This makes the IR
            # have a sharper transition. BUT! A higher beta causes lower stopband attenuation (seen
            # with increased sidelobe levels). Usually a beta of 5 can yield ~60 dB stopband attenuation!
            beta = 5.0
            # 1) Low-pass design using Kaiser window
            h_lp = firwin(
                numtaps=self.nTaps, cutoff=fc, fs=self.fs, window=("kaiser", beta)
            )
            # ===================================================================================
            # 2) High-pass design using spectral inversion of LP design
            #
            # First off, we have:
            #
            # h_hp[n] = delta[n-M] - h_lp[n],   where M=(N-1)/2
            #
            # This can be shown using Euler's formula, but multiplying by -1 is equal
            # to shifting the frequency spectrum around half the sampling rate, moving
            # the LP response into the HP response.

            # Flip the spectrum (1 kHz LPF becomes 23 kHz HPF)
            h_hp = ((-1) ** np.arange(self.nTaps)) * h_lp
            # ===================================================================================
            # 3) Quantize to signed 16-bit (Q1.15 = 1 int+15 frac bits)
            # A. Multiply by number of fraction bits
            # B. Clip to +- (2^15 - 1)
            # C. Truncate to 16-bits signed
            h_lp_s16 = np.round(h_lp * (1 << self.qFormat))
            h_lp_s16 = np.clip(h_lp_s16, -(1 << self.qFormat), (1 << self.qFormat) - 1)
            h_lp_s16 = h_lp_s16.astype(np.int16)

            h_hp_s16 = np.round(h_hp * (1 << self.qFormat))
            h_hp_s16 = np.clip(h_hp_s16, -(1 << self.qFormat), (1 << self.qFormat) - 1)
            h_hp_s16 = h_hp_s16.astype(np.int16)
            # ===================================================================================
            # 4) Save coefficients for later plotting
            lp_float_coeffs.append(h_lp)
            hp_float_coeffs.append(h_hp)

            # 5) Write coefficients to .coe files
            for name, coeffs in [("lp", h_lp_s16), ("hp", h_hp_s16)]:
                h_u16 = coeffs.astype(np.uint16)
                self.writeToFile_coe(a_type=name, a_freq=fc, a_coeffs=h_u16)
            # END-OF-LOOP
        print("-- Succesfully dumped all coefficients to .coe files! --")
        # ===================================================================================
        # 6) Save .pngs of frequency responses

        # Reverse list due to LP fc <---> HP fc=24k-fc
        hp_float_coeffs = hp_float_coeffs[::-1]

        self.writeToFile_png(
            a_lp_f_coeffs=lp_float_coeffs,
            a_hp_f_coeffs=hp_float_coeffs,
            a_cutoffs=cutoffs,
        )
        print("-- Succesfully dumped visualization of response to .png files! --")

    def writeToFile_coe(self, a_type: str, a_freq: int, a_coeffs: list) -> None:
        """
        Dump truncated filter coefficients to .coe file.

            Parameters:
                a_type [str]: "lp" or "hp"
                a_freq [int]: cutoff frequency
                a_coeffs [list]: arrays of filter coefficients (uint16)
            Returns:
                None
        """
        print("Dumping to .coe...")
        frequency = a_freq
        if a_type == "hp":
            frequency = 24000 - a_freq
        outputPath = Path(
            "fir_filter_coefficients"
            + "/"
            + f"{a_type}"
            + "/"
            + f"{a_type}_{int(frequency)}hz.coe"
        )
        outputPath.parent.mkdir(exist_ok=True, parents=True)
        with open(outputPath, "w") as file:
            file.write("\n".join(f"{(c & 0xFFFF):04X}" for c in a_coeffs))

    def writeToFile_png(
        self, a_lp_f_coeffs: list, a_hp_f_coeffs: list, a_cutoffs: list
    ) -> None:
        """
        Visualize frequency response and coefficients plot using both original float
        coefficients and truncated coefficients read from generated .coe files.
        Dumped to .png files.

            Parameters:
                a_lp_f_coeffs [list]: list containing {NUMBER_OF_TAPS} number of arrays of LP coefficients (float64)
                a_hp_f_coeffs [list]: list containing {NUMBER_OF_TAPS} number of arrays of HP coefficients (float64)
                a_cutoffs [list]: list of cutoff frequencies used in generating filter coefficients
            Returns:
                None
        """

        print("Dumping to .png...")
        # freq. response resolution
        worN = 8192

        nPlots = len(a_cutoffs)
        nCols = 6
        nRows = math.ceil(nPlots / nCols)

        if nRows * nCols < nPlots:
            raise ValueError("Grid too small for number of cutoffs!")

        def _make_fig_axes():
            fig, axs = plt.subplots(nRows, nCols, figsize=(4 * nCols, 3 * nRows))
            # ensure axs is array
            axs = np.asarray(axs)
            return fig, axs

        def _quantized_to_float(a_coefficients):
            h_s16_to_f64 = [
                np.float64(twos_complement(coeff, 16)) / (1 << self.qFormat)
                for coeff in a_coefficients
            ]
            return h_s16_to_f64

        for plot_type in ("fresp_plot", "coeff_plot"):
            for filter_type in ("lp", "hp"):
                fig, axs = _make_fig_axes()

                # Frequency responses
                for i, fc in enumerate(a_cutoffs):
                    row = i // nCols
                    col = i % nCols
                    ax = axs[row, col]

                    if plot_type == "fresp_plot":
                        if filter_type == "lp":
                            w, Hf = freqz(
                                a_lp_f_coeffs[i], worN=worN, fs=SAMPLING_FREQUENCY
                            )
                        else:
                            w, Hf = freqz(
                                a_hp_f_coeffs[i], worN=worN, fs=SAMPLING_FREQUENCY
                            )
                        coeffs_quantized = _quantized_to_float(
                            self.readFromFile_coe(filter_type, fc)
                        )
                        _, Ht = freqz(
                            coeffs_quantized, worN=worN, fs=SAMPLING_FREQUENCY
                        )

                        # Constrain magnitude calc to not blow up if H=0
                        floatMag = 20 * np.log10(np.maximum(np.abs(Hf), 1e-12))
                        truncMag = 20 * np.log10(np.maximum(np.abs(Ht), 1e-12))

                        ax.plot(w, floatMag, label=f"float")
                        ax.plot(w, truncMag, label=f"trunc", linestyle="--")
                        ax.axvline(fc, color="blue", linestyle=":", linewidth=0.8)
                        ax.set_xlim(0, SAMPLING_FREQUENCY / 2)
                        ax.set_ylim(-120, 5)
                        ax.grid(True)
                        ax.set_title(f"{fc} Hz")
                        if col == 0:
                            ax.set_ylabel("Magnitude (dB)")
                        if row == nRows - 1:
                            ax.set_xlabel("Frequency (Hz)")
                        if i == 0:
                            ax.legend(loc="lower left", fontsize="small")
                    else:
                        if filter_type == "lp":
                            coeffs_float = a_lp_f_coeffs[i]
                        else:
                            coeffs_float = a_hp_f_coeffs[i]
                        coeffs_quantized = _quantized_to_float(
                            self.readFromFile_coe(filter_type, fc)
                        )
                        x_taps = np.arange(NUMBER_OF_TAPS)
                        ax.plot(x_taps, coeffs_float, label=f"float")
                        ax.plot(
                            x_taps, coeffs_quantized, label=f"trunc", linestyle="--"
                        )
                        ax.grid(True)
                        ax.set_title(f"{fc} Hz")
                        if col == 0:
                            ax.set_ylabel("Amplitude (1)")
                        if row == nRows - 1:
                            ax.set_xlabel("Tap index (n)")
                        if i == 0:
                            ax.legend(loc="lower left", fontsize="small")

                # Turn off any unused plots
                for j in range(nPlots, nRows * nCols):
                    r = j // nCols
                    c = j % nCols
                    axs[r, c].axis("off")

                if plot_type == "fresp_plot":
                    fig.suptitle(
                        f"{filter_type.upper()}F frequency responses", fontsize=16
                    )
                    outputPath = (
                        Path(f"fir_filter_coefficients")
                        / f"{filter_type}"
                        / f"{filter_type}_frequency_responses.png"
                    )
                else:
                    fig.suptitle(f"{filter_type.upper()}F coefficients", fontsize=16)
                    outputPath = (
                        Path(f"fir_filter_coefficients")
                        / f"{filter_type}"
                        / f"{filter_type}_coefficients.png"
                    )
                fig.tight_layout(rect=[0, 0.03, 1, 0.95])

                # Save fig
                # ensure output dir exists

                outputPath.parent.mkdir(exist_ok=True, parents=True)
                plt.savefig(
                    str(outputPath),
                    bbox_inches="tight",
                    dpi=200,
                )
                plt.close(fig)

    def readFromFile_coe(self, a_type: str, a_fc: int) -> list:
        """
        Read coefficients from .coe file

            Parameters:
                a_type [str]: "lp" or "hp"
                a_fc [int]: cutoff frequency
            Returns:
                coefficients [list]: list of uint16 coefficients
        """

        # Fetch data from correct file
        file_name = (
            Path(f"fir_filter_coefficients")
            / f"{a_type}"
            / f"{a_type}_{int(a_fc)}hz.coe"
        )
        # Read all lines
        with open(str(file_name), "r") as coe_file:
            coefficients = [line.strip() for line in coe_file]
        return coefficients


if __name__ == "__main__":
    # Create instance
    filter_coeff_gen = filter_coeff_gen(
        a_fs=SAMPLING_FREQUENCY, a_nTaps=NUMBER_OF_TAPS, a_qFormat=Q_FORMAT
    )
    # Generate coefficients
    filter_coeff_gen.generateCoefficients(a_resolution=FC_RESOLUTION)
