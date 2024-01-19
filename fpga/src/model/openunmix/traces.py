import torch
import os


class Traces():

    def __init__(self, test_name):
        self.test_name = test_name
        self.outdir = self.get_outdir()

    def get_outdir(self):
        out_home = os.environ.get("OUT_HOME")
        outdir = out_home + "/" + self.test_name
        return outdir

    def dump_trace(self, x, name):
        path = "{}/{}.pt".format(self.outdir, name)
        torch.save(x, path)
