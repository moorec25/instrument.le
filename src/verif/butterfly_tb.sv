`timescale 1ns / 1ps

module butterfly_tb;

    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire [DATA_WIDTH:0]	fft_wdataa;		// From DUT of butterfly.v
    wire [DATA_WIDTH:0]	fft_wdatab;		// From DUT of butterfly.v
    // End of automatics
    /*AUTOREGINPUT*/
    // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
    reg			clk;			// To DUT of butterfly.v
    reg [DATA_WIDTH-1:0] fft_rdataa;		// To DUT of butterfly.v
    reg [DATA_WIDTH-1:0] fft_rdatab;		// To DUT of butterfly.v
    reg [TWIDDLE_WIDTH-1:0] twiddle;		// To DUT of butterfly.v
    // End of automatics

    butterfly DUT
    (/*AUTOINST*/
     // Outputs
     .fft_wdataa			(fft_wdataa[DATA_WIDTH:0]),
     .fft_wdatab			(fft_wdatab[DATA_WIDTH:0]),
     // Inputs
     .clk				(clk),
     .fft_rdataa			(fft_rdataa[DATA_WIDTH-1:0]),
     .fft_rdatab			(fft_rdatab[DATA_WIDTH-1:0]),
     .twiddle				(twiddle[TWIDDLE_WIDTH-1:0]));

     initial begin
         clk = 1'b1;
         forever #4 clk = ~clk;
     end

     initial begin
         #6
         twiddle = {16'h7fff, 16'h0000};
         in1 = {-32'd2824, 32'd0};
         in2 = {-32'd1256, 32'd0};
         #8
         in1 = {-32'd2477, 32'd0};
         in2 = {-32'd947, 32'd0};
         #8
         in1 = {-32'd4080, 32'd0};
         in2 = {-32'd3424, 32'd0};
         #8 
         twiddle = {16'd0, 16'h8000};
         in1 = {-32'd1568, 32'd0};
         in2 = {-32'd1530, 32'd0};
     end
endmodule

// Local Variables:
// verilog-library-flags:("-y ../../sources_1/new/")
// End:
