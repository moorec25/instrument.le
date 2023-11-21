#include "fft.h"

int main (int argc, char *argv[]) {
    
    
    if (argc != 2) {
        std::cout << "Usage: ./fft <path to test output>\n";
        exit(1);
    }
    
    char in_file_name[] = "/fft_in.txt";
    char out_file_name[] = "/fft_out_c.txt";
    char *test_path = argv[1];

    char *in_file_path = NULL;
    char *out_file_path = NULL;

    in_file_path = (char *) malloc(strlen(test_path) + strlen(in_file_name) + 1);
    out_file_path = (char *) malloc(strlen(test_path) + strlen(out_file_name) + 1);

    sprintf(in_file_path, "%s%s", test_path, in_file_name);
    sprintf(out_file_path, "%s%s", test_path, out_file_name);

    FILE * input_file = fopen(in_file_path, "r");
    FILE * output_file = fopen(out_file_path, "w");

    // Instantiate RAM
    
    DPRAM_64 dpram0(N_FFT);
    DPRAM_64 dpram1(N_FFT);

    loadRam(input_file, dpram0);

    // Perform FFT
    fftTop(dpram0, dpram1);

    // Write to output file
    uint8_t levels = (uint8_t) std::log2(N_FFT);
    if (levels % 2 == 0) {
        writeOutput(output_file, dpram0);
    } else {
        writeOutput(output_file, dpram1);
    }

    fclose(input_file);
    fclose(output_file);
    
    return 0;
}

void fftTop(DPRAM_64 &dpram0, DPRAM_64 &dpram1) {

    TwiddleRom twiddles(N_TWIDDLES);
    

    uint8_t readingRam = 0;
    uint8_t writingRam = 1;

    uint8_t levels = (uint8_t) std::log2(N_FFT);

    uint32_t addr1, addr2, addr1Rev, addr2Rev;
    int32_t real1, imag1, real2, imag2;
    uint16_t twiddleAddr, twiddleMask;
    int16_t twiddleReal, twiddleImag;
    int32_t bflyOutReal1, bflyOutImag1, bflyOutReal2, bflyOutImag2;

    for (int i=0; i<levels; i++) {
        for (int j=0; j<N_FFT/2; j++) {

            addr1 = j << 1;
            addr2 = addr1 + 1;
            rotateLeft(addr1, i, levels);
            rotateLeft(addr2, i, levels);

            calcTwiddleMask(twiddleMask, i, levels-1); 
            twiddleAddr = twiddleMask & (N_FFT/2-1) & j;

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

void butterfly(int32_t inReal1, int32_t inImag1, int32_t inReal2, int32_t inImag2, int32_t twiddleReal, int32_t twiddleImag, int32_t &outReal1, int32_t &outImag1, int32_t &outReal2, int32_t &outImag2) {

    int64_t twiddleMultReal;
    int64_t twiddleMultImag;

    complexMultiply(inReal2, inImag2, twiddleReal, twiddleImag, twiddleMultReal, twiddleMultImag);

    outReal1 = (twiddleMultReal >> 15) + inReal1;
    outImag1 = (twiddleMultImag >> 15) + inImag1;

    outReal2 = inReal1 - (twiddleMultReal >> 15);
    outImag2 = inImag1 - (twiddleMultImag >> 15);
}

void complexMultiply(int32_t inReal1, int32_t inImag1, int32_t inReal2, int32_t inImag2, int64_t &outReal, int64_t &outImag) {

    // Multiply two complex numbers using 3 multipliers
    
    int64_t K1 = (int64_t) inReal2 * (int64_t)(inReal1 + inImag1);
    int64_t K2 = (int64_t)inReal1 * (int64_t)(inImag2 - inReal2);
    int64_t K3 = (int64_t)inImag1 * (int64_t)(inReal2 + inImag2);

    outReal = K1 - K3;
    outImag = K1 + K2;
}

void rotateLeft(uint32_t &x, uint32_t y, uint8_t N) {
    
    uint32_t mask = 1;

    for (int i=1; i < N; i++) {
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

void loadRam(FILE *fp, DPRAM_64 &ram) {
    
    uint16_t sample;

    for (int i=0; i<N_FFT; i++) {
        fscanf(fp, "%hd", &sample);
        ram.memWrite(i, signExtend(sample, 16), 0);
    }
}

void writeOutput(FILE *fp, DPRAM_64 &ram) {

    int32_t real, imag;

    for (int i=0; i<N_FFT; i++) {
        ram.memRead(i, real, imag); 
        fprintf(fp, "%f %f\n", real/32768.0, imag/32768.0);
    }

}

int32_t signExtend(uint32_t x, uint8_t N) {
    
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
