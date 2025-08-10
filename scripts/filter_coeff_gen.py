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


class filter_coeff_gen:
    def __init__(self, a_fs: int, a_nTaps: int, a_qFormat: int):
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

    def generateCoefficients(self, a_resolution):
        """
        Generate coefficients in .coe files between 0-(fs/2) with
        a resolution determined by a_resolution.

            Parameters:
                a_resolution (int): resolution in Hz between filters.
            Returns:
                None.

        """
        # Clear directory
        shutil.rmtree(Path("fir_filter_coefficients"))

        # For plotting
        cutoffs = []
        lp_float_resps = []
        lp_trunc_resps = []
        hp_float_resps = []
        hp_trunc_resps = []

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
            # 4) Save frequency response
            h_lp_trunc = h_lp_s16.astype(np.float64) / (1 << self.qFormat)
            h_hp_trunc = h_hp_s16.astype(np.float64) / (1 << self.qFormat)

            # freq. response resolution
            worN = 8192

            # freq response of LP float & trunc
            w_lp, freqResp_lp_float = freqz(h_lp, worN=worN, fs=SAMPLING_FREQUENCY)
            _, freqResp_lp_trunc = freqz(h_lp_trunc, worN=worN, fs=SAMPLING_FREQUENCY)

            # freq response of HP float & trunc
            w_hp, freqResp_hp_float = freqz(h_hp, worN=worN, fs=SAMPLING_FREQUENCY)
            _, freqResp_hp_trunc = freqz(h_hp_trunc, worN=worN, fs=SAMPLING_FREQUENCY)

            # Save response as tuple in list
            lp_float_resps.append((w_lp, freqResp_lp_float))
            lp_trunc_resps.append((w_lp, freqResp_lp_trunc))
            hp_float_resps.append((w_hp, freqResp_hp_float))
            hp_trunc_resps.append((w_hp, freqResp_hp_trunc))

            # 5) Write coefficients to .coe files
            for name, coeffs in [("lp", h_lp_s16), ("hp", h_hp_s16)]:
                h_u16 = coeffs.astype(np.uint16)
                self.writeToFile_coe(a_type=name, a_freq=fc, a_coeffs=h_u16)

            # END-OF-LOOP
        # ===================================================================================
        # 6) Save .pngs of frequency responses
        hp_float_resps = hp_float_resps[::-1]
        self.writeToFile_png(
            a_lp_f_fresp=lp_float_resps,
            a_lp_t_fresp=lp_trunc_resps,
            a_hp_f_fresp=hp_float_resps,
            a_hp_t_fresp=hp_trunc_resps,
            a_cutoffs=cutoffs,
        )

    def writeToFile_coe(self, a_type, a_freq, a_coeffs):
        frequency = a_freq
        if a_type == "hp":
            frequency = 24000 - a_freq
        outputPath = Path(
            "fir_filter_coefficients"
            + "/"
            + f"{a_type}"
            + "/"
            + f"{a_type}_{frequency}hz.coe"
        )
        outputPath.parent.mkdir(exist_ok=True, parents=True)
        with open(outputPath, "w") as file:
            file.write("\n".join(f"{(c & 0xFFFF):04X}" for c in a_coeffs))
        # print(f"Wrote {a_type}_{a_freq}hz.coe \n\r")

    def writeToFile_png(
        self, a_lp_f_fresp, a_hp_f_fresp, a_lp_t_fresp, a_hp_t_fresp, a_cutoffs
    ):
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

        for filter_type in ("lp", "hp"):
            fig, axs = _make_fig_axes()

            for i, fc in enumerate(a_cutoffs):
                row = i // nCols
                col = i % nCols
                ax = axs[row, col]

                if filter_type == "lp":
                    w, Hf = a_lp_f_fresp[i]
                    _, Ht = a_lp_t_fresp[i]
                else:
                    w, Hf = a_hp_f_fresp[i]
                    _, Ht = a_hp_t_fresp[i]

                # Constrain magnitude calc to not blow up if H=0
                floatMag = 20 * np.log10(np.maximum(np.abs(Hf), 1e-12))
                truncMag = 20 * np.log10(np.maximum(np.abs(Ht), 1e-12))

                ax.plot(w, floatMag, label=f"float")
                ax.plot(w, truncMag, label=f"trunc", linestyle="--")
                ax.axvline(fc, color="k", linestyle=":", linewidth=0.8)
                ax.set_xlim(0, SAMPLING_FREQUENCY / 2)
                ax.set_ylim(-120, 5)
                ax.grid(True)
                ax.set_title(f"{fc} Hz")
                if col == 0:
                    ax.set_xlabel("Frequency (Hz)")
                if row == nRows - 1:
                    ax.set_ylabel("Magnitude (dB)")
                if i == 0:
                    ax.legend(loc="lower left", fontsize="small")

            # Turn off any unused plots
            for j in range(nPlots, nRows * nCols):
                print(j)
                r = j // nCols
                c = j % nCols
                axs[r, c].axis("off")

            fig.suptitle(f"{filter_type.upper()}F frequency responses", fontsize=16)
            fig.tight_layout(rect=[0, 0.03, 1, 0.95])

            # Save fig
            # ensure output dir exists
            outputDir = Path(f"fir_filter_coefficients")
            outputPath = (
                outputDir / f"{filter_type}" / f"{filter_type}_frequency_responses.png"
            )
            outputPath.parent.mkdir(exist_ok=True, parents=True)
            plt.savefig(
                str(outputPath),
                bbox_inches="tight",
                dpi=200,
            )
            plt.close(fig)

    def readFromFile_coe(self, a_inputPath):
        pass


if __name__ == "__main__":
    # Create instance
    filter_coeff_gen = filter_coeff_gen(
        a_fs=SAMPLING_FREQUENCY, a_nTaps=NUMBER_OF_TAPS, a_qFormat=Q_FORMAT
    )
    # Generate coefficients
    filter_coeff_gen.generateCoefficients(a_resolution=FC_RESOLUTION)
