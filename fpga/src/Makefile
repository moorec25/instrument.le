export

.PHONY: clean_demo clean_cdsp clean

# Default parameters
TEST_NAME ?= angels
N_FFT ?= 4096
HOP_SIZE ?= 1024

build_stft:
	$(MAKE) build_stft -C c_dsp

c_stft: py_stft
	$(MAKE) run_stft -C c_dsp

py_stft:
	$(MAKE) stft -C trace

build_fft: 
	$(MAKE) build_fft -C c_dsp

test_fft: c_fft py_fft
	$(MAKE) test_fft -C test

c_fft: py_fft
	$(MAKE) run_fft -C c_dsp

py_fft:
	$(MAKE) fft -C trace

clean:
	rm -rf $(OUT_HOME)

clean_demo:
	$(MAKE) clean -C demo
