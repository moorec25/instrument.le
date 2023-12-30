#include "twiddle_rom.h"

TwiddleRom::TwiddleRom(uint16_t size) {

    // Size must be a power of 2
    assert(std::ceil(log2(size)) == std::floor(log2(size)));

    num_twiddles = size;
    twiddles = new uint32_t[size];

    generateTwiddles();
}

TwiddleRom::~TwiddleRom() {
    delete twiddles;
}

void TwiddleRom::generateTwiddles() {

    double pi = 2 * std::acos(0.0);

    for (int k=0; k<num_twiddles; k++) {
        double real = std::cos(-1*pi*k/num_twiddles);
        double imag = std::sin(-1*pi*k/num_twiddles);
        
        // Store complex number as two 16 bit ints
        uint16_t real_int = (real > 0) ? real * INT16_MAX : real * (INT16_MAX+1);
        uint16_t imag_int = (imag > 0) ? imag * INT16_MAX : imag * (INT16_MAX+1);
        twiddles[k] = ((uint32_t) real_int << 16) & 0xffff0000;
        twiddles[k] |= ((uint32_t) imag_int) & 0x0000ffff;
        printf("%x\n", twiddles[k]);
    }
}

void TwiddleRom::readTwiddle(uint16_t address, int16_t &real, int16_t &imag) {
    
    assert(address < num_twiddles);

    uint32_t twiddle = twiddles[address];

    real = (int16_t) ((twiddle & 0xffff0000) >> 16);
    imag = (int16_t) (twiddle & 0x0000ffff);
}

