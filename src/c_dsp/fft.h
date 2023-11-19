#ifndef FFT_H
#define FFT_H

#include "fft_common.h"
#include "twiddle_rom.h"
#include "dualport.h"

#ifndef N_FFT
#define N_FFT 4
#endif

#define N_TWIDDLES N_FFT/2

void fftTop(DPRAM_64 &dpram0, DPRAM_64 &dpram1);

void butterfly(int32_t inReal1, int32_t inImag1, int32_t inReal2, int32_t inImag2, int32_t twiddleReal, int32_t twiddleImag, int32_t &outReal1, int32_t &outImag1, int32_t &outReal2, int32_t &outImag2);

void complexMultiply(int32_t inReal1, int32_t inImag1, int32_t inReal2, int32_t inImag2, int32_t &outReal, int32_t &outImag);

// Perform a circular left shift on N bit word x by y bits
void rotateLeft(uint32_t &x, uint32_t y, uint8_t N);

// Reverse the bits of N bit word x
void bitReverse(uint32_t &x, uint8_t N);

void calcTwiddleMask(uint16_t &mask, uint8_t level, uint8_t N);

void loadRam(FILE *fp, DPRAM_64 &ram);

void writeOutput(FILE *fp, DPRAM_64 &ram);

int32_t signExtend(uint32_t x, uint8_t N);
#endif
