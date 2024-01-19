`define LEVELS $clog2(FFT_SIZE)
`define DATA_WIDTH 2*(SAMPLE_WIDTH + $clog2(FFT_SIZE)/2)
`define AXI_WIDTH (1 << $clog2(`DATA_WIDTH))
`define BYTE_COUNT `AXI_WIDTH/8
`define ADDR_WIDTH $clog2(FFT_SIZE)
`define NUM_TWIDDLES FFT_SIZE/2
