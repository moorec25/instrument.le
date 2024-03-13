#ifndef ISTFT_H
#define ISTFT_H

#include "fft.h"
#include "fft_common.h"

class ISTFT {

    public:
        ISTFT(uint16_t fftSize, uint16_t hopSize, FILE * input, FILE * output, FILE * window);
        ~ISTFT();
        const uint16_t fftSize;
        const uint16_t hopSize;
        void calcISTFT();
        FFT ifft;

    private:
        void load_window();
        bool load_input_frame();
        void window_mult();
        void overlap_add();
        void output_trace();

        FILE * m_input_file;
        FILE * m_output_file;
        FILE * m_window_file;

        int16_t * m_window;
        int32_t * m_input_buffer_r;
        int32_t * m_input_buffer_i;
        int32_t * m_output_buffer;
        int32_t * m_overlap;
        int32_t * m_ola_out;
};

#endif
