RUNDIR = $(OUT_HOME)/$(TEST_NAME)

.PHONY: clean 
.SILENT: rundir

fft: $(RUNDIR)/.pyfftdone

$(RUNDIR)/.pyfftdone: fft.py | rundir
	python fft.py -t $(TEST_NAME) -N $(N_FFT)
	touch $(RUNDIR)/.pyfftdone

rundir:
	mkdir -p $(RUNDIR)

clean:
	rm -rf $(OUT_HOME)/pydsp
