import numpy as np


def stft(x, n_fft, hop_size, center=True, norm="forward"):

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
        output_stft[frame] = np.fft.rfft(win_frame, n=n_fft, norm=norm)

    return output_stft.transpose()


def istft(X, n_fft=None, hop_size=None, center=True, window=None):

    shape = list(X.shape)

    if n_fft is None:
        n_fft = (shape[0] - 1) * 2

    if hop_size is None:
        hop_size = int(n_fft // 4)

    if window is None:
        window = np.hanning(n_fft)

    window = window.reshape(n_fft, 1)

    n_frames = shape[1]

    signal_length = (n_frames - 1) * hop_size + n_fft

    y = np.zeros(signal_length)

    ytmp = window * np.fft.irfft(X, n=n_fft, axis=-2)

    __overlap_add(y, ytmp, hop_size)

    window_sum = __window_sumsquare(window, n_frames, hop_size, n_fft)

    nonzero_indices = window_sum > 0

    y[nonzero_indices] /= window_sum[nonzero_indices]

    if center:
        y = y[int(n_fft // 2):-int(n_fft // 2)]

    return y


def __overlap_add(y, ytmp, hop_size):
    """Perform overlap add
    y: output buffer
    ytmp: windowed frames of shape (n_fft, n_frames)
    hop_size: window hop size"""

    n_fft = ytmp.shape[0]
    N = n_fft
    n_frames = ytmp.shape[1]

    for frame in range(n_frames):
        sample = frame * hop_size
        if N > y.shape[-1] - sample:
            N = y.shape[-1] - sample

        y[sample:sample + N] += ytmp[:N, frame]


def __window_sumsquare(window, n_frames, hop_size, n_fft):

    signal_length = (n_frames - 1) * hop_size + n_fft
    w = np.zeros(signal_length)

    win_sq = np.square(window).reshape(n_fft)

    for frame in range(n_frames):
        sample = frame * hop_size
        w[sample:sample + n_fft] += win_sq

    return w
