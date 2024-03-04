`include "fft_defs.vh"

module stft_wrapper (/*AUTOARG*/
   // Outputs
   s_axis_tready, m_axis_tvalid, m_axis_tlast, m_axis_tkeep,
   m_axis_tdata, fft_busy,
   // Inputs
   s_axis_tvalid, s_axis_tlast, s_axis_tkeep, s_axis_tdata, reset,
   m_axis_tready, fft_go, clk
   );

    parameter FFT_SIZE = 4096;
    parameter SAMPLE_WIDTH = 16;
    parameter REAL_INPUT = 1;

    /*AUTOINPUT*/
    // Beginning of automatic inputs (from unused autoinst inputs)
    input		clk;			// To stft_window of sliding_window.v, ...
    input		fft_go;			// To fft of fft_wrapper.v
    input		m_axis_tready;		// To fft of fft_wrapper.v
    input		reset;			// To stft_window of sliding_window.v, ...
    input [`IN_AXI_WIDTH-1:0] s_axis_tdata;	// To stft_window of sliding_window.v
    input [`IN_BYTE_COUNT-1:0] s_axis_tkeep;	// To stft_window of sliding_window.v
    input		s_axis_tlast;		// To stft_window of sliding_window.v
    input		s_axis_tvalid;		// To stft_window of sliding_window.v
    // End of automatics
    /*AUTOOUTPUT*/
    // Beginning of automatic outputs (from unused autoinst outputs)
    output		fft_busy;		// From fft of fft_wrapper.v
    output [`OUT_AXI_WIDTH-1:0] m_axis_tdata;	// From fft of fft_wrapper.v
    output [`OUT_BYTE_COUNT-1:0] m_axis_tkeep;	// From fft of fft_wrapper.v
    output		m_axis_tlast;		// From fft of fft_wrapper.v
    output		m_axis_tvalid;		// From fft of fft_wrapper.v
    output		s_axis_tready;		// From stft_window of sliding_window.v
    // End of automatics
    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire [`IN_AXI_WIDTH-1:0] axis_win2fft_tdata;// From stft_window of sliding_window.v
    wire [`IN_BYTE_COUNT-1:0] axis_win2fft_tkeep;// From stft_window of sliding_window.v
    wire		axis_win2fft_tlast;	// From stft_window of sliding_window.v
    wire		axis_win2fft_tready;	// From fft of fft_wrapper.v
    wire		axis_win2fft_tvalid;	// From stft_window of sliding_window.v
    // End of automatics

    sliding_window  #(/*AUTOINSTPARAM*/
		      // Parameters
		      .FFT_SIZE		(FFT_SIZE),
		      .SAMPLE_WIDTH	(SAMPLE_WIDTH)) stft_window
    (/*AUTOINST*/
     // Outputs
     .s_axis_tready			(s_axis_tready),
     .axis_win2fft_tvalid		(axis_win2fft_tvalid),
     .axis_win2fft_tlast		(axis_win2fft_tlast),
     .axis_win2fft_tdata		(axis_win2fft_tdata[`IN_AXI_WIDTH-1:0]),
     .axis_win2fft_tkeep		(axis_win2fft_tkeep[`IN_BYTE_COUNT-1:0]),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .s_axis_tvalid			(s_axis_tvalid),
     .s_axis_tlast			(s_axis_tlast),
     .s_axis_tdata			(s_axis_tdata[`IN_AXI_WIDTH-1:0]),
     .s_axis_tkeep			(s_axis_tkeep[`IN_BYTE_COUNT-1:0]),
     .axis_win2fft_tready		(axis_win2fft_tready));

    fft_wrapper #(/*AUTOINSTPARAM*/
		  // Parameters
		  .FFT_SIZE		(FFT_SIZE),
		  .SAMPLE_WIDTH		(SAMPLE_WIDTH),
		  .REAL_INPUT		(REAL_INPUT)) fft
    (/*AUTOINST*/
     // Outputs
     .axis_win2fft_tready		(axis_win2fft_tready),
     .fft_busy				(fft_busy),
     .m_axis_tdata			(m_axis_tdata[`OUT_AXI_WIDTH-1:0]),
     .m_axis_tkeep			(m_axis_tkeep[`OUT_BYTE_COUNT-1:0]),
     .m_axis_tlast			(m_axis_tlast),
     .m_axis_tvalid			(m_axis_tvalid),
     // Inputs
     .reset				(reset),
     .axis_win2fft_tdata		(axis_win2fft_tdata[`IN_AXI_WIDTH-1:0]),
     .axis_win2fft_tkeep		(axis_win2fft_tkeep[`IN_BYTE_COUNT-1:0]),
     .axis_win2fft_tlast		(axis_win2fft_tlast),
     .axis_win2fft_tvalid		(axis_win2fft_tvalid),
     .clk				(clk),
     .fft_go				(fft_go),
     .m_axis_tready			(m_axis_tready));

endmodule
