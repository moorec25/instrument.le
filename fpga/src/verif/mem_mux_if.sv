interface mem_mux_if_t(/*AUTOARG*/
   // Inputs
   clk, fft_waddra, fft_waddrb, fft_wdataa, fft_wdatab, fft_wea, fft_web,
   wmem_id
   );

    input clk;
    input [11:0] fft_waddra;
    input [11:0] fft_waddrb;
    input [43:0] fft_wdataa;
    input [43:0] fft_wdatab;
    input fft_wea;
    input fft_web;
    input wmem_id;

endinterface
