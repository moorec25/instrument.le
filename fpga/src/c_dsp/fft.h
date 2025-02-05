#ifndef FFT_H
#define FFT_H

#include "fft_common.h"
#include "twiddle_rom.h"
#include "dualport.h"

class FFT {

    public:
        FFT(uint16_t size, bool inverse=false);
        void calcFFT();
        const uint16_t nFFT;
        void loadRam(FILE *fp);
        void loadRam(int16_t * samples);
        void loadRam(int32_t * samples_r, int32_t * samples_i);
        void writeOutput(FILE *fp);
        void writeOutput(int32_t * real, int32_t * imag);
        void writeOutput(int32_t * real);
#ifdef FFT_TRACE_EN
        FILE * fp_mem_wr_trace;
#endif

    private:
        TwiddleRom twiddles;
        DPRAM_64 dpram0;
        DPRAM_64 dpram1;
        const uint8_t levels;
        bool m_inverse;

        void butterfly(int32_t inReal1, int32_t inImag1, int32_t inReal2, int32_t inImag2, int32_t twiddleReal, int32_t twiddleSum, int32_t twiddleDiff, int32_t &outReal1, int32_t &outImag1, int32_t &outReal2, int32_t &outImag2);
        void complexMultiply(int32_t inReal1, int32_t inImag1, int32_t twiddleReal, int32_t twiddleSum, int32_t twiddleDiff, int64_t &outReal, int64_t &outImag);
        // Perform a circular left shift on N bit word x by y bits
        void rotateLeft(uint32_t &x, uint32_t y, uint8_t N);
        // Reverse the bits of N bit word x
        void bitReverse(uint32_t &x, uint8_t N);
        void calcTwiddleMask(uint16_t &mask, uint8_t level, uint8_t N);
        int32_t signExtend(uint32_t x, uint8_t N);
        void mem_trace(FILE * fp, uint32_t addra, int32_t wdataa_r, int32_t wdataa_i, uint32_t addrb, int32_t wdatab_r, int32_t wdatab_i, uint16_t wmem_id);

};
#endif
