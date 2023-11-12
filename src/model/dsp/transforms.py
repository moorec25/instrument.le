import numpy as np


def stft(x, n_fft, hop_size, center=True):

    # Create hann window of window size = n_fft
    window = np.hanning(n_fft)

    # Zero pad beginning of signal for centering
    if center:
        x = np.pad(x, (int(n_fft / 2), 0))

    # Zero pad to make signal length a multiple of n_fft
    x_pad = x if x.shape[0] % n_fft == 0 else \
        np.pad(x, (0, n_fft - x.shape[0] % n_fft), 'constant')

    n_bins = int(n_fft / 2 + 1)
    n_frames = int((x_pad.shape[0] - n_fft) / hop_size + 1)

    output_stft = np.zeros((n_frames, n_bins), dtype=complex)

    for frame in range(n_frames):
        x = x_pad[frame * hop_size:frame * hop_size + n_fft]
        win_frame = x * window
        output_stft[frame] = np.fft.fft(win_frame, n=n_fft)[0:n_bins]

    return output_stft.transpose()
