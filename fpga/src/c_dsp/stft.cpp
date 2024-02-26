#include "fft.h"
#include "fft_common.h"
#include <cstdio>
#include <cstdlib>

void output_trace(FILE * output_file, int32_t * real, int32_t * imag, int n);
void shift_input(FILE * input_file, int16_t * input_buffer, uint16_t fft_size, uint16_t hop_size);
void load_window (FILE * window_file, int16_t * window, int n);
void window_mult(int16_t * input, int16_t * output, int16_t * window, int n);

int main (int argc, char *argv[]) {
    
    if (argc != 4) {
        std::cout << "Usage: ./stft <fft size> <hop_size> <path to test output>\n";
        exit(1);
    }
   
    char in_file_name[] = "/stft_in.txt";
    char out_file_name[] = "/stft_out_c.txt";
    char window_file_name[] = "/window.txt";
    char *test_path = argv[3];

    char *in_file_path = NULL;
    char *out_file_path = NULL;
    char *window_file_path = NULL;

    in_file_path = (char *) malloc(strlen(test_path) + strlen(in_file_name) + 1);
    out_file_path = (char *) malloc(strlen(test_path) + strlen(out_file_name) + 1);
    window_file_path = (char *) malloc(strlen(test_path) + strlen(window_file_name) + 1);

    sprintf(in_file_path, "%s%s", test_path, in_file_name);
    sprintf(out_file_path, "%s%s", test_path, out_file_name);
    sprintf(window_file_path, "%s%s", test_path, window_file_name);

    printf("%s\n", in_file_path);

    FILE * input_file = fopen(in_file_path, "r");
    FILE * output_file = fopen(out_file_path, "w");
    FILE * window_file = fopen(window_file_path, "r");

    uint16_t fftSize = std::strtol(argv[1], NULL, 10);
    uint16_t hopSize = std::strtol(argv[2], NULL, 10);

    FFT fft = FFT(fftSize);

#ifdef FFT_TRACE_EN
    char mem_wr_trace_name[] = "/fft_mem_wr_trace.txt";
    char *mem_wr_trace_path = (char *) malloc(strlen(test_path) + strlen(mem_wr_trace_name) + 1);
    sprintf(mem_wr_trace_path, "%s%s", test_path, mem_wr_trace_name);
    fft.fp_mem_wr_trace = fopen(mem_wr_trace_path, "w");
#endif

    int16_t * input_buffer = new int16_t[fftSize];
    int16_t * windowed_input = new int16_t[fftSize];
    int32_t * output_buffer_r = new int32_t[fftSize / 2 + 1];
    int32_t * output_buffer_i = new int32_t[fftSize / 2 + 1];
    int16_t * window = new int16_t[fftSize];
    
    load_window(window_file, window, fftSize);

    for (int i=0; i<fftSize; i++) {
        uint16_t sample;
        fscanf(input_file, "%hd", &sample);
        input_buffer[i] = sample;
    }


    while (!feof(input_file)) {
    
        window_mult(input_buffer, windowed_input, window, fftSize);
        fft.loadRam(windowed_input);

        // Perform FFT
        fft.calcFFT();

        // Write to output file
        fft.writeOutput(output_buffer_r, output_buffer_i, true);

        output_trace(output_file, output_buffer_r, output_buffer_i, fftSize / 2 + 1);
        shift_input(input_file, input_buffer, fftSize, hopSize);
    }

    fclose(input_file);
    fclose(output_file);
    
    return 0;
}

void output_trace(FILE * output_file, int32_t * real, int32_t * imag, int n) {
    for (int i=0; i<n; i++) {
        fprintf(output_file, "%f %f\n", real[i] / 32768.0, imag[i] / 32768.0);
    }
}

void shift_input(FILE * input_file, int16_t * input_buffer, uint16_t fft_size, uint16_t hop_size) {
    
    int overlap = fft_size - hop_size;
    for (int i=0; i<overlap; i++) {
        input_buffer[i] = input_buffer[i + hop_size];
    }

    int16_t sample;
    for (int i=overlap; i<fft_size; i++) {
        fscanf(input_file, "%hd", &sample);
        input_buffer[i] = sample;
    }
}

void load_window (FILE * window_file, int16_t * window, int n) {
    int16_t sample;
    for (int i=0; i<n; i++) {
        fscanf(window_file, "%hd", &sample);
        window[i] = sample;
    }
}

void window_mult(int16_t * input, int16_t * output, int16_t * window, int n) {
    int32_t product;
    for (int i=0; i<n; i++) {
        product = (int32_t) window[i] * (int32_t) input[i];
        output[i] = (int16_t) ((product >> 15) & 0x0000ffff);
    }
}
