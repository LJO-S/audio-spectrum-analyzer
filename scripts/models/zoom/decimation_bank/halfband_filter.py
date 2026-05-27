import math
import numpy as np
from matplotlib import pyplot as plt
from collections import deque
from pathlib import Path
from scipy.signal import remez, freqz, firwin, kaiserord


def _calculate_nbr_of_taps(
    a_attenuation_db: float, a_fstop: float, a_fpass: float, a_fs: float
):
    """
    Calculate number of taps required for desired atten, fstop and fpass in a LPF.
    Uses Fred Harris "rule-of-thumb" formula
    """
    return int(math.ceil(a_fs * a_attenuation_db / (22 * abs(a_fstop - a_fpass))))


def __plot_response(a_w, a_h, a_atten_db, a_taps, a_title):
    """
    Utility function to plot response functions
    """
    fig = plt.figure()
    ax1 = fig.add_subplot(211)
    ax1.plot(a_w, 20 * np.log10(np.abs(a_h)))
    ax1.set_ylim(-a_atten_db, 5)
    ax1.grid(True)
    ax1.set_xlabel("Frequency (Hz)")
    ax1.set_ylabel("Gain (dB)")
    ax1.set_title(a_title)
    ax2 = fig.add_subplot(212)
    ax2.plot(a_taps)
    ax2.grid(True)
    ax2.set_xlabel("Coefficient Index")
    ax2.set_ylabel("N/A")
    ax2.set_title(f"{a_title} Coefficients")


def generate_coefficients_remez(
    a_attenuation_db: float,
    a_gain: float,
    a_fstop: list,
    a_fpass: list,
    a_fs: float,
    a_multirate_factor: int = None,
    a_plot: bool = True,
    a_halfband_en: bool = False,
):
    """
    Use SciPy's implementation of the Parks-McClellan algorithm. Works for LPF and HPF.

    Note: For very large transition bands, this algorithm will break down as the passband and stopband
    become so very tiny so there are not enough distinct frequency points to perform optimiziation. I found
    this out when using the halfband iterations... Works absolutely perfectly for your run-of-the-mill polyphase though!!
    """
    fpass_1 = a_fpass[0]
    fstop_1 = a_fstop[0]
    fpass_2 = 0
    fstop_2 = 0
    bpf_en = False
    if len(a_fstop) > 1:
        assert len(a_fstop) == 2, "No more than 2 stop frequences allowed!"
        assert len(a_fpass) == 2, "Expected 2 fpass since 2 fstop was specified!"
        bpf_en = True
        fpass_2 = a_fpass[1]
        fstop_2 = a_fstop[1]

    # Get maximum number of taps required
    nbr_of_taps_1 = _calculate_nbr_of_taps(
        a_attenuation_db=a_attenuation_db, a_fstop=fstop_1, a_fpass=fpass_1, a_fs=a_fs
    )
    nbr_of_taps = nbr_of_taps_1

    bands = list()
    if bpf_en:
        # BPF
        nbr_of_taps_2 = _calculate_nbr_of_taps(
            a_attenuation_db=a_attenuation_db,
            a_fstop=fstop_2,
            a_fpass=fpass_2,
            a_fs=a_fs,
        )
        nbr_of_taps = max(nbr_of_taps_1, nbr_of_taps_2)
        bands = [0, fstop_1, fpass_1, fpass_2, fstop_2, 0.5 * a_fs]
        gain = [0, a_gain, 0]
        title = "BPF"
    elif fstop_1 > fpass_1:
        # LPF
        bands = [0, fpass_1, fstop_1, 0.5 * a_fs]
        gain = [a_gain, 0]
        title = "LPF"
    else:
        # HPF
        bands = [0, fstop_1, fpass_1, 0.5 * a_fs]
        gain = [0, a_gain]
        title = "HPF"

    # Create odd number of taps
    if a_multirate_factor is None:
        if a_halfband_en:
            while (nbr_of_taps + 1) % 4 != 0:
                nbr_of_taps += 1
        else:
            if nbr_of_taps % 2 == 0:
                nbr_of_taps += 1
    else:
        if a_halfband_en:
            # If using multirate factor, keep existing logic but
            # ensure it doesn't violate the 4k-1 rule for half-bands
            while nbr_of_taps % a_multirate_factor != 0 or (nbr_of_taps + 1) % 4 != 0:
                print(a_multirate_factor, nbr_of_taps)
                nbr_of_taps += 1
        else:
            while nbr_of_taps % a_multirate_factor != 0:
                nbr_of_taps += 1

    # Remez Exchange algorithm (parks-mcclellan)
    taps = remez(
        numtaps=nbr_of_taps,
        bands=bands,
        desired=gain,
        fs=a_fs,
    )

    # Get coefficients
    w, h = freqz(taps, [1], worN=2000, fs=a_fs)
    __plot_response(
        a_w=w, a_h=h, a_atten_db=a_attenuation_db, a_taps=taps, a_title=title
    )
    if a_plot:
        print(
            f"=====================\nGenerated {title} with:\nN_taps={nbr_of_taps}\nBands_hz={bands}\nG={gain}\n=====================\n"
        )
        plt.show()
    return taps


