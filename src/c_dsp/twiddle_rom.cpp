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
        double real = std::cos(pi*k/num_twiddles);
        double imag = std::sin(pi*k/num_twiddles);
        
        // Store complex number as two 16 bit ints
        
        twiddles[k] = ((uint32_t) (real * 32767) << 16) & 0xffff0000;
        twiddles[k] |= ((uint32_t) (imag * 32767)) & 0x0000ffff;
    }
}

void TwiddleRom::readTwiddle(uint16_t address, uint16_t &real, uint16_t &imag) {
    
    assert(address < num_twiddles);

    uint32_t twiddle = twiddles[address];

    real = (uint16_t) ((twiddle & 0xffff0000) >> 16);
    imag = (uint16_t) (twiddle & 0x0000ffff);
}

