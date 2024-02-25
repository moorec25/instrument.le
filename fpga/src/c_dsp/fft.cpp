#include "fft.h"
#include <cstdio>

FFT::FFT(uint16_t size) : 
    nFFT(size), 
    dpram0(size), 
    dpram1(size), 
    twiddles(size/2),
    levels ((uint8_t) std::log2(size)) {

    assert(std::ceil(log2(size)) == std::floor(log2(size)));
}

void FFT::calcFFT() {

    uint8_t readingRam = 0;
    uint8_t writingRam = 1;

    uint32_t addr1, addr2, addr1Rev, addr2Rev;
    int32_t real1, imag1, real2, imag2;
    uint16_t twiddleAddr, twiddleMask;
    int16_t twiddleReal;
    int32_t twiddleSum, twiddleDiff;
    int32_t bflyOutReal1, bflyOutImag1, bflyOutReal2, bflyOutImag2;

    for (int i=0; i<levels; i++) {
        for (int j=0; j<nFFT/2; j++) {

            addr1 = j << 1;
            addr2 = addr1 + 1;
            rotateLeft(addr1, i, levels);
            rotateLeft(addr2, i, levels);

            calcTwiddleMask(twiddleMask, i, levels-1); 
            twiddleAddr = twiddleMask & (nFFT/2-1) & j;

            if (i == 0) {
                bitReverse(addr1, levels);
                bitReverse(addr2, levels);
            }

            if (readingRam == 0) {
                dpram0.memRead(addr1, real1, imag1);
                dpram0.memRead(addr2, real2, imag2);
            } else {
                dpram1.memRead(addr1, real1, imag1);
                dpram1.memRead(addr2, real2, imag2);
            }

            twiddles.readTwiddle(twiddleAddr, twiddleReal, twiddleSum, twiddleDiff);

            butterfly(real1, imag1, real2, imag2, twiddleReal, twiddleSum, twiddleDiff, bflyOutReal1, bflyOutImag1, bflyOutReal2, bflyOutImag2);

            if (i == 0) {
                bitReverse(addr1, levels);
                bitReverse(addr2, levels);
            }

            if (i % 2 == 1) {
                bflyOutReal1 >>= 1;
                bflyOutImag1 >>= 1;
                bflyOutReal2 >>= 1;
                bflyOutImag2 >>= 1;
            }

            if (writingRam == 0) {
                dpram0.memWrite(addr1, bflyOutReal1, bflyOutImag1);
                dpram0.memWrite(addr2, bflyOutReal2, bflyOutImag2);
            } else {
                dpram1.memWrite(addr1, bflyOutReal1, bflyOutImag1);
                dpram1.memWrite(addr2, bflyOutReal2, bflyOutImag2);
            }
#ifdef FFT_TRACE_EN
            mem_trace(fp_mem_wr_trace, addr1, bflyOutReal1, bflyOutImag1, addr2, bflyOutReal2, bflyOutImag2, writingRam);
#endif
        } 
        readingRam = (readingRam == 0) ? 1 : 0;
        writingRam = (writingRam == 0) ? 1 : 0;
    }
}

void FFT::butterfly(int32_t inReal1, int32_t inImag1, int32_t inReal2, int32_t inImag2, int32_t twiddleReal, int32_t twiddleSum, int32_t twiddleDiff, int32_t &outReal1, int32_t &outImag1, int32_t &outReal2, int32_t &outImag2) {

    int64_t twiddleMultReal;
    int64_t twiddleMultImag;

    complexMultiply(inReal2, inImag2, twiddleReal, twiddleSum, twiddleDiff, twiddleMultReal, twiddleMultImag);

    outReal1 = (twiddleMultReal >> 15) + inReal1;
    outImag1 = (twiddleMultImag >> 15) + inImag1;

    outReal2 = inReal1 - (twiddleMultReal >> 15);
    outImag2 = inImag1 - (twiddleMultImag >> 15);
}

void FFT::complexMultiply(int32_t inReal1, int32_t inImag1, int32_t twiddleReal, int32_t twiddleSum, int32_t twiddleDiff, int64_t &outReal, int64_t &outImag) {

    // Multiply two complex numbers using 3 multipliers
    
    int64_t K1 = (int64_t) twiddleReal * (int64_t)(inReal1 + inImag1);
    int64_t K2 = (int64_t) inReal1 * (int64_t)(twiddleDiff);
    int64_t K3 = (int64_t) inImag1 * (int64_t)(twiddleSum);

    outReal = K1 - K3;
    outImag = K1 + K2;
}

void FFT::rotateLeft(uint32_t &x, uint32_t y, uint8_t N) {
    
    uint32_t mask = 1;

    for (int i=1; i < N; i++) {
        mask |= (1 << i);
    }

    x = ((x << y%N) | (x >> (N - y%N))) & mask;
    
}

void FFT::bitReverse(uint32_t &x, uint8_t N) {
    
    uint32_t output = 0;
    uint32_t mask = 1 << (N-1);
    uint32_t bit = 0;

    for (int i=0; i<N; i++) {
        bit = x & mask;
        rotateLeft(bit, 2*i+1, N);
        output |= bit;
        mask >>= 1;
    }
    x = output;
}

void FFT::calcTwiddleMask(uint16_t &mask, uint8_t level, uint8_t N) {
    
    mask = UINT16_MAX;

    for (int i=0; i<N-level; i++) {
        mask ^= (1 << i);
    }

}

void FFT::loadRam(FILE *fp) {
    
    uint16_t sample;

    for (int i=0; i<nFFT; i++) {
        fscanf(fp, "%hd", &sample);
        dpram0.memWrite(i, signExtend(sample, 16), 0);
    }
}

void FFT:: loadRam(uint16_t * samples) {
    
    for (int i=0; i<nFFT; i++) {
        dpram0.memWrite(i, signExtend(samples[i], 16), 0);
        printf("%d\n", (int16_t) samples[i]);
    }
}

void FFT::writeOutput(FILE *fp, bool symmetry) {

    int32_t real, imag;
    uint16_t n = symmetry ? nFFT / 2 + 1 : nFFT;

    DPRAM_64 &ram = (levels % 2 == 0) ? dpram0 : dpram1;

    for (int i=0; i<n; i++) {
        ram.memRead(i, real, imag);
        fprintf(fp, "%d %d\n", real, imag);
    }

}

void FFT::writeOutput(int32_t * real, int32_t * imag, bool symmetry) {
   
    int32_t real_s, imag_s;
    uint16_t n = symmetry ? nFFT / 2 + 1 : nFFT;

    DPRAM_64 &ram = (levels % 2 == 0) ? dpram0 : dpram1;
    for (int i=0; i<n; i++) {
        ram.memRead(i, real_s, imag_s);
        real[i] = real_s;
        imag[i] = imag_s;
    }
}

int32_t FFT::signExtend(uint32_t x, uint8_t N) {
    
    uint32_t signMask = 1 << (N-1);
    uint32_t sign = x & signMask;

    uint32_t valueMask = signMask-1;

    int32_t y = (x & valueMask);

    for (int i=0; i<=(32-N); i++) {
        y |= sign;
        sign <<= 1;
    }

    return y;
}

void FFT::mem_trace(FILE * fp, uint32_t addra, int32_t wdataa_r, int32_t wdataa_i, uint32_t addrb, int32_t wdatab_r, int32_t wdatab_i, uint16_t wmem_id) {
    fprintf(fp, "%x %x %x %x %x %x %d\n", addra, wdataa_r, wdataa_i, addrb, wdatab_r, wdatab_i, wmem_id);
}