def generate_coefficients_least_squares():
    """
    Use SciPy's implementation of the Least Squares method.
    """
    pass


def generate_coefficients_firwin(
    a_attenuation_db: float,
    a_gain: float,
    a_fstop: list,
    a_fpass: list,
    a_fs: float,
    a_multirate_factor: int = None,
    a_plot: bool = True,
    a_halfband_en: bool = False,
):
    """
    Use SciPy's implementation of the Window method.

    Note: Extremely robust for wide transition bands where Remez fails.
    """
    fpass_1 = a_fpass[0]
    fstop_1 = a_fstop[0]
    fpass_2 = 0
    fstop_2 = 0
    bpf_en = len(a_fstop) > 1
    if bpf_en:
        assert len(a_fstop) == 2, "No more than 2 stop frequences allowed!"
        assert len(a_fpass) == 2, "Expected 2 fpass since 2 fstop was specified!"
        fpass_2 = a_fpass[1]
        fstop_2 = a_fstop[1]

    # Get maximum number of taps required
    nbr_of_taps_1 = _calculate_nbr_of_taps(
        a_attenuation_db=a_attenuation_db, a_fstop=fstop_1, a_fpass=fpass_1, a_fs=a_fs
    )
    nbr_of_taps = nbr_of_taps_1

    bands = list()
    if bpf_en:
        # BPF
        nbr_of_taps_2 = _calculate_nbr_of_taps(
            a_attenuation_db=a_attenuation_db,
            a_fstop=fstop_2,
            a_fpass=fpass_2,
            a_fs=a_fs,
        )
        nbr_of_taps = max(nbr_of_taps_1, nbr_of_taps_2)
        cutoff = [(fpass_1 + fstop_1) / 2, (fpass2 + fstop_2) / 2]
        pass_zero = False
        title = "BPF (Window)"
    elif fstop_1 > fpass_1:
        # LPF
        cutoff = (fpass_1 + fstop_1) / 2
        pass_zero = True
        title = "LPF (Window)"
    else:
        # HPF
        cutoff = (fpass_1 + fstop_1) / 2
        pass_zero = False
        title = "HPF (Window)"

    nbr_of_taps, beta = kaiserord(a_attenuation_db, (fstop_1 - fpass_1) / (0.5 * a_fs))

    # Create odd number of taps
    if a_multirate_factor is None:
        if a_halfband_en:
            while (nbr_of_taps + 1) % 4 != 0:
                nbr_of_taps += 1
        else:
            if nbr_of_taps % 2 == 0:
                nbr_of_taps += 1
    else:
        if a_halfband_en:
            # If using multirate factor, keep existing logic but
            # ensure it doesn't violate the 4k-1 rule for half-bands
            while nbr_of_taps % a_multirate_factor != 0 or (nbr_of_taps + 1) % 4 != 0:
                nbr_of_taps += 1
        else:
            while nbr_of_taps % a_multirate_factor != 0:
                nbr_of_taps += 1

    # FIR Window algorithm (use 'hamming' by default)
    taps = firwin(
        numtaps=nbr_of_taps,
        cutoff=cutoff,
        window=("kaiser", beta),
        pass_zero=pass_zero,
        fs=a_fs,
        scale=False,
    )
    taps *= a_gain

    # Get coefficients
    w, h = freqz(taps, [1], worN=2000, fs=a_fs)
    __plot_response(
        a_w=w, a_h=h, a_atten_db=a_attenuation_db, a_taps=taps, a_title=title
    )
    if a_plot:
        print(
            f"=====================\nGenerated {title} with:\nN_taps={nbr_of_taps}\nBands_hz={bands}\nG={gain}\n=====================\n"
        )
        plt.show()
    return taps


