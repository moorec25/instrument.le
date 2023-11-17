CC=g++
DEPS = fft_common.h
ODIR = $(OUT_HOME)/c_dsp

_OBJ = twiddle_rom.o fft.o dualport.o
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))

.PHONY: clean run outdir
.SILENT: run outdir

$(ODIR)/%.o: %.cpp %.h $(DEPS) | outdir
	$(CC) -c -o $@ $<

$(ODIR)/fft: $(OBJ)
	$(CC) -o $@ $^

run: $(ODIR)/fft
	$(ODIR)/fft

outdir:
	mkdir -p $(ODIR)

clean: 
	rm -rf $(ODIR)
