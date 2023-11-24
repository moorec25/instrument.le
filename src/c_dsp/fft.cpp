#include "fft.h"

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
    int16_t twiddleReal, twiddleImag;
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

            twiddles.readTwiddle(twiddleAddr, twiddleReal, twiddleImag);

            butterfly(real1, imag1, real2, imag2, twiddleReal, twiddleImag, bflyOutReal1, bflyOutImag1, bflyOutReal2, bflyOutImag2);

            if (i == 0) {
                bitReverse(addr1, levels);
                bitReverse(addr2, levels);
            }

            if (writingRam == 0) {
                dpram0.memWrite(addr1, bflyOutReal1, bflyOutImag1);
                dpram0.memWrite(addr2, bflyOutReal2, bflyOutImag2);
            } else {
                dpram1.memWrite(addr1, bflyOutReal1, bflyOutImag1);
                dpram1.memWrite(addr2, bflyOutReal2, bflyOutImag2);
            }
        } 
        readingRam = (readingRam == 0) ? 1 : 0;
        writingRam = (writingRam == 0) ? 1 : 0;
    }
}

void FFT::butterfly(int32_t inReal1, int32_t inImag1, int32_t inReal2, int32_t inImag2, int32_t twiddleReal, int32_t twiddleImag, int32_t &outReal1, int32_t &outImag1, int32_t &outReal2, int32_t &outImag2) {

    int64_t twiddleMultReal;
    int64_t twiddleMultImag;

    complexMultiply(inReal2, inImag2, twiddleReal, twiddleImag, twiddleMultReal, twiddleMultImag);

    outReal1 = (twiddleMultReal >> 15) + inReal1;
    outImag1 = (twiddleMultImag >> 15) + inImag1;

    outReal2 = inReal1 - (twiddleMultReal >> 15);
    outImag2 = inImag1 - (twiddleMultImag >> 15);
}

void FFT::complexMultiply(int32_t inReal1, int32_t inImag1, int32_t inReal2, int32_t inImag2, int64_t &outReal, int64_t &outImag) {

    // Multiply two complex numbers using 3 multipliers
    
    int64_t K1 = (int64_t) inReal2 * (int64_t)(inReal1 + inImag1);
    int64_t K2 = (int64_t)inReal1 * (int64_t)(inImag2 - inReal2);
    int64_t K3 = (int64_t)inImag1 * (int64_t)(inReal2 + inImag2);

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

void FFT::writeOutput(FILE *fp) {

    int32_t real, imag;

    DPRAM_64 &ram = (levels % 2 == 0) ? dpram0 : dpram1;

    for (int i=0; i<nFFT; i++) {
        ram.memRead(i, real, imag);
        fprintf(fp, "%f %f\n", real/32768.0, imag/32768.0);
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
