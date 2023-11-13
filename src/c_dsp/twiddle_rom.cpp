#include "fft_common.h"

class TwiddleRom {

    private:
        uint16_t num_twiddles;
        uint32_t * twiddles;        
        void generateTwiddles();

    public:
        TwiddleRom(uint16_t size) {
            num_twiddles = size;
            twiddles = new uint32_t[size];
            for (int i=0; i<num_twiddles; i++) {
                twiddles[i] = 0;
            }
            generateTwiddles();
        }

        void readTwiddle(uint16_t address, uint16_t &real, uint16_t &imag);
};

void TwiddleRom::generateTwiddles() {
    double pi  = 2 * std::acos(0.0);

    for (int k=0; k<num_twiddles/2; k++) {
        double real = std::cos(2*pi*k/num_twiddles);
        double imag = std::sin(2*pi*k/num_twiddles);
        twiddles[k] |= ((uint32_t) (real * 32767) << 16);
        twiddles[k] |= (uint32_t) (imag * 32767);
    }
}

void TwiddleRom::readTwiddle(uint16_t address, uint16_t &real, uint16_t &imag) {
    
    assert(address < num_twiddles);

    uint32_t twiddle = twiddles[address];

    real = (uint16_t) ((twiddle & 0xffff0000) >> 16);
    imag = (uint16_t) (twiddle & 0x0000ffff);
}
