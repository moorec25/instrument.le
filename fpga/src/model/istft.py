from dsp import transforms
import numpy as np

if __name__ == "__main__":
    n_fft = 1024
    hop_size = 512
    x = np.random.random(9728)
    trans = transforms.stft(x, n_fft, hop_size)
    inv = transforms.istft(trans, n_fft, hop_size)
    print(x)
    print(inv)
    np.savetxt('x.txt', x)
    np.savetxt('inv.txt', inv)
