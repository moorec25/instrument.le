`include "fft_defs.vh"

interface mem_mux_if_t(/*AUTOARG*/
   // Inputs
   clk, fft_waddra, fft_waddrb, fft_wdataa, fft_wdatab, fft_wea, fft_web,
   wmem_id
   );

    parameter FFT_SIZE = 4096;
    parameter DATA_WIDTH = 64;

    input clk;
    input [`ADDR_WIDTH-1:0] fft_waddra;
    input [`ADDR_WIDTH-1:0] fft_waddrb;
    input [DATA_WIDTH-1:0] fft_wdataa;
    input [DATA_WIDTH-1:0] fft_wdatab;
    input fft_wea;
    input fft_web;
    input wmem_id;

endinterface
