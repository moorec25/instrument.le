#include "twiddle_rom.h"

TwiddleRom::TwiddleRom(uint16_t size) {

    // Size must be a power of 2
    assert(std::ceil(log2(size)) == std::floor(log2(size)));

    num_twiddles = size;
    twiddles = new uint64_t[size];

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
        uint32_t real_int = (real > 0) ? real * INT16_MAX : real * (INT16_MAX+1);
        uint32_t imag_int = (imag > 0) ? imag * INT16_MAX : imag * (INT16_MAX+1);
        uint32_t sum = real_int + imag_int;
        uint32_t diff = imag_int - real_int;

        twiddles[k] = ((uint64_t) real_int << 34) & 0x0003fffc00000000;
        twiddles[k] |= ((uint64_t) sum << 17)     & 0x00000003fffe0000;
        twiddles[k] |= ((uint64_t) diff)          & 0x000000000001ffff;
    }
}

void TwiddleRom::readTwiddle(uint16_t address, int16_t &real, int32_t &sum, int32_t &diff) {
    
    assert(address < num_twiddles);

    uint64_t twiddle = twiddles[address];

    real = (int16_t) ((twiddle & 0x0003fffc00000000) >> 34);
    sum = (int32_t) (((twiddle & 0x3fffe0000) >> 17) | ((twiddle & 0x200000000) ? 0xfffe0000 : 0));
    diff = (int32_t) ((twiddle & 0x1ffff) | ((twiddle & 0x10000) ? 0xfffe0000 : 0));

}

