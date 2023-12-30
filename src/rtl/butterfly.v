`include "fft_defs.vh"

module butterfly(/*AUTOARG*/
   // Outputs
   fft_wdataa, fft_wdatab,
   // Inputs
   clk, fft_rdataa, fft_rdatab, twiddle
   );

    parameter DATA_WIDTH = 64;
    parameter TWIDDLE_WIDTH = 32;
    localparam DELAY_PIPE = 4;

    input clk;

    // TODO find optimal bit width for samples
    input [DATA_WIDTH-1:0] fft_rdataa;
    input [DATA_WIDTH-1:0] fft_rdatab;

    input [TWIDDLE_WIDTH-1:0] twiddle;

    output [DATA_WIDTH:0] fft_wdataa;
    output [DATA_WIDTH:0] fft_wdatab;

    reg [DATA_WIDTH-1:0] in1_q [DELAY_PIPE-1:0];

    wire signed [DATA_WIDTH/2-1:0] in1_real_delayed;
    wire signed [DATA_WIDTH/2-1:0] in1_imag_delayed;

    assign {in1_real_delayed, in1_imag_delayed} = in1_q[DELAY_PIPE-1];

    wire signed [DATA_WIDTH/2-1:0] in2_real;
    wire signed [DATA_WIDTH/2-1:0] in2_imag;

    assign {in2_real, in2_imag} = fft_rdatab;

    wire [TWIDDLE_WIDTH/2-1:0] twiddle_real;
    wire [TWIDDLE_WIDTH/2-1:0] twiddle_imag;

    assign {twiddle_real, twiddle_imag} = twiddle;

    wire signed [DATA_WIDTH/2-1:0] twiddle_mult_real;
    wire signed [DATA_WIDTH/2-1:0] twiddle_mult_imag; 

    reg signed [DATA_WIDTH/2-1:0] out1_real;
    reg signed [DATA_WIDTH/2-1:0] out1_imag;

    reg signed [DATA_WIDTH/2-1:0] out2_real;
    reg signed [DATA_WIDTH/2-1:0] out2_imag;

    assign fft_wdataa = {out1_real, out1_imag};
    assign fft_wdatab = {out2_real, out2_imag};

    integer i;
    always @ (posedge clk) begin
        in1_q[0] <= fft_rdataa;
        for (i=0; i<DELAY_PIPE-1; i=i+1) begin
            in1_q[i+1] <= in1_q[i];
        end
    end

    always @ (posedge clk) begin
        out1_real <= in1_real_delayed + twiddle_mult_real;
        out1_imag <= in1_imag_delayed + twiddle_mult_imag;

        out2_real <= in1_real_delayed - twiddle_mult_real;
        out2_imag <= in1_imag_delayed - twiddle_mult_imag;
    end

    twiddle_multiplier m0
    (   
      // Outputs
     .out_real				(twiddle_mult_real),
     .out_imag				(twiddle_mult_imag),
     // Inputs
     .clk				(clk),
     .in_real				(in2_real),
     .in_imag				(in2_imag),
     .twiddle_real			(twiddle_real),
     .twiddle_imag			(twiddle_imag)
     );

endmodule
