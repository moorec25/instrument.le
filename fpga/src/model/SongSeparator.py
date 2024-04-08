import openunmix
from openunmix import data
from openunmix import utils
from pathlib import Path
import torch.hub
import os
import torchaudio


class SongSeparator:

    def __init__(self) -> None:
        self.targets = ["vocals", "drums", "bass", "other"]
        self.separator = openunmix.umxl(self.targets)
        self.outdir = self.get_outdir()

    def get_outdir(self) -> str:

        out_home = os.environ.get("OUT_HOME")
        outdir = out_home + "/app"

        if not os.path.exists(outdir):
            os.makedirs(outdir)

        return outdir

    def separate_song(self, file_path: str, for_game: bool = False) -> list:
        """
        This function is responsible for separating the song into its individual tracks.
        Returns a list of absolute file paths to the separated tracks.
        Returns bass, drums, vocals, other, 2layer, 3layer
        """
        print(f"Separating song {file_path}...")
        
        audio, Fs = data.load_audio(file_path)
        audio = utils.preprocess(audio, Fs, self.separator.sample_rate)
        estimates = self.separator(audio)
        estimates = self.separator.to_dict(estimates)

        paths = []

        if for_game:
            estimates['2layer'] = estimates['drums'] + estimates['bass']
            estimates['3layer'] = estimates['2layer'] + estimates['other']

        for target, estimate in estimates.items():
            target_path = str(self.outdir / Path(target).with_suffix(".wav"))
            paths.append(target_path)
            torchaudio.save(
                target_path,
                torch.squeeze(estimate).detach().to("cpu"),
                sample_rate=self.separator.sample_rate,
            )

        print("Song separated successfully.")

        return paths

