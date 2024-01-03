export

.PHONY: clean_demo clean_cdsp clean

# Default parameters
TEST_NAME ?= angels
N_FFT ?= 8

build: build_cmodel

build_cmodel: 
	$(MAKE) build -C c_dsp

test_fft: c_fft py_fft
	$(MAKE) test_fft -C test

c_fft: py_fft
	$(MAKE) run -C c_dsp

py_fft:
	$(MAKE) fft -C demo

clean:
	rm -rf $(OUT_HOME)

clean_demo:
	$(MAKE) clean -C demo
