#ifndef FFT_H
#define FFT_H

#include "fft_common.h"
#include "twiddle_rom.h"
#include "dualport.h"

#define N_FFT 8
#define N_TWIDDLES N_FFT/2

void fftTop();

void butterfly(int32_t inReal1, int32_t inImag1, int32_t inReal2, int32_t inImag2, uint16_t twiddleReal, uint16_t twiddleImag, int32_t &outReal1, int32_t &outImag1, int32_t &outReal2, int32_t &outImag2);

void complexMultiply(int32_t inReal1, int32_t inImag1, int32_t inReal2, int32_t inImag2, int32_t &outReal, int32_t &outImag);

// Perform a circular left shift on N bit word x by y bits
void rotateLeft(uint32_t &x, uint32_t y, uint8_t N);

// Reverse the bits of N bit word x
void bitReverse(uint32_t &x, uint8_t N);

void calcTwiddleMask(uint16_t &mask, uint8_t level, uint8_t N);
#endif
