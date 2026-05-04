from fileinput import filename
import math
from matplotlib import pyplot as plt
import numpy as np


class dds:
    def __init__(
        self,
        a_amp_width,
        a_data_width,
        a_lut_addr_width,
        a_accumulator_width,
        a_clk_freq,
    ):
        self.lut_addr_width = a_lut_addr_width
        self.amp_width = a_amp_width
        self.data_width = a_data_width
        self.clk_freq = a_clk_freq
        self.accumulator_width = a_accumulator_width
        self.tuning_word = 0
        self.phase_accumulator = 0
        self.sine_lut = [0] * (2**a_lut_addr_width)
        self.sign_bit = 1 << (a_data_width - 1)

        # Create LUT (only need to store one quadrant)
        max_period = math.pi / 2
        for i in range(len(self.sine_lut)):
            self.sine_lut[i] = int(
                (math.sin(max_period * i / (2**self.lut_addr_width)))
                * (2 ** (self.data_width - 1) - 1)
            )

    def dump_to_text(self, a_output_dir):
        from pathlib import Path

        mask = (1 << self.data_width) - 1

        filename = Path(a_output_dir) / "dds_lut.txt"
        filename.parent.mkdir(exist_ok=True, parents=True)
        with open(filename, "w") as f:
            for value in self.sine_lut:
                f.write(
                    format(mask & int(round(float(value))), f"0{self.data_width}b")
                    + "\n"
                )

    def configure(self, a_freq, a_amp=1.0):
        # Match VHDL fixed-point: tuning_word = freq * round(2^(ACC+FRAC) / CLK) >> FRAC
        _frac_width = 14
        _tuning_factor = round(
            (2**self.accumulator_width) * (2**_frac_width) / self.clk_freq
        )
        self.tuning_word = (int(a_freq) * _tuning_factor) >> _frac_width
        self.amp = a_amp

    def _compute_sine(self, phase):
        lut_index = (phase >> (self.accumulator_width - 2 - self.lut_addr_width)) & (
            (1 << self.lut_addr_width) - 1
        )

        quadrant = phase >> (self.accumulator_width - 2)

        # f_lut_idx_map: Q0,Q2 → use index; Q1,Q3 → flip index
        if quadrant == 1 or quadrant == 3:
            lut_index = (2**self.lut_addr_width - 1) - lut_index

        # f_lut_data_map: Q0,Q1 → positive; Q2,Q3 → negative
        if quadrant == 2 or quadrant == 3:
            return -self.sine_lut[lut_index]
        return self.sine_lut[lut_index]

    def tick(self):
        # 1. Update the phase accumulator
        self.phase_accumulator = (self.phase_accumulator + self.tuning_word) % (
            2**self.accumulator_width
        )

        # 2. Compute I and Q — Q is shifted 90° (2^(accumulator_width-2)) ahead
        i_value = self._compute_sine(self.phase_accumulator)
        phase_q = (self.phase_accumulator - (1 << (self.accumulator_width - 2))) % (
            2**self.accumulator_width
        )
        q_value = self._compute_sine(phase_q)

        return i_value, q_value


if __name__ == "__main__":
    # ===========================
    # PARAMETERS
    AMP_WIDTH = 16
    DATA_WIDTH = 12
    LUT_ADDR_WIDTH = 10
    ACCUMULATOR_WIDTH = 32
    CLK_FREQ = 100.0e6  # 100 MHz
    OUTPUT_FREQ = 350.0e3  # 1 kHz
    OUTPUT_AMP = 0.5
    clk_ticks = CLK_FREQ / OUTPUT_FREQ
    # ===========================
    # Create DDS instance
    dds_instance = dds(
        a_amp_width=AMP_WIDTH,
        a_data_width=DATA_WIDTH,
        a_lut_addr_width=LUT_ADDR_WIDTH,
        a_accumulator_width=ACCUMULATOR_WIDTH,
        a_clk_freq=CLK_FREQ,
    )
    dds_instance.dump_to_text(
        "/mnt/tools/projects/fpga/audio-spectrum-analyzer/src/signal_generator"
    )
    # Configure DDS for a specific frequency and amplitude
    dds_instance.configure(a_freq=OUTPUT_FREQ)
    # Simulate for a certain number of clock cycles
    output_i = list()
    output_q = list()
    for cycle in range(int(clk_ticks)):
        i, q = dds_instance.tick()
        output_i.append(i)
        output_q.append(q)
    # Plot the output waveform
    fig = plt.figure()
    # ------------------------------------------
    ax1 = fig.add_subplot(211)
    ax1.plot(output_i, label="I")
    ax1.plot(output_q, label="Q")
    ax1.legend()
    ax1.grid(True)
    ax1.set_title("DDS Output Waveform (IQ)")
    ax1.set_xlabel("Clock Cycles")
    ax1.set_ylabel("Amplitude")
    # ------------------------------------------
    # Plot the frequency spectrum of the complex IQ signal
    ax2 = fig.add_subplot(212)
    iq = np.array(output_i, dtype=float) + 1j * np.array(output_q, dtype=float)
    x_axis_freq = np.fft.fftfreq(len(iq), 1 / CLK_FREQ)
    fft_input = np.fft.fft(iq)
    magnitude = np.maximum(np.abs(fft_input), 1e-12)
    magnitude /= np.max(magnitude)
    magnitudeDB = 20 * np.log10(magnitude)
    ax2.plot(np.fft.fftshift(x_axis_freq), np.fft.fftshift(magnitudeDB))
    ax2.set_ylim(-150, 10)
    ax2.grid(True)
    # Find max frequency component in input signal
    max_freq_index = np.argmax(magnitude)
    max_freq = x_axis_freq[max_freq_index]
    ax2.annotate(
        f"Input Frequency: {max_freq:.1f} Hz",
        xy=(max_freq, magnitudeDB[max_freq_index]),
        xytext=(max_freq, magnitudeDB[max_freq_index] + 10),
        arrowprops=dict(facecolor="black", shrink=0.05),
        fontsize=8,
    )
    plt.show()
