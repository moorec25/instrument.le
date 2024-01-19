`include "fft_defs.vh"
`define MULT_WIDTH DATA_WIDTH/2 + TWIDDLE_WIDTH/2

// Performs complex multiplication between twiddle factor and input
// 3 cycle latency
module twiddle_multiplier(/*AUTOARG*/
   // Outputs
   out_real, out_imag,
   // Inputs
   clk, in_real, in_imag, twiddle_real, twiddle_sum, twiddle_diff
   );

    parameter DATA_WIDTH = 44;
    parameter TWIDDLE_WIDTH = 50;

    input clk;

    input signed [DATA_WIDTH/2-1:0] in_real;
    input signed [DATA_WIDTH/2-1:0] in_imag;

    input signed [15:0] twiddle_real;
    input signed [16:0] twiddle_sum;
    input signed [16:0] twiddle_diff;

    output signed [DATA_WIDTH/2-1:0] out_real;
    output signed [DATA_WIDTH/2-1:0] out_imag;

    reg signed [DATA_WIDTH/2-1:0] in_real_q0;
    reg signed [DATA_WIDTH/2-1:0] in_imag_q0;

    reg signed [DATA_WIDTH/2-1:0] in_real_q1;
    reg signed [DATA_WIDTH/2-1:0] in_imag_q1;

    reg signed [15:0] twiddle_real_q0;

    reg signed [15:0] twiddle_real_q1;

    reg signed [DATA_WIDTH/2:0] pre_add0_q;
    reg signed [16:0] twiddle_sum_q0;
    reg signed [16:0] twiddle_diff_q0;
    reg signed [16:0] twiddle_sum_q1;
    reg signed [16:0] twiddle_diff_q1;

    reg signed [47:0] mult0_q;
    reg signed [47:0] mult1_q;
    reg signed [47:0] mult2_q;

    reg signed [47:0] post_add0_q;
    reg signed [47:0] post_add1_q;

    assign out_real = post_add0_q[36:15];
    assign out_imag = post_add1_q[36:15];

    always @ (posedge clk) begin
        in_real_q0 <= in_real;
        in_imag_q0 <= in_imag;
        in_real_q1 <= in_real_q0;
        in_imag_q1 <= in_imag_q0;

        twiddle_real_q0 <= twiddle_real;
        twiddle_real_q1 <= twiddle_real_q0;

        twiddle_diff_q0 <= twiddle_diff;
        twiddle_sum_q0 <= twiddle_sum;
        twiddle_diff_q1 <= twiddle_diff_q0;
        twiddle_sum_q1 <= twiddle_sum_q0;
    end

    always @ (posedge clk) begin
        pre_add0_q <= in_real_q0 + in_imag_q0;
    end

    always @ (posedge clk) begin
        mult0_q <= twiddle_real_q1 * pre_add0_q;
        mult1_q <= in_real_q1 * twiddle_diff_q1;
        mult2_q <= in_imag_q1 * twiddle_sum_q1;
    end

    always @ (posedge clk) begin
        post_add0_q <= mult0_q - mult2_q;
        post_add1_q <= mult0_q + mult1_q;
    end

endmodule
