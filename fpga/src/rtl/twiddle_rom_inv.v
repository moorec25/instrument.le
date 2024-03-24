`include "fft_defs.vh"

module twiddle_rom_inv(/*AUTOARG*/
   // Outputs
   twiddle,
   // Inputs
   clk, twiddle_addr
   );

    parameter FFT_SIZE = 4096;

    input clk;
    input [$clog2(`NUM_TWIDDLES)-1:0] twiddle_addr;
    output [`TWIDDLE_WIDTH-1:0] twiddle;

    rom1p50x2048 rom
    (
        .addra(twiddle_addr),
        .clka(clk),
        .douta(twiddle)
    );

endmodule
