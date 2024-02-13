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


def istft(X, n_fft, hop_size, center=True):

    window = np.hanning(n_fft)
    window[1:-1] = 1 / window[1:-1]

    n_frames = X.shape[1]
    n_samples = (n_frames - 1) * hop_size + n_fft
    stft = X.transpose()
    output_istft = np.zeros(n_samples, dtype=complex)

    for frame in range(n_frames-1):
        frame_fft = stft[frame+1]
        frame_fft = np.concatenate((frame_fft, np.flip(np.conjugate(frame_fft[1:-1]))))
        inverse = np.fft.ifft(frame_fft, n=n_fft) * window
        output_istft[(frame + 1) * hop_size:(frame + 1) * hop_size + n_fft] += inverse

    if center:
        output_istft = output_istft[int(n_fft / 2):]

    output_istft = np.real(output_istft)

    return output_istft
