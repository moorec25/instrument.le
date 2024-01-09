interface fft_ctrl_if_t(/*AUTOARG*/
   // Inputs
   clk, resetn
   );

    input clk;
    input resetn;
    logic fft_go;
    logic fft_busy;

endinterface
