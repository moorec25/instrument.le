import os
import librosa
import librosa.display
import numpy as np
from dsp import transforms


def custom_stft(audio, Fs, frame_size, hop_size):

    window = np.hanning(frame_size)

    audio = np.pad(audio, (int(frame_size / 2), 0))
    padded_audio = audio if audio.shape[0] % frame_size == 0 else \
        np.pad(audio, (0, frame_size - audio.shape[0] % frame_size), 'constant')

    n_bins = int(frame_size / 2 + 1)
    n_frames = int((padded_audio.shape[0] - frame_size) / hop_size + 1)

    output_stft = np.zeros((n_frames, n_bins), dtype=complex)

    for frame in range(n_frames):
        x = padded_audio[frame * hop_size:frame * hop_size + frame_size]
        win_frame = x * window
        output_stft[frame] = np.fft.fft(win_frame, n=frame_size)[0:n_bins]

    return output_stft.transpose()


if __name__ == "__main__":
    mixture_file = os.environ.get("TEST_HOME") + "/angels/mixture.wav"

    angels, Fs = librosa.load(mixture_file, sr=None)
    frame_size = 4096
    hop_size = 1024

    print(angels[0:10])

    print('audio shape: {}'.format(angels.shape))

    spec = librosa.stft(angels, n_fft=frame_size, hop_length=hop_size, window=np.hanning)

    print('spectrogram shape: {}'.format(spec.shape))

    angels_int = (angels * 32767).astype(np.int16)
    spec_cust = transforms.stft(angels, Fs, frame_size, hop_size)

    print('custom spectrogram shape: {}'.format(spec_cust.shape))
    print(np.allclose(spec, spec_cust))
