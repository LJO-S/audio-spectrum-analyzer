import math
import numpy as np
import matplotlib.pyplot as plt



class Window:
    def __init__(self, a_window_type, a_window_length):
        self.window_type = a_window_type
        self.window_length = a_window_length
        self.window = [0] * self.window_length
        self.tick_index = 0

        if self.window_type == "hamming":
            for i in range(self.window_length):
                self.window[i] = 0.54 - 0.46 * math.cos(2 * math.pi * i / (self.window_length - 1))
        elif self.window_type == "hann":
            for i in range(self.window_length):
                self.window[i] = 0.5 * (1 - math.cos(2 * math.pi * i / (self.window_length - 1)))
        elif self.window_type == "blackman":
            for i in range(self.window_length):
                self.window[i] = 0.42 - 0.5 * math.cos(2 * math.pi * i / (self.window_length - 1)) + 0.08 * math.cos(4 * math.pi * i / (self.window_length - 1))
        else:
            raise ValueError("Unsupported window type: {}".format(self.window_type))
        

    def dump_to_txt(self, a_file_path, a_data_width):
        with open(a_file_path, "w") as f:
            for i in range(self.window_length):
                # Format as signed with a_data_width bits
                value = int(self.window[i] * (2 ** (a_data_width - 1)) - 1)
                f.write("{:d}\n".format(value))
                

    def tick(self, a_sample):
        ret = a_sample * self.window[self.tick_index]
        self.tick_index += 1
        if self.tick_index >= self.window_length:
            self.tick_index = 0
        return ret




if __name__ == "__main__":
    # Two-tone leakage demo: strong tone off-bin + weak tone 5 bins away.
    # With N=1024 and fs=44100, bin width ≈ 43 Hz.
    # Rectangular-window sidelobe at ~5 bins ≈ -24 dB — this swamps the -40 dB weak tone.
    # Good windows push sidelobes below -60 dB, revealing it.
    N = 1024
    SAMPLE_RATE = 44100
    FREQ_STRONG = 1000.0   # lands at bin 23.24 — deliberately off-bin to maximise leakage
    FREQ_WEAK   = 1215.0   # ~5 bins away from strong tone
    WEAK_DB     = -40      # amplitude ratio 0.01 relative to strong tone

    t = np.arange(N) / SAMPLE_RATE
    signal = np.sin(2 * np.pi * FREQ_STRONG * t) + 10 ** (WEAK_DB / 20) * np.sin(2 * np.pi * FREQ_WEAK * t)

    # Create window
    window_hamming = Window("hamming", N)
    window_hann = Window("hann", N)
    window_blackman = Window("blackman", N)

    # Apply window
    windowed_signal_hamming = [window_hamming.tick(sample) for sample in signal]
    windowed_signal_hann = [window_hann.tick(sample) for sample in signal]
    windowed_signal_blackman = [window_blackman.tick(sample) for sample in signal]

    # Plot
    # Creatue time 2x3 domain plot
    fig, axs = plt.subplots(2, 3, figsize=(15, 10))
    axs[0, 1].plot(t, signal)
    axs[0, 1].set_title("Original Signal")
    axs[1, 0].plot(t, windowed_signal_hamming)
    axs[1, 0].set_title("Hamming Windowed Signal")
    axs[1, 1].plot(t, windowed_signal_hann)
    axs[1, 1].set_title("Hann Windowed Signal")
    axs[1, 2].plot(t, windowed_signal_blackman)
    axs[1, 2].set_title("Blackman Windowed Signal")
    # axs[1, 0].axis("off")
    # axs[1, 1].axis("off")
    # axs[1, 2].axis("off")
    # Create frequency domain plot
    freqs = np.fft.rfftfreq(len(signal), 1 / SAMPLE_RATE)
    # Get dB values
    original_spectrum = 20 * np.log10(np.abs(np.fft.rfft(signal)))
    original_spectrum = original_spectrum - np.max(original_spectrum)
    hamming_spectrum = 20 * np.log10(np.abs(np.fft.rfft(windowed_signal_hamming)))
    hamming_spectrum = hamming_spectrum - np.max(hamming_spectrum)
    hann_spectrum = 20 * np.log10(np.abs(np.fft.rfft(windowed_signal_hann)))
    hann_spectrum = hann_spectrum - np.max(hann_spectrum)
    blackman_spectrum = 20 * np.log10(np.abs(np.fft.rfft(windowed_signal_blackman)))
    blackman_spectrum = blackman_spectrum - np.max(blackman_spectrum)
    PLOT_XLIM = (700, 1500)  # zoom in on the region of interest
    PLOT_YLIM = (-100, 5)

    fig2, axs2 = plt.subplots(2, 3, figsize=(15, 10))
    for ax, spectrum, title in [
        (axs2[0, 1], original_spectrum,  "No window (rectangular)"),
        (axs2[1, 0], hamming_spectrum,   "Hamming"),
        (axs2[1, 1], hann_spectrum,      "Hann"),
        (axs2[1, 2], blackman_spectrum,  "Blackman"),
    ]:
        ax.plot(freqs, spectrum)
        ax.set_title(title)
        # ax.set_xlim(PLOT_XLIM)
        # ax.set_ylim(PLOT_YLIM)
        ax.axhline(WEAK_DB, color="r", linestyle="--", linewidth=0.8, label=f"weak tone level ({WEAK_DB} dB)")
        ax.set_xlabel("Frequency (Hz)")
        ax.set_ylabel("dB")
    # Set grid
    for ax in axs.flat:
        ax.grid()
    for ax in axs2.flat:
        ax.grid()
    plt.tight_layout()
    plt.show()
    
    