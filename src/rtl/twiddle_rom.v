`include "fft_defs.vh"

module twiddle_rom(/*AUTOARG*/
   // Outputs
   twiddle,
   // Inputs
   clk, twiddle_addr
   );

    parameter FFT_SIZE = 4096;
    parameter TWIDDLE_WIDTH = 32;

    input clk;
    input [$clog2(`NUM_TWIDDLES)-1:0] twiddle_addr;
    output [TWIDDLE_WIDTH-1:0] twiddle;

    rom1p32x4096 rom
    (
        .addra({9'b0, twiddle_addr}),
        .clka(clk),
        .douta(twiddle)
    );

endmodule
