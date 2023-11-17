#include "dualport.h"

DPRAM_64::DPRAM_64(uint16_t size) {

    // Size must be a power of 2
    assert(std::ceil(log2(size)) == std::floor(log2(size)));

    words = size;

    ram = new uint64_t[size];

    for (int i=0; i<size; i++) {
        ram[i] = 0;
    }
}

DPRAM_64::~DPRAM_64() {
    delete ram;
}

void DPRAM_64::memRead(uint16_t address, uint32_t &real, uint32_t &imag) {
    
    assert(address < words);

    uint64_t value = ram[address];

    real = (uint32_t) ((value & 0xffffffff00000000) >> 32);
    imag = (uint32_t) (value & 0x00000000ffffffff);
}


void DPRAM_64::memWrite(uint16_t address, uint32_t real, uint32_t imag) {
    
    assert(address < words);

    ram[address] = (((uint64_t) real) << 32 & 0xffffffff00000000);
    ram[address] = (((uint64_t) real) & 0x00000000ffffffff);
}
