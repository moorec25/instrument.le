import os
import numpy as np
import argparse

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Compare output of c++ fft to python model')

    parser.add_argument('-t', '--testname', type=str, required=True)

    args = parser.parse_args()

    pydata = np.loadtxt('{}/{}/fft_out_py.txt'.format(os.environ.get("OUT_HOME"), args.testname))
    cdata = np.loadtxt('{}/{}/fft_out_c.txt'.format(os.environ.get("OUT_HOME"), args.testname))

    if np.allclose(pydata, cdata, rtol=1e-4, atol=5e-3):
        print("Test {} passed!\n".format(args.testname))
    else:
        print("Mismatch occured in test {} \n".format(args.testname))
