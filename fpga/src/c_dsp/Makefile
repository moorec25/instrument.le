CC=g++
DEPS = fft_common.h
BUILDDIR = $(OUT_HOME)/build/c_dsp
RUNDIR = $(OUT_HOME)/$(TEST_NAME)

_FFT_OBJ = twiddle_rom.o fft.o dualport.o fft_inf.o
FFT_OBJ = $(patsubst %,$(BUILDDIR)/%,$(_FFT_OBJ))

_STFT_OBJ = stft.o twiddle_rom.o fft.o dualport.o
STFT_OBJ = $(patsubst %,$(BUILDDIR)/%,$(_STFT_OBJ))

.PHONY: clean run builddir
.SILENT: run builddir rundir

build_fft: $(BUILDDIR)/fft

build_stft: $(BUILDDIR)/stft

$(BUILDDIR)/%.o: %.cpp $(DEPS) | builddir
	$(CC) $(CFLAGS) -c -o  $@ $< 

$(BUILDDIR)/fft: $(FFT_OBJ)
	$(CC) $(CFLAGS) -o  $@ $^

$(BUILDDIR)/stft: $(STFT_OBJ)
	$(CC) $(CFLAGS) -o  $@ $^

run_fft: $(RUNDIR)/.cfftdone

run_stft: $(RUNDIR)/.cstftdone

$(RUNDIR)/.cfftdone: $(BUILDDIR)/fft | rundir
	$(BUILDDIR)/fft $(N_FFT) $(RUNDIR)
	touch $(RUNDIR)/.cfftdone

$(RUNDIR)/.cstftdone: $(BUILDDIR)/stft | rundir
	$(BUILDDIR)/stft $(N_FFT) $(HOP_SIZE) $(RUNDIR)
	touch $(RUNDIR)/.cstftdone

rundir:
	mkdir -p $(RUNDIR)

builddir:
	mkdir -p $(BUILDDIR)

clean: 
	rm -rf $(BUILDDIR)
