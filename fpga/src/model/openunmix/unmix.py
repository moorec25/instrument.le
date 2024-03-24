import utils
import torch.hub
import sys
import data
import os
import torchaudio
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path
from model import OpenUnmix
from model import Separator

def load_spectrogram(filepath, device = "cpu"):
    mixed_spectrogram = torch.load(filepath, map_location=device)
    return mixed_spectrogram

def process_spectrogram(spectrogram):
    with torch.no_grad():
        models = umxl_spec()
        output_spectrograms = torch.zeros(spectrogram.shape + (len(models),), dtype=torch.float32)
        for j, (model_name, model) in enumerate(models.items()):
            target_spectrogram = model(spectrogram.detach().clone())
            output_spectrograms[..., j] = target_spectrogram
        return output_spectrograms

def umxl_spec(targets=None, device="cpu", pretrained=True):

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

def get_outdir(test_name):

    out_home = os.environ.get("OUT_HOME")
    outdir = out_home + "/" + test_name

    if not os.path.exists(outdir):
        os.makedirs(outdir)

    return outdir

def amplitude_to_db(amplitude_tensor, ref=np.max):
    amplitude_tensor = amplitude_tensor.numpy() if isinstance(amplitude_tensor, torch.Tensor) else amplitude_tensor
    ref_value = ref(amplitude_tensor) if callable(ref) else ref
    power_db = 20 * np.log10(np.maximum(1e-10, amplitude_tensor / ref_value))
    return power_db

def plot_spectrogram(spectrogram, path, sr, ref=np.max, title='Spectrogram', ylabel='Frequency (Hz)', xlabel='Time (s)'):
    plt.figure(figsize=(10, 4))
    db_spec = amplitude_to_db(spectrogram, ref=ref)
    plt.imshow(db_spec, aspect='auto', origin='lower', extent=[0, spectrogram.shape[1], 0, sr/2])
    plt.colorbar(format='%+2.0f dB')
    plt.title(title)
    plt.ylabel(ylabel)
    plt.xlabel(xlabel)
    plt.tight_layout()
    plt.savefig(get_outdir(path) + f"/{path}")
    print(get_outdir("angels"))
    #plt.show()

def compare_tensor(spectrogram_tensor, output_directory):

    #output_tensor = output_tensor.squeeze()  # Remove batch dimension if present
    similarities = {}
    file_names = ["vocals.pt", "drums.pt", "bass.pt", "other.pt"]

    for j, file_name in enumerate(file_names):
        target_tensor = spectrogram_tensor[..., j]
        file_path = os.path.join(output_directory, file_name)
        # Load the audio file
        files_name_tensor = torch.load(file_path)
        print(f"{file_name} is\n", files_name_tensor)
        print("target tensor is:\n", target_tensor)
        
        files_name_tensor = files_name_tensor.squeeze()  # Remove channel dimension if it's single channel
        target_tensor = target_tensor.squeeze()
        # Check the similarity
        similarity = torch.equal(target_tensor, files_name_tensor)
        similarities[file_name] = similarity
    return similarities

if __name__ == "__main__":
    
    #Spectrogram
    #path = str(sys.argv[1])
    device = torch.device("cpu") #"cuda" if torch.cuda.is_available() else 
    file_path = os.environ.get("CAPSTONE_HOME") + "/out/angels/mix_spectrogram.pt" #Hardcoded path, should adjust to make modular
    
    spectrogram = load_spectrogram(file_path, device=device)
    output = process_spectrogram(spectrogram)

    #plot_spectrogram(output[0, 0], path, sr=44100)

    output_directory = os.environ.get("CAPSTONE_HOME") + "/out/angels/"  # Example directory, hardcoded
    output_filename = "unmix.pt"  # Desired output filename
    output_filepath = os.path.join(output_directory, output_filename) # output_directory + output_filename

    torch.save(output[..., 0], output_filepath)  #Hardcoded path, should adjust to make modular
    tensor = torch.load(f"{output_directory}/bass.pt")
    print(tensor.shape)

    print(output.shape)

    similarities = compare_tensor(output, output_directory)

    for file_name, is_similar in similarities.items():
        print(f"{file_name}: {'Similar' if is_similar else 'Not Similar'}") #rudimentary check
