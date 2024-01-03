import os
import numpy as np
import argparse
import librosa


def dump_input_samples(test_name, input_samples):

    outdir = get_outdir(test_name)
    file = open('{}/fft_in.txt'.format(outdir), 'w')

    for sample in input_samples:
        file.write(str(sample) + '\n')

    file.close()


def dump_output(test_name, output_real, output_imag):

    outdir = get_outdir(test_name)
    file = open('{}/fft_out_py.txt'.format(outdir), 'w')

    for i in range(len(output_real)):
        file.write('{} {}\n'.format(output_real[i], output_imag[i]))

    file.close()


def get_outdir(test_name):

    out_home = os.environ.get("OUT_HOME")
    outdir = '{}/{}'.format(out_home, test_name)

    if not os.path.exists(outdir):
        os.makedirs(outdir)

    return outdir


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Run fft on samples in numpy and c++ and compare output')

    parser.add_argument('-t', '--testname', type=str, required=True)

    parser.add_argument('-N', '--numsamples', type=int)

    args = parser.parse_args()

    input_file = '{}/{}/mixture.wav'.format(os.environ.get("TEST_HOME"), args.testname)

    if args.numsamples is None:
        samples = 4096
    else:
        samples = args.numsamples

    if not ((samples & (samples - 1) == 0) and samples != 0):
        print('Samples must be a power of 2')
        exit(1)

    mixture, Fs = librosa.load(input_file, sr=None)

    mixture = mixture[0:samples]

    mixture_int = (mixture * 32766).astype(np.int16)

    mixture_fft = np.fft.fft(mixture, samples, norm="ortho")

    dump_input_samples(args.testname, mixture_int)
    dump_output(args.testname, mixture_fft.real, mixture_fft.imag)
