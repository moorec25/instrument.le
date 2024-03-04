#include "stft.h"
#include <cstdio>
#include <cstdlib>

int main (int argc, char *argv[]) {
    
    if (argc != 5) {
        std::cout << "Usage: ./stft <fft size> <hop_size> <channels> <path to test output>\n";
        exit(1);
    }
   
    uint16_t fftSize = std::strtol(argv[1], NULL, 10);
    uint16_t hopSize = std::strtol(argv[2], NULL, 10);
    uint8_t channels = std::atoi(argv[3]);
    char *test_path = argv[4];

    if (channels != 1 && channels != 2) {
        std::cout << "Must be 1 or 2 channels" << std::endl;
    }

    for (int i=0; i<channels; i++) {

        char in_file_path[200];
        char out_file_path[200];
        char window_file_path[200];

        sprintf(in_file_path, "%s%s_%d.txt", test_path, "/stft_in", i);
        sprintf(out_file_path, "%s%s_%d.txt", test_path, "/stft_out_c", i);
        sprintf(window_file_path, "%s%s.txt", test_path, "/window");

        FILE * input_file = fopen(in_file_path, "r");
        FILE * output_file = fopen(out_file_path, "w");
        FILE * window_file = fopen(window_file_path, "r");

        STFT stft = STFT(fftSize, hopSize, input_file, output_file, window_file);

#ifdef FFT_TRACE_EN
        char mem_wr_trace_path[200];
        sprintf(mem_wr_trace_path, "%s%s_%d.txt", test_path, "/fft_mem_wr_trace", i);
        stft.fft.fp_mem_wr_trace = fopen(mem_wr_trace_path, "w");
#endif
        stft.calcSTFT();

        fclose(input_file);
        fclose(output_file);
        fclose(window_file);
    }
    return 0;
}

STFT::STFT(uint16_t fftSize, uint16_t hopSize, FILE * input, FILE * output, FILE * window_file) :
    fftSize(fftSize),
    hopSize(hopSize),
    fft(fftSize) 
{
    STFT::input_file = input;
    STFT::output_file = output;
    STFT::window_file = window_file;
    STFT::input_buffer = new int16_t[fftSize];
    STFT::windowed_input = new int16_t[fftSize];
    STFT::output_buffer_r = new int32_t[fftSize / 2 + 1];
    STFT::output_buffer_i = new int32_t[fftSize / 2 + 1];
    STFT::window = new int16_t[fftSize];
    load_window();
}

STFT::~STFT() {
    delete input_buffer;
    delete windowed_input;
    delete output_buffer_r;
    delete output_buffer_i;
    delete window;
}

void STFT::calcSTFT() {

    for (int i=0; i<fftSize; i++) {
        uint16_t sample;
        fscanf(input_file, "%hd", &sample);
        input_buffer[i] = sample;
    }


    while (!feof(input_file)) {

        window_mult();
        fft.loadRam(windowed_input);

        // Perform FFT
        fft.calcFFT();

        // Write to output file
        fft.writeOutput(output_buffer_r, output_buffer_i, true);

        output_trace();
        shift_input();
    }

}

void STFT::output_trace() {
    int n = fftSize/2 + 1;
    for (int i=0; i<n; i++) {
        fprintf(output_file, "%d %d\n", output_buffer_r[i], output_buffer_i[i]);
    }
}

void STFT::shift_input() {
    
    int overlap = fftSize - hopSize;
    for (int i=0; i<overlap; i++) {
        input_buffer[i] = input_buffer[i + hopSize];
    }

    int16_t sample;
    for (int i=overlap; i<fftSize; i++) {
        fscanf(input_file, "%hd", &sample);
        input_buffer[i] = sample;
    }
}

void STFT::load_window () {
    int16_t sample;
    for (int i=0; i<fftSize; i++) {
        fscanf(window_file, "%hd", &sample);
        window[i] = sample;
    }
}

void STFT::window_mult() {
    int32_t product;
    for (int i=0; i<fftSize; i++) {
        product = (int32_t) window[i] * (int32_t) input_buffer[i];
        windowed_input[i] = (int16_t) ((product >> 15) & 0x0000ffff);
    }
}
