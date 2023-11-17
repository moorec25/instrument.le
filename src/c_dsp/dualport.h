#ifndef DUALPORT_H
#define DUALPORT_H

#include "fft_common.h"

class DPRAM_64 {
    
    private:
        uint16_t words;
        uint64_t * ram;

    public:
        DPRAM_64(uint16_t size);
        ~DPRAM_64();
        void memRead(uint16_t address, uint32_t &real, uint32_t &imag);
        void memWrite(uint16_t address, uint32_t real, uint32_t imag);
};

#endif
