#ifndef TWIDDLE_ROM_H
#define TWIDDLE_ROM_H

#include "fft_common.h"

class TwiddleRom {
    
    private:
        uint16_t num_twiddles;
        uint32_t * twiddles;
        void generateTwiddles();
    public:
        TwiddleRom(uint16_t size);
        ~TwiddleRom();
        void readTwiddle(uint16_t address, uint16_t &real, uint16_t &imag);
};

#endif
