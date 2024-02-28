RUNDIR = $(OUT_HOME)/$(TEST_NAME)

.PHONY: clean 
.SILENT: rundir

stft: $(RUNDIR)/.pystftdone

$(RUNDIR)/.pystftdone: fft.py | rundir
	python stft.py -t $(TEST_NAME) -s $(N_FFT) -m $(HOP_SIZE) -c $(CHANNELS)
	touch $(RUNDIR)/.pystftdone

fft: $(RUNDIR)/.pyfftdone

$(RUNDIR)/.pyfftdone: fft.py | rundir
	python fft.py -t $(TEST_NAME) -N $(N_FFT)
	touch $(RUNDIR)/.pyfftdone

rundir:
	mkdir -p $(RUNDIR)

clean:
	rm $(RUNDIR)/.pyfftdone
