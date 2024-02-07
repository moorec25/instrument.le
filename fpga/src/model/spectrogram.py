import os
import librosa
import librosa.display
import numpy as np
import matplotlib.pyplot as plt
import torchaudio
import torch
import torch.nn.functional as F
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

    librosa_stft_left = librosa.stft(angels_left, n_fft=frame_size, hop_length=hop_size, window=np.hanning)
    librosa_stft_right = librosa.stft(angels_right, n_fft=frame_size, hop_length=hop_size, window=np.hanning)
    #spec = librosa.stft(angels, n_fft=frame_size, hop_length=hop_size, window=np.hanning)
    
    angels_int = (angels * 32767).astype(np.int16)
    #print(np.max(np.abs(angels_int)))

    stft_left_cust = transforms.stft(angels_left, frame_size, hop_size)
    stft_right_cust = transforms.stft(angels_right, frame_size, hop_size)
    stft_cust = stft_left_cust + stft_right_cust
    print('custom stft shape: {}'.format(stft_cust.shape))

    spec_cust = np.abs(stft_cust)
    spec_left_cust = np.abs(stft_left_cust)
    spec_right_cust = np.abs(stft_right_cust)
    print('custom spectrogram shape: {}'.format(spec_cust.shape))

    stft_left_tensor = torch.stack([torch.tensor(stft_left_cust.real),torch.tensor(stft_left_cust.imag)],dim = -1)
    stft_right_tensor = torch.stack([torch.tensor(stft_right_cust.real),torch.tensor(stft_right_cust.imag)],dim=-1)
    stft_tensor = torch.stack([stft_left_tensor,stft_right_tensor],dim=1)
    stft_tensor = stft_tensor.unsqueeze(0)
    stft_tensor = stft_tensor.permute(0,2,1,3,4)
   
    spec_left_tensor = torch.tensor(spec_left_cust)
    spec_right_tensor = torch.tensor(spec_right_cust)
    spectrogram_tensor = torch.stack([spec_left_tensor,spec_right_tensor],dim=-1)
    spectrogram_tensor = spectrogram_tensor.unsqueeze(0)
    spectrogram_tensor = spectrogram_tensor.permute(0,3,1,2)
    print('stft tensor shape: {}'.format(stft_tensor.size()))
    print('spectrogram tensor shape: {}'.format(spectrogram_tensor.size()))
    #print(np.allclose(spec, spec_cust))


    spectrogram_path = '../../../out/angels/mix_spectrogram.pt'
    stft_path = '../../../out/angels/mix_stft.pt'

    spectrogram = torch.load(spectrogram_path)
    stft = torch.load(stft_path)
   
    # Comparing stft/spectrogram created with the expected stft/spectrogram
    #mse_stft_loss = F.mse_loss(stft_tensor,stft)
    #print("MSE: {}".format(mse_stft_loss.item()))
    #mse_spec_loss = F.mse_loss(spectrogram_tensor,spectrogram)
    #print("MSE: {}".format(mse_spec_loss.item()))

    spectrogram = torchaudio.transforms.AmplitudeToDB()(spectrogram)
    
    spectrogram_tensor = torchaudio.transforms.AmplitudeToDB()(spectrogram_tensor)
    print('mix_spectrogram shape: {}'.format(spectrogram.size()))    
    print('mix_stft shape: {}'.format(stft.size()))
    #print('spectrogram_tensor: {}'.format(spectrogram_tensor))
    #print('spectrogram {}'.format(spectrogram))
    
    plt.figure(figsize=(10,5))
    for i in range(spectrogram_tensor.shape[1]):
        plt.subplot(2,1,i+1)
        librosa.display.specshow(librosa.amplitude_to_db(spectrogram_tensor[0,i],ref = np.max),sr=44100,x_axis ='time',y_axis='log')
        plt.colorbar(format='%+2.0f dB')
        plt.title('Spectrogram Channel {}'.format(i+1))
    plt.tight_layout()
    plt.savefig('spectrogram_tensor.png')

    plt.figure(figsize=(10,5))
    for i in range(spectrogram.shape[1]):
        plt.subplot(2,1,i+1)
        librosa.display.specshow(librosa.amplitude_to_db(spectrogram[0,i],ref = np.max),sr=44100,x_axis ='time',y_axis='log')
        plt.colorbar(format='%+2.0f dB')
        plt.title('Spectrogram Channel {}'.format(i+1))
    plt.tight_layout()
    plt.savefig('spectrogram.png')
