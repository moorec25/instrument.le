#include "fft.h"

int main (int argc, char *argv[]) {
    
    if (argc != 3) {
        std::cout << "Usage: ./fft <fft size> <path to test output>\n";
        exit(1);
    }
    
    char in_file_name[] = "/fft_in.txt";
    char out_file_name[] = "/fft_out_c.txt";
    char *test_path = argv[2];

    char *in_file_path = NULL;
    char *out_file_path = NULL;

    in_file_path = (char *) malloc(strlen(test_path) + strlen(in_file_name) + 1);
    out_file_path = (char *) malloc(strlen(test_path) + strlen(out_file_name) + 1);

    sprintf(in_file_path, "%s%s", test_path, in_file_name);
    sprintf(out_file_path, "%s%s", test_path, out_file_name);

    FILE * input_file = fopen(in_file_path, "r");
    FILE * output_file = fopen(out_file_path, "w");

    uint16_t fftSize = std::strtol(argv[1], NULL, 10);

    FFT fft = FFT(fftSize);

    fft.loadRam(input_file);

    // Perform FFT
    fft.calcFFT();

    // Write to output file
    fft.writeOutput(output_file);

    fclose(input_file);
    fclose(output_file);
    
    return 0;
}

