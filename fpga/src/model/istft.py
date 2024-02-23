from dsp import transforms
import numpy as np
import librosa

if __name__ == "__main__":
    n_fft = 4096
    hop_size = 1024
    x = np.random.random(40960)
    trans = transforms.stft(x, n_fft=n_fft, hop_size=hop_size)
    inv1 = transforms.istft(trans, n_fft, hop_size, window=np.hanning(n_fft))
    inv2 = librosa.istft(trans, n_fft=n_fft, hop_length=hop_size, window=np.hanning(n_fft))

    print(x)
    print(inv1)
    print(inv2)

    print('Inverse matches librosa: {}'.format(np.allclose(inv1, inv2)))

    np.savetxt('x.txt', x)
    np.savetxt('inv.txt', inv1)
