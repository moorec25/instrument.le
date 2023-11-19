CC=g++
DEPS = fft_common.h
BUILDDIR = $(OUT_HOME)/build/c_dsp
RUNDIR = $(OUT_HOME)/$(TEST_NAME)

_OBJ = twiddle_rom.o fft.o dualport.o
OBJ = $(patsubst %,$(BUILDDIR)/%,$(_OBJ))

.PHONY: clean run builddir
.SILENT: run builddir

build: $(BUILDDIR)/fft

$(BUILDDIR)/%.o: %.cpp %.h $(DEPS) | builddir
	$(CC) -c -o $@ $< -DN_FFT=$(N_FFT)

$(BUILDDIR)/fft: $(OBJ)
	$(CC) -o $@ $^

run: $(RUNDIR)/.cfftdone

$(RUNDIR)/.cfftdone: $(BUILDDIR)/fft | rundir
	$(BUILDDIR)/fft $(RUNDIR)
	touch $(RUNDIR)/.cfftdone

rundir:
	mkdir -p $(RUNDIR)

builddir:
	mkdir -p $(BUILDDIR)

clean: 
	rm -rf $(BUILDDIR)
