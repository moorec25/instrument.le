import numpy as np
import matplotlib.pyplot as plt
import os
import librosa


def plot_magnitude_spectrum(signal, Fs, title, f_ratio=1):
    ft = np.fft.fft(signal)
    magnitude_spectrum = np.abs(ft)

    bins = np.linspace(0, Fs, len(magnitude_spectrum))
    nbins = int(len(bins) * f_ratio)

    plt.ioff()
    plt.plot(bins[:nbins], magnitude_spectrum[:nbins])
    plt.xlabel("Frequency (Hz)")
    plt.title(title)

    plt.savefig(title + ".png")


if __name__ == "__main__":

    BASE_DIR = "../../DSD100subset/Sources/Dev/055 - Angels In Amplifiers - I'm Alright/"
    vocals_file = "vocals.wav"
    drums_file = "drums.wav"
    bass_file = "bass.wav"
    other_file = "other.wav"

    vocals, Fs = librosa.load(os.path.join(BASE_DIR, vocals_file))
    drums, _ = librosa.load(os.path.join(BASE_DIR, drums_file))
    bass, _ = librosa.load(os.path.join(BASE_DIR, bass_file))
    other, _ = librosa.load(os.path.join(BASE_DIR, other_file))

    plot_magnitude_spectrum(vocals, Fs, "Vocals Magnitude Spectrum", 0.1)
