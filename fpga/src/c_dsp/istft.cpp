#include "istft.h"

int main (int argc, char *argv[]) {
    
    if (argc != 5) {
        std::cout << "Usage: ./istft <fft size> <hop size> <channels> <trace path>\n";
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

        sprintf(in_file_path, "%s%s_%d.txt", test_path, "/stft_out_c", i);
        sprintf(out_file_path, "%s%s_%d.txt", test_path, "/istft_out_c", i);
        sprintf(window_file_path, "%s%s.txt", test_path, "/window");

        FILE * input_file = fopen(in_file_path, "r");
        FILE * output_file = fopen(out_file_path, "w");
        FILE * window_file = fopen(window_file_path, "r");

        ISTFT istft = ISTFT(fftSize, hopSize, input_file, output_file, window_file);

        istft.calcISTFT();

        fclose(input_file);
        fclose(output_file);
        fclose(window_file);

    }

    return 0;
}

ISTFT::ISTFT(uint16_t fftSize, uint16_t hopSize, FILE * input, FILE * output, FILE * window) : 
    fftSize(fftSize),
    hopSize(hopSize),
    ifft(fftSize, true)
{
    m_input_file = input;
    m_output_file = output;
    m_window_file = window;
    m_window = new int16_t[fftSize];
    m_input_buffer_r = new int32_t[fftSize];
    m_input_buffer_i = new int32_t[fftSize];
    m_output_buffer = new int32_t[fftSize];
    m_overlap = new int32_t[fftSize];
    m_ola_out = new int32_t[hopSize];

    load_window();
}

ISTFT::~ISTFT() {
    delete m_window;
    delete m_input_buffer_r;
    delete m_input_buffer_i;
    delete m_overlap;
    delete m_ola_out;
    delete m_output_buffer;
}

void ISTFT::calcISTFT() {
    
    uint32_t frame = 0;

    while (!load_input_frame()) {

        ifft.loadRam(m_input_buffer_r, m_input_buffer_i);

        ifft.calcFFT();

        ifft.writeOutput(m_output_buffer);

        window_mult();

        overlap_add();

        if (frame != 0) {
            output_trace();
        }
        
        frame++;
    }

    for (int i=0; i<fftSize; i++) {
        fprintf(m_output_file, "%d\n", m_overlap[i]);
    }
}

void ISTFT::overlap_add() {

    for (int i=0; i<hopSize; i++) {
        m_ola_out[i] = m_overlap[i];
    }

    for (int i=0; i<fftSize-hopSize; i++) {
        m_overlap[i] = m_overlap[i+hopSize] + m_output_buffer[i];
    }

    for (int i=fftSize-hopSize; i<fftSize; i++) {
        m_overlap[i] = m_output_buffer[i];
    }
}

bool ISTFT::load_input_frame() {
    int32_t sample_r, sample_i;
    fscanf(m_input_file, "%d %d", &sample_r, &sample_i);
    m_input_buffer_r[0] = sample_r;
    m_input_buffer_i[0] = sample_i;
    for (int i=1; i<fftSize / 2 + 1; i++) {
        fscanf(m_input_file, "%d %d", &sample_r, &sample_i);
        m_input_buffer_r[i] = sample_r;
        m_input_buffer_i[i] = sample_i;
        m_input_buffer_r[fftSize - i] = sample_r;
        m_input_buffer_i[fftSize - i] = -1*sample_i;
    }

    return feof(m_input_file);
}

void ISTFT::load_window() {
    int16_t sample;
    for (int i=0; i<fftSize; i++) {
        fscanf(m_window_file, "%hd", &sample);
        m_window[i] = sample;
    }
}

void ISTFT::window_mult() {
    int32_t product;
    for (int i=0; i<fftSize; i++) {
        product = (int32_t) m_window[i] * m_output_buffer[i];
        m_output_buffer[i] = product >> 15;
    }
}

void ISTFT::output_trace() {
    for (int i=0; i<hopSize; i++) {
        fprintf(m_output_file, "%d\n", m_ola_out[i]);
    }
}
