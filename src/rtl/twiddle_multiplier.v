`include "fft_defs.vh"

// Performs complex multiplication between twiddle factor and input
// 3 cycle latency
module twiddle_multiplier(/*AUTOARG*/
   // Outputs
   out_real, out_imag,
   // Inputs
   clk, in_real, in_imag, twiddle_real, twiddle_imag
   );

    parameter DATA_WIDTH = 64;
    parameter TWIDDLE_WIDTH = 32;

    input clk;

    input signed [DATA_WIDTH/2-1:0] in_real;
    input signed [DATA_WIDTH/2-1:0] in_imag;

    input signed [TWIDDLE_WIDTH/2-1:0] twiddle_real;
    input signed [TWIDDLE_WIDTH/2-1:0] twiddle_imag;

    output signed [DATA_WIDTH/2-1:0] out_real;
    output signed [DATA_WIDTH/2-1:0] out_imag;

    reg signed [DATA_WIDTH/2-1:0] in_real_q0;
    reg signed [DATA_WIDTH/2-1:0] in_imag_q0;

    reg signed [DATA_WIDTH/2-1:0] in_real_q1;
    reg signed [DATA_WIDTH/2-1:0] in_imag_q1;

    reg signed [TWIDDLE_WIDTH/2-1:0] twiddle_real_q0;
    reg signed [TWIDDLE_WIDTH/2-1:0] twiddle_imag_q0;

    reg signed [TWIDDLE_WIDTH/2-1:0] twiddle_real_q1;

    reg signed [DATA_WIDTH/2:0] pre_add0_q;
    reg signed [TWIDDLE_WIDTH/2:0] pre_add1_q;
    reg signed [TWIDDLE_WIDTH/2:0] pre_add2_q;

    reg signed [DATA_WIDTH/2 + TWIDDLE_WIDTH/2:0] mult0_q;
    reg signed [48:0] mult1_q;
    reg signed [48:0] mult2_q;

    reg signed [48:0] post_add0_q;
    reg signed [48:0] post_add1_q;

    assign out_real = post_add0_q[46:15];
    assign out_imag = post_add1_q[46:15];

    always @ (posedge clk) begin
        in_real_q0 <= in_real;
        in_imag_q0 <= in_imag;
        in_real_q1 <= in_real_q0;
        in_imag_q1 <= in_imag_q0;

        twiddle_real_q0 <= twiddle_real;
        twiddle_imag_q0 <= twiddle_imag;
        twiddle_real_q1 <= twiddle_real_q0;
    end

    always @ (posedge clk) begin
        pre_add0_q <= in_real_q0 + in_imag_q0;
        pre_add1_q <= twiddle_imag_q0 - twiddle_real_q0;
        pre_add2_q <= twiddle_real_q0 + twiddle_imag_q0;
    end

    always @ (posedge clk) begin
        mult0_q <= twiddle_real_q1 * pre_add0_q;
        mult1_q <= in_real_q1 * pre_add1_q;
        mult2_q <= in_imag_q1 * pre_add2_q;
    end

    always @ (posedge clk) begin
        post_add0_q <= mult0_q - mult2_q;
        post_add1_q <= mult0_q + mult1_q;
    end

endmodule
