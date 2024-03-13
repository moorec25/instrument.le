#ifndef TWIDDLE_ROM_H
#define TWIDDLE_ROM_H

#include "fft_common.h"

class TwiddleRom {
    
    private:
        uint16_t num_twiddles;
        uint64_t * twiddles;
        void generateTwiddles();
        bool m_inverse;
    public:
        TwiddleRom(uint16_t size, bool inverse=false);
        ~TwiddleRom();
        void readTwiddle(uint16_t address, int16_t &real, int32_t &sum, int32_t &diff);
};

#endif
