#ifndef STFT_H
#define STFT_H

#include "fft.h"
#include "fft_common.h"

class STFT {

    public:
        STFT(uint16_t fftSize, uint16_t hopSize, FILE * input, FILE * output, FILE * window);
        ~STFT();
        const uint16_t fftSize;
        const uint16_t hopSize;
        void calcSTFT();
    
    private:
        void output_trace();
        void shift_input();
        void load_window ();
        void window_mult();

        FFT fft;
        FILE * input_file;
        FILE * output_file;
        FILE * window_file;
        int16_t * input_buffer;
        int16_t * windowed_input;
        int32_t * output_buffer_r;
        int32_t * output_buffer_i;
        int16_t * window;
        
};

#endif

