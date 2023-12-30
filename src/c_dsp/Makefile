CC=g++
DEPS = fft_common.h
BUILDDIR = $(OUT_HOME)/build/c_dsp
RUNDIR = $(OUT_HOME)/$(TEST_NAME)

_OBJ = twiddle_rom.o fft.o dualport.o fft_inf.o
OBJ = $(patsubst %,$(BUILDDIR)/%,$(_OBJ))

.PHONY: clean run builddir
.SILENT: run builddir

build: $(BUILDDIR)/fft

$(BUILDDIR)/%.o: %.cpp $(DEPS) | builddir
	$(CC) $(CFLAGS) -c -o  $@ $< 

$(BUILDDIR)/fft: $(OBJ)
	$(CC) $(CFLAGS) -o  $@ $^

run: $(RUNDIR)/.cfftdone

$(RUNDIR)/.cfftdone: $(BUILDDIR)/fft | rundir
	$(BUILDDIR)/fft $(N_FFT) $(RUNDIR)
	touch $(RUNDIR)/.cfftdone

rundir:
	mkdir -p $(RUNDIR)

builddir:
	mkdir -p $(BUILDDIR)

clean: 
	rm -rf $(BUILDDIR)
