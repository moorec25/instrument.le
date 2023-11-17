#include "fft.h"

int main (int argc, char *argv[]) {
    
    fftTop();

    return 0;
}

void fftTop() {

    TwiddleRom twiddles(N_TWIDDLES);
    
    DPRAM_64 dpram0(N_FFT);
    DPRAM_64 dpram1(N_FFT);

    uint8_t readingRam = 0;
    uint8_t writingRam = 1;

    uint8_t levels = (uint8_t) std::log2(N_FFT);

    uint32_t addr1, addr2;
    uint32_t real1, imag1, real2, imag2;
    uint16_t twiddleReal, twiddleImag, twiddleAddr, twiddleMask;
    int32_t bflyOutReal1, bflyOutImag1, bflyOutReal2, bflyOutImag2;

    for (int i=0; i<levels; i++) {
        for (int j=0; j<N_FFT/2; j++) {

            addr1 = j << 1;
            addr2 = addr1 + 1;
            rotateLeft(addr1, i, levels);
            rotateLeft(addr2, i, levels);
            bitReverse(addr1, levels);
            bitReverse(addr2, levels);

            calcTwiddleMask(twiddleMask, i, levels); 
            twiddleAddr = twiddleMask & (N_FFT/2-1) & j;

            if (readingRam == 0) {
                dpram0.memRead(addr1, real1, imag1);
                dpram0.memRead(addr1, real2, imag2);
            } else {
                dpram1.memRead(addr1, real1, imag1);
                dpram1.memRead(addr1, real2, imag2);
            }

            twiddles.readTwiddle(twiddleAddr, twiddleReal, twiddleImag);

            butterfly(real1, imag1, real2, imag2, twiddleReal, twiddleImag, bflyOutReal1, bflyOutImag1, bflyOutReal2, bflyOutImag2);

            if (writingRam == 0) {
                dpram0.memWrite(addr1, bflyOutReal1, bflyOutImag1);
                dpram0.memWrite(addr2, bflyOutReal2, bflyOutImag2);
            } else {
                dpram0.memWrite(addr1, bflyOutReal1, bflyOutImag1);
                dpram0.memWrite(addr2, bflyOutReal2, bflyOutImag2);
            }
        } 
        readingRam = (readingRam == 0) ? 1 : 0;
        writingRam = (writingRam == 0) ? 1 : 0;
    }
}

void butterfly(int32_t inReal1, int32_t inImag1, int32_t inReal2, int32_t inImag2, uint16_t twiddleReal, uint16_t twiddleImag, int32_t &outReal1, int32_t &outImag1, int32_t &outReal2, int32_t &outImag2) {

    int32_t twiddleMultReal;
    int32_t twiddleMultImag;

    complexMultiply(inReal2, inImag2, twiddleReal, twiddleImag, twiddleMultReal, twiddleMultImag);

    outReal1 = (twiddleMultReal / 32768) + inReal1;
    outImag1 = (twiddleMultImag / 32768) + inImag1;

    outReal2 = inReal1 - (twiddleMultReal / 32768);
    outImag2 = inImag1 - (twiddleMultImag / 32768);
}

void complexMultiply(int32_t inReal1, int32_t inImag1, int32_t inReal2, int32_t inImag2, int32_t &outReal, int32_t &outImag) {

    // Multiply two complex numbers using 3 multipliers
    
    int32_t K1 = inReal2 * (inReal1 + inImag1);
    int32_t K2 = inReal1 * (inImag2 - inReal2);
    int32_t K3 = inImag1 * (inReal2 + inImag2);

    outReal = K1 - K3;
    outImag = K1 + K2;
}

void rotateLeft(uint32_t &x, uint32_t y, uint8_t N) {
    
    uint32_t mask = 1;

    for (int i=0; i < (N-1); i++) {
        mask |= (1 << i);
    }

    x = ((x << y%N) | (x >> (N - y%N))) & mask;
    
}

void bitReverse(uint32_t &x, uint8_t N) {
    
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

void calcTwiddleMask(uint16_t &mask, uint8_t level, uint8_t N) {
    
    mask = UINT16_MAX;

    for (int i=0; i<N-level; i++) {
        mask ^= (1 << i);
    }

}
