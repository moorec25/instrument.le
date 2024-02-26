import os
import librosa
import librosa.display
import numpy as np
import argparse
import sys
sys.path.insert(0, '../model')
from dsp import transforms


def dump_input_samples(test_name, input_samples):

    outdir = get_outdir(test_name)
    file = open('{}/stft_in.txt'.format(outdir), 'w')

    for sample in input_samples:
        file.write(str(sample) + '\n')

    file.close()


def dump_output(test_name, output_stft):

    outdir = get_outdir(test_name)
    file = open('{}/stft_out_py.txt'.format(outdir), 'w')

    n_bins = output_stft.shape[1]
    print(n_bins)

    for frame in output_stft:
        for i in range(n_bins):
            file.write('{} {}\n'.format(frame[i].real, frame[i].imag))

    file.close()


def dump_window(test_name, window):

    outdir = get_outdir(test_name)
    file = open('{}/window.txt'.format(outdir), 'w')

    for sample in window:
        file.write(str(sample) + '\n')

    file.close


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

    window = np.hanning(n_fft)
    window = (window * 32767).astype(np.int16)
    mixture_file = '{}/{}/mixture.wav'.format(os.environ.get("TEST_HOME"), args.testname)
    mixture, Fs = librosa.load(mixture_file, sr=None)

    if args.frames is not None:
        samples = n_fft + hop_size * (args.frames - 1)
        mixture = mixture[0:samples]

    mixture_int = (mixture * 32767).astype(np.int16)
    mixture_stft = transforms.stft(mixture, n_fft, hop_size, norm="ortho")

    x = np.pad(mixture_int, (int(n_fft / 2), 0))
    x_pad = x if x.shape[0] % n_fft == 0 else \
        np.pad(x, (0, n_fft - x.shape[0] % n_fft), 'constant')

    dump_input_samples(args.testname, x_pad)
    dump_output(args.testname, mixture_stft.transpose())
    dump_window(args.testname, window)
