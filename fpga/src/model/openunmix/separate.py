import utils
import torch.hub
import sys
import data
import os
import torchaudio
from pathlib import Path


def umxl_spec(targets=None, device="cpu", pretrained=True):
    from model import OpenUnmix

    # set urls for weights
    target_urls = {
        "bass": "https://zenodo.org/api/files/f8209c3e-ba60-48cf-8e79-71ae65beca61/bass-2ca1ce51.pth",
        "drums": "https://zenodo.org/api/files/f8209c3e-ba60-48cf-8e79-71ae65beca61/drums-69e0ebd4.pth",
        "other": "https://zenodo.org/api/files/f8209c3e-ba60-48cf-8e79-71ae65beca61/other-c8c5b3e6.pth",
        "vocals": "https://zenodo.org/api/files/f8209c3e-ba60-48cf-8e79-71ae65beca61/vocals-bccbd9aa.pth",
    }

    if targets is None:
        targets = ["vocals", "drums", "bass", "other"]

    # determine the maximum bin count for a 16khz bandwidth model
    max_bin = utils.bandwidth_to_max_bin(rate=44100.0, n_fft=4096, bandwidth=16000)

    target_models = {}
    for target in targets:
        # load open unmix model
        target_unmix = OpenUnmix(
            nb_bins=4096 // 2 + 1, nb_channels=2, hidden_size=1024, max_bin=max_bin
        )

        # enable centering of stft to minimize reconstruction error
        if pretrained:
            state_dict = torch.hub.load_state_dict_from_url(
                target_urls[target], map_location=device
            )
            target_unmix.load_state_dict(state_dict, strict=False)
            target_unmix.eval()

        target_unmix.to(device)
        target_models[target] = target_unmix
    return target_models


def umxl(
    targets=None,
    residual=False,
    niter=1,
    device="cpu",
    pretrained=True,
    filterbank="torch",
    test_name="angels"
):
    """
    Open Unmix Extra (UMX-L), 2-channel/stereo BLSTM Model trained on a private dataset
    of ~400h of multi-track audio.


    Args:
        targets (str): select the targets for the source to be separated.
                a list including: ['vocals', 'drums', 'bass', 'other'].
                If you don't pick them all, you probably want to
                activate the `residual=True` option.
                Defaults to all available targets per model.
        pretrained (bool): If True, returns a model pre-trained on MUSDB18-HQ
        residual (bool): if True, a "garbage" target is created
        niter (int): the number of post-processingiterations, defaults to 0
        device (str): selects device to be used for inference
        filterbank (str): filterbank implementation method.
            Supported are `['torch', 'asteroid']`. `torch` is about 30% faster
            compared to `asteroid` on large FFT sizes such as 4096. However,
            asteroids stft can be exported to onnx, which makes is practical
            for deployment.

    """

    from model import Separator

    target_models = umxl_spec(targets=targets, device=device, pretrained=pretrained)
    separator = Separator(
        target_models=target_models,
        niter=niter,
        residual=residual,
        n_fft=4096,
        n_hop=1024,
        nb_channels=2,
        sample_rate=44100.0,
        filterbank=filterbank,
        trace_en=True,
        test_name=test_name
    ).to(device)

    return separator


def get_outdir(test_name):

    out_home = os.environ.get("OUT_HOME")
    outdir = out_home + "/" + test_name

    if not os.path.exists(outdir):
        os.makedirs(outdir)

    return outdir


if __name__ == "__main__":

    test_name = str(sys.argv[1])

    separator = umxl(test_name=test_name)

    testdir = os.environ.get("TEST_HOME")
    test_path = testdir + "/" + test_name + "/mixture.wav"

    outdir = get_outdir(test_name)

    audio, Fs = data.load_audio(test_path)
    audio = utils.preprocess(audio, Fs, separator.sample_rate)
    estimates = separator(audio)
    estimates = separator.to_dict(estimates)
    for target, estimate in estimates.items():
        target_path = str(outdir / Path(target).with_suffix(".wav"))
        torchaudio.save(
            target_path,
            torch.squeeze(estimate).to("cpu"),
            sample_rate=separator.sample_rate,
        )

