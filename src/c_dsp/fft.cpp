#include "fft.h"

int main (int argc, char *argv[]) {
    
    TwiddleRom twiddles(N_TWIDDLES);

    uint16_t real = 0;
    uint16_t imag = 0;

    for (int i=0; i<N_TWIDDLES; i++) {
        twiddles.readTwiddle(i, real, imag); 
        printf("Real value: 0x%16x Imaginary value: 0x%16x \n", real, imag);
    }
    return 0;
}
