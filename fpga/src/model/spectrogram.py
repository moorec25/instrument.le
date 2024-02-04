import os
import librosa
import librosa.display
import numpy as np
import matplotlib.pyplot as plt
import torchaudio
import torch

from soundfile import SoundFile
from dsp import transforms


if __name__ == "__main__":
    mixture_file = os.environ.get("TEST_HOME") + "/angels/mixture.wav"

    angels, Fs = librosa.load(mixture_file, sr=None, mono=None)
    frame_size = 4096
    hop_size = 1024

    print('audio shape: {}'.format(angels.shape))
 
    angels_left = angels[0,:]
    angels_right = angels[1,:]

    spec_left = librosa.stft(angels_left, n_fft=frame_size, hop_length=hop_size, window=np.hanning)
    spec_right = librosa.stft(angels_right, n_fft=frame_size, hop_length=hop_size, window=np.hanning)
    
    #spec = librosa.stft(angels, n_fft=frame_size, hop_length=hop_size, window=np.hanning)
    
    print('spectrogram shape: {}'.format(spec_left.shape))
    
    print('spectrogram shape: {}'.format(spec_right.shape))

    angels_int = (angels * 32767).astype(np.int16)
    print(np.max(np.abs(angels_int)))

    spec_left_cust = transforms.stft(angels_left, frame_size, hop_size)
    spec_right_cust = transforms.stft(angels_right, frame_size, hop_size)

    spec_left_mag = np.abs(spec_left_cust)
    spec_right_mag = np.abs(spec_right_cust)
    spec_cust = np.sqrt(spec_left_mag**2 + spec_right_mag**2)
    #spec_cust = transforms.stft(angels, frame_size, hop_size)

    print('custom spectrogram shape: {}'.format(spec_left_cust.shape))
    print('custom spectrogram shape: {}'.format(spec_right_cust.shape))
    print('custom spectrogram shape: {}'.format(spec_cust.shape))
    #print(np.allclose(spec, spec_cust))

    spectrogram_path = '../../../out/angels_short/mix_spectrogram.pt'
    spectrogram = torch.load(spectrogram_path)
    spectrogram = torchaudio.transforms.AmplitudeToDB()(spectrogram)
    plt.imshow(spectrogram[0].numpy(),cmap='viridis',aspect='auto',origin='lower')
    plt.show()