class Halfband_filter:
    def __init__(
        self,
        a_fpass: float,
        a_fstop: float,
        a_gain: float,
        a_atten_db: float,
        a_fs: int,
        a_data_width: int = 16,
        a_plot_coeffs: bool = False,
    ):
        # Characteristics
        self.fpass = a_fpass
        self.fstop = a_fstop
        self.atten_db = a_atten_db
        self.fs = a_fs
        self.data_width = a_data_width

        # Generate filter coefficients
        try:
            self.taps_prototype = generate_coefficients_remez(
                a_attenuation_db=a_atten_db,
                a_gain=a_gain,
                a_fstop=[a_fstop],
                a_fpass=[a_fpass],
                a_fs=self.fs,
                a_multirate_factor=None,
                a_plot=a_plot_coeffs,
                a_halfband_en=True,
            )
            if np.isnan(self.taps_prototype).any():
                raise ValueError
        except:
            self.taps_prototype = generate_coefficients_firwin(
                a_attenuation_db=a_atten_db,
                a_gain=a_gain,
                a_fstop=[a_fstop],
                a_fpass=[a_fpass],
                a_fs=self.fs,
                a_multirate_factor=None,
                a_plot=a_plot_coeffs,
                a_halfband_en=True,
            )

        # Force 0s and 1s where close to
        self.taps_prototype[np.abs(self.taps_prototype) <= 2e-4] = 0.0
        self.taps_prototype[np.abs(self.taps_prototype) >= 0.999] = 1.0

        # The nbr of taps are odd, but the code below re-uses a interpolate-by-2 structure
        if len(self.taps_prototype) % 2 != 0:
            self.taps_prototype = np.append(self.taps_prototype, 0.0)

        # Generate Polyphase structure
        self.taps_polyphase = np.zeros((2, len(self.taps_prototype) // 2))
        for i, coeff in enumerate(self.taps_prototype):
            # Create polyphase matrix
            self.taps_polyphase[i % 2][i // 2] = coeff

        # Force 0.5 where close to 0.5 in the lower branch
        self.taps_polyphase[1][
            (self.taps_polyphase[1] >= 0.499) & (self.taps_polyphase[1] < 0.501)
        ] = 0.5

        self.shift_register = [
            deque([0.0] * self.taps_polyphase.shape[1]) for _ in range(2)
        ]
        self.input_data = list()

    def dump_to_txt(self, a_output_dir, a_order_idx):
        # Dump coefficients
        output_path = Path(a_output_dir) / f"HBF_{self.data_width}_{a_order_idx}.txt"
        output_path.parent.mkdir(exist_ok=True, parents=True)
        with open(output_path, "w") as f:
            for _, coeff in enumerate(self.taps_polyphase[0]):
                # 1. Convert to fixed-point
                fixed_point_val = int(round(coeff * (2.0 ** (self.data_width - 1))))

                if self.data_width <= 0:
                    raise ValueError(f"Invalid width: {self.data_width}")

                # 2. Format as binary string
                # produce two's-complement bit pattern of 'width' bits
                mask = (1 << self.data_width) - 1
                val_masked = mask & fixed_point_val
                coeff_bstring = format(val_masked, f"0{self.data_width}b")

                if len(coeff_bstring) != self.data_width:
                    raise ValueError(
                        "Binary string was longer than allowed depth! Actual=",
                        len(coeff_bstring),
                        "vs Expected=",
                        self.data_width,
                    )
                f.write(f"{coeff_bstring}\n")


class Halfband_interpolate_part:
    def __init__(
        self,
        a_fpass: float,
        a_fstop: float,
        a_atten_db: float,
        a_fs: int,
        a_data_width: int = 16,
    ):
        # Characteristics
        self.fpass = a_fpass
        self.fstop = a_fstop
        self.atten_db = a_atten_db
        self.fs = a_fs
        self.data_width = a_data_width

        self.filter_obj = Halfband_filter(
            a_fpass=a_fpass,
            a_fstop=a_fstop,
            a_gain=2.0,
            a_atten_db=a_atten_db,
            a_fs=a_fs,
        )

    def tick(self, a_new_sample):
        # Push new sample into delay line
        result = list()
        for phase in range(2):
            self.filter_obj.shift_register[phase].appendleft(a_new_sample)
            self.filter_obj.shift_register[phase].pop()
            result.append(
                np.dot(
                    self.filter_obj.taps_polyphase[phase],
                    self.filter_obj.shift_register[phase],
                )
            )
        return result

    def dump_to_txt(self, a_output_dir, a_order_idx):
        self.filter_obj.dump_to_txt(a_output_dir=a_output_dir, a_order_idx=a_order_idx)


class Halfband_decimate_part:
    def __init__(
        self,
        a_fpass: float,
        a_fstop: float,
        a_atten_db: float,
        a_fs: int,
        a_data_width: int = 16,
    ):
        # Characteristics
        self.fpass = a_fpass
        self.fstop = a_fstop
        self.atten_db = a_atten_db
        self.fs = a_fs
        self.data_width = a_data_width
        self.ddc_counter = 0

        self.filter_obj = Halfband_filter(
            a_fpass=a_fpass,
            a_fstop=a_fstop,
            a_gain=1.0,
            a_atten_db=a_atten_db,
            a_fs=a_fs,
        )
        self.input_register = deque([0.0] * self.filter_obj.taps_polyphase.shape[1])

    def tick(self, a_new_sample):
        # Push new sample into input delay line
        self.input_register.appendleft(a_new_sample)
        self.input_register.pop()
        # Compute output every M samples
        self.ddc_counter += 1
        if self.ddc_counter % 2 == 0:
            result = 0
            for phase in range(2):
                # Update the delay line of each sub-filter with its respective sample
                self.filter_obj.shift_register[phase].appendleft(
                    self.input_register[phase]
                )
                self.filter_obj.shift_register[phase].pop()
                # Accumulate the "Multiply-and-Accumulate"
                result += np.dot(
                    self.filter_obj.taps_polyphase[phase],
                    self.filter_obj.shift_register[phase],
                )
            # Increment decimate counter
            return result
        return None

    def dump_to_txt(self, a_output_dir, a_order_idx):
        self.filter_obj.dump_to_txt(a_output_dir=a_output_dir, a_order_idx=a_order_idx)


class Halfband_interpolate:
    def __init__(
        self,
        a_fpass: float,
        a_atten_db: float,
        a_fs: int,
        a_multirate_factor: int,
        a_data_width: int = 16,
    ):
        # Characteristics
        self.fpass = a_fpass
        self.atten_db = a_atten_db
        self.fs = a_fs
        self.multirate_factor = a_multirate_factor
        self.data_width = a_data_width

        assert a_multirate_factor % 2 == 0, f"L={a_multirate_factor} is NOT a pow-of-2"

        self.interpolate_chain = list()

        fs_new = a_fs
        for i in range(int(np.ceil(np.log2(a_multirate_factor)))):
            delta = (
                fs_new / 2 - a_fpass
            ) * 2  # this might look complex but is actually pretty intuitive if you draw it
            fs_new *= 2
            fpass = fs_new / 4 - (delta / 2)
            fstop = fs_new / 4 + (delta / 2)
            # Append to the chain of interpolate-by-2
            self.interpolate_chain.append(
                Halfband_interpolate_part(
                    a_fpass=fpass,
                    a_fstop=fstop,
                    a_atten_db=a_atten_db,
                    a_fs=fs_new,
                    a_data_width=a_data_width,
                )
            )

    def tick(self, a_new_sample):
        # Depth of chain
        num_stages = int(np.ceil(np.log2(self.multirate_factor)))
        result = [[] for _ in range(num_stages)]

        # Stage 0: first interpolation
        result[0] = self.interpolate_chain[0].tick(a_new_sample=a_new_sample)

        # Stages 1 to N: chained interpolation
        for l_idx in range(1, num_stages):
            prev_stage_samples = result[l_idx - 1]
            curr_stage_output = [0.0] * (len(prev_stage_samples) * 2)
            for s_idx, s in enumerate(prev_stage_samples):
                curr_stage_output[2 * s_idx : 2 * s_idx + 2] = self.interpolate_chain[
                    l_idx
                ].tick(a_new_sample=s)
            result[l_idx] = curr_stage_output
        return result[-1]

    def dump_to_txt(self, a_output_dir: str):
        for i, interpolate_stage in enumerate(self.interpolate_chain):
            interpolate_stage.dump_to_txt(a_output_dir=a_output_dir, a_order_idx=i)

    def generate_vhdl_package(self, a_jinja_path: str, a_output_path: str):
        from jinja2 import Environment, FileSystemLoader

        # Fetch idx that 1.0 is located at in the lower branch of each stage, which corresponds to the number of leading zeros in the lower branch
        for stage in self.interpolate_chain:
            stage.lower_delay_index = np.where(
                stage.filter_obj.taps_polyphase[1] == 1.0
            )[0][0]

        env = Environment(loader=FileSystemLoader(a_jinja_path))
        template = env.get_template("halfband_interpolate_pkg.vhd.j2")
        rendered_code = template.render(stages=self.interpolate_chain)

        output_path = Path(a_output_path)
        output_path.parent.mkdir(exist_ok=True, parents=True)
        with open(output_path, "w") as f:
            f.write(rendered_code)


class Halfband_decimate:
    def __init__(
        self,
        a_fpass: float,
        a_atten_db: float,
        a_fs: int,
        a_multirate_factor: int,
        a_data_width: int = 16,
    ):
        # Characteristics
        self.fpass = a_fpass
        self.atten_db = a_atten_db
        self.fs = a_fs
        self.multirate_factor = a_multirate_factor
        self.data_width = a_data_width

        assert a_multirate_factor % 2 == 0, f"L={a_multirate_factor} is NOT a pow-of-2"

        self.decimate_chain = list()

        fs_new = a_fs
        fpass = a_fpass
        for i in range(int(np.ceil(np.log2(a_multirate_factor)))):
            # Centers the transition band around fs_new/4 (intuitive if you draw it out)
            # The width of the transition band is halved at each stage, which results in the stopband edge being at fs_new/2 - fpass
            fstop = fs_new / 2 - a_fpass
            if fstop <= fpass:
                raise ValueError(
                    f"Invalid filter design! Stopband edge is negative or equals fpass. fs={fs_new}, fstop={fstop}, fpass={fpass}"
                )
            # Append to the chain of decimate-by-2
            self.decimate_chain.append(
                Halfband_decimate_part(
                    a_fpass=a_fpass,
                    a_fstop=fstop,
                    a_atten_db=a_atten_db,
                    a_fs=fs_new,
                    a_data_width=a_data_width,
                )
            )
            fs_new /= 2

    def tick(self, a_new_sample):
        # Depth of chain
        num_stages = int(np.ceil(np.log2(self.multirate_factor)))
        result = [None for _ in range(num_stages)]

        # Stage 0: first interpolation
        result[0] = self.decimate_chain[0].tick(a_new_sample=a_new_sample)

        # Stages 1 to N: chained interpolation
        for m_idx in range(1, num_stages):
            prev_stage_samples = result[m_idx - 1]
            if prev_stage_samples is None:
                result[m_idx] = None
                continue
            curr_stage_output = self.decimate_chain[m_idx].tick(
                a_new_sample=prev_stage_samples
            )
            result[m_idx] = curr_stage_output
        return result[-1]

    def dump_to_txt(self, a_output_dir: str):
        for i, decimate_stage in enumerate(self.decimate_chain):
            decimate_stage.dump_to_txt(a_output_dir=a_output_dir, a_order_idx=i)

    def generate_vhdl_package(self, a_jinja_path: str, a_output_path: str):
        from jinja2 import Environment, FileSystemLoader

        # Fetch idx that 0.5 is located at in the lower branch of each stage, which corresponds to the number of leading zeros in the lower branch
        for stage in self.decimate_chain:
            stage.lower_delay_index = np.where(
                stage.filter_obj.taps_polyphase[1] == 0.5
            )[0][0]

        env = Environment(loader=FileSystemLoader(a_jinja_path))
        template = env.get_template("halfband_decimate_pkg.vhd.j2")
        rendered_code = template.render(stages=self.decimate_chain)

        output_path = Path(a_output_path)
        output_path.parent.mkdir(exist_ok=True, parents=True)
        with open(output_path, "w") as f:
            f.write(rendered_code)


if __name__ == "__main__":
    # ================================
    # TYPE
    INTERPOLATE = False
    # ================================
    # PARAMETERS
    FS = 468.8e3
    INPUT_FREQ = 0.01 * FS
    FPASS = INPUT_FREQ + 0.05 * FS
    ATTEN_DB = 60
    L = 16
    M = 8
    # ================================
    # A. Generate 1/10 FS sine
    N = 1024
    t = np.arange(N) * (1 / FS)
    input_data = np.sin(2 * np.pi * (INPUT_FREQ) * t)

    # B. Create Polyphase filter
    if INTERPOLATE:
        filter_obj = Halfband_interpolate(
            a_fpass=FPASS,
            a_atten_db=ATTEN_DB,
            a_fs=FS,
            a_multirate_factor=L,
        )
    else:
        filter_obj = Halfband_decimate(
            a_fpass=FPASS,
            a_atten_db=ATTEN_DB,
            a_fs=FS,
            a_multirate_factor=M,
        )

    result = list()
    for input in input_data:
        output = filter_obj.tick(a_new_sample=input)
        if INTERPOLATE:
            for res in output:
                result.append(res)
        else:
            if output is not None:
                result.append(output)
    fig = plt.figure()
    # ----------------------------------------------------------
    ax1 = fig.add_subplot(221)
    ax1.plot(input_data, marker="o")
    ax1.grid(True)
    # ----------------------------------------------------------
    ax2 = fig.add_subplot(223)
    ax2.plot(result, marker="o")
    ax2.grid(True)
    # ----------------------------------------------------------
    x_axis_freq = np.fft.rfftfreq(len(t), 1 / FS)
    fft_input = np.fft.rfft(input_data)
    magnitude = np.maximum(np.abs(fft_input), 1e-12)
    magnitudeDB = 20 * np.log10(magnitude)
    ax3 = fig.add_subplot(222)
    ax3.plot(x_axis_freq, magnitudeDB)
    ax3.set_ylim(-10, 100)
    ax3.grid(True)
    # ----------------------------------------------------------
    if INTERPOLATE:
        new_fs = FS * L
        t = np.arange(N * L) * (1 / new_fs)
    else:
        new_fs = FS / M
        t = np.arange(N // M) * (1 / new_fs)
    x_axis_freq = np.fft.rfftfreq(len(t), 1 / new_fs)
    fft_output = np.fft.rfft(result)
    magnitude = np.maximum(np.abs(fft_output), 1e-12)
    magnitudeDB = 20 * np.log10(magnitude)
    ax4 = fig.add_subplot(224)
    ax4.plot(x_axis_freq, magnitudeDB)
    ax4.set_ylim(-10, 100)
    ax4.grid(True)
    plt.show()
