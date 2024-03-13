import os
import librosa
import librosa.display
import numpy as np
import argparse
import sys
sys.path.insert(0, '../model')
from dsp import transforms


def dump_stimulus(test_name, stim, file_name):

    outdir = get_outdir(test_name)
    file = open('{}/{}'.format(outdir, file_name), 'w')

    for item in stim:
        file.write(str(item) + '\n')

    file.close()


def dump_output(test_name, output_stft, file_name):

    outdir = get_outdir(test_name)
    file = open('{}/{}'.format(outdir, file_name), 'w')

    n_bins = output_stft.shape[1]
    print(n_bins)

    for frame in output_stft:
        for i in range(n_bins):
            file.write('{} {}\n'.format(frame[i].real, frame[i].imag))

    file.close()


def get_outdir(test_name):

    out_home = os.environ.get("OUT_HOME")
    outdir = '{}/{}'.format(out_home, test_name)

    if not os.path.exists(outdir):
        os.makedirs(outdir)

    return outdir


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Create traces for stft")

    parser.add_argument('-t', '--testname', type=str, required=True)

    parser.add_argument('-s', '--fft_size', type=int)

    parser.add_argument('-f', '--frames', type=int)

    parser.add_argument('-m', '--hop_size', type=int)

    parser.add_argument('-c', '--channels', type=int)

    args = parser.parse_args()

    if args.fft_size is None:
        n_fft = 4096
    else:
        n_fft = args.fft_size

    if not ((n_fft & (n_fft - 1) == 0) and n_fft != 0):
        print('fft size must be a power of 2')
        exit(1)

    if args.hop_size is None:
        hop_size = 1024
    else:
        hop_size = args.hop_size

    if args.channels is None:
        mono = True
    else:
        mono = args.channels == 1

    window = np.hanning(n_fft)
    window = (window * 32767).astype(np.int16)
    mixture_file = '{}/{}/mixture.wav'.format(os.environ.get("TEST_HOME"), args.testname)
    mixture, Fs = librosa.load(mixture_file, sr=None, mono=mono)

    if args.frames is not None and args.frames != 0:
        samples = n_fft + hop_size * (args.frames - 1)
        mixture = mixture[..., 0:samples]

    print(len(mixture[0]))

    if mono:
        mixture_int = (mixture * 32767).astype(np.int16)
        mixture_stft = transforms.stft(mixture, n_fft, hop_size, norm="ortho")

        x = np.pad(mixture_int, (int(n_fft / 2), 0))
        x_pad = x if x.shape[0] % n_fft == 0 else \
            np.pad(x, (0, n_fft - x.shape[0] % n_fft), 'constant')

        dump_stimulus(args.testname, x_pad, 'stft_in_0.txt')
        dump_stimulus(args.testname, window, 'window.txt')
        dump_output(args.testname, mixture_stft.transpose(), 'stft_out_py.txt')

    else:
        mixture_left = mixture[0, ...]
        mixture_right = mixture[1, ...]

        mixture_int_l = (mixture_left * 32767).astype(np.int16)
        mixture_int_r = (mixture_right * 32767).astype(np.int16)

        mixture_stft_l = transforms.stft(mixture_left, n_fft, hop_size, norm="ortho")
        mixture_stft_r = transforms.stft(mixture_right, n_fft, hop_size, norm="ortho")

        x_l = np.pad(mixture_int_l, (int(n_fft / 2), 0))
        x_l_pad = x_l if x_l.shape[0] % n_fft == 0 else \
            np.pad(x_l, (0, n_fft - x_l.shape[0] % n_fft), 'constant')

        x_r = np.pad(mixture_int_r, (int(n_fft / 2), 0))
        x_r_pad = x_l if x_r.shape[0] % n_fft == 0 else \
            np.pad(x_r, (0, n_fft - x_r.shape[0] % n_fft), 'constant')

        dump_stimulus(args.testname, window, 'window.txt')
        dump_stimulus(args.testname, x_l_pad, 'stft_in_0.txt')
        dump_stimulus(args.testname, x_r_pad, 'stft_in_1.txt')
        dump_output(args.testname, mixture_stft_l.transpose(), 'stft_out_py_0.txt')
        dump_output(args.testname, mixture_stft_r.transpose(), 'stft_out_py_1.txt')
