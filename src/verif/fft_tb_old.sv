`include "../../sources_1/new/fft_defs.vh"

module fft_tb;

    parameter FFT_SIZE=4096;
    parameter DATA_WIDTH=64;
    parameter TWIDDLE_WIDTH=32;
    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire		fft_busy;		// From fft of fft_wrapper.v
    wire [DATA_WIDTH-1:0] m_axis_tdata;		// From fft of fft_wrapper.v
    wire [`BYTE_COUNT-1:0] m_axis_tkeep;	// From fft of fft_wrapper.v
    wire		m_axis_tlast;		// From fft of fft_wrapper.v
    wire		m_axis_tvalid;		// From fft of fft_wrapper.v
    wire		s_axis_tready;		// From fft of fft_wrapper.v
    // End of automatics
    /*AUTOREGINPUT*/
    // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
    reg			clk;			// To fft of fft_wrapper.v
    reg			fft_go;			// To fft of fft_wrapper.v
    reg			m_axis_tready;		// To fft of fft_wrapper.v
    reg			reset;			// To fft of fft_wrapper.v
    reg [DATA_WIDTH-1:0] s_axis_tdata;		// To fft of fft_wrapper.v
    reg [`BYTE_COUNT-1:0] s_axis_tkeep;		// To fft of fft_wrapper.v
    reg			s_axis_tlast;		// To fft of fft_wrapper.v
    reg			s_axis_tvalid;		// To fft of fft_wrapper.v
    // End of automatics

    fft_wrapper #(/*AUTOINSTPARAM*/
		  // Parameters
		  .FFT_SIZE		(FFT_SIZE),
		  .DATA_WIDTH		(DATA_WIDTH),
		  .TWIDDLE_WIDTH	(TWIDDLE_WIDTH)) fft
    (/*AUTOINST*/
     // Outputs
     .fft_busy				(fft_busy),
     .m_axis_tdata			(m_axis_tdata[DATA_WIDTH-1:0]),
     .m_axis_tkeep			(m_axis_tkeep[`BYTE_COUNT-1:0]),
     .m_axis_tlast			(m_axis_tlast),
     .m_axis_tvalid			(m_axis_tvalid),
     .s_axis_tready			(s_axis_tready),
     // Inputs
     .clk				(clk),
     .fft_go				(fft_go),
     .m_axis_tready			(m_axis_tready),
     .reset				(reset),
     .s_axis_tdata			(s_axis_tdata[DATA_WIDTH-1:0]),
     .s_axis_tkeep			(s_axis_tkeep[`BYTE_COUNT-1:0]),
     .s_axis_tlast			(s_axis_tlast),
     .s_axis_tvalid			(s_axis_tvalid));

     initial begin
         clk = 1'b1;
         forever #4 clk = ~clk;
     end

     initial begin
         reset = 0;
         fft_go = 0;
         #8
         reset = 1;
         #40
         reset = 0;
         #12
         fft_go = 1;
         #8
         fft_go = 0;
     end

endmodule

// Local Variables:
// verilog-library-flags:("-y ../../sources_1/new/")
// End:
