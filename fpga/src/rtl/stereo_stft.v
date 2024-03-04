`include "fft_defs.vh"

module stereo_stft(/*AUTOARG*/
   // Outputs
   m_axis_tdata, m_axis_tkeep, m_axis_tlast, m_axis_tvalid,
   s_axis_tready,
   // Inputs
   clk, m_axis_tready, resetn, s_axis_tdata, s_axis_tkeep,
   s_axis_tlast, s_axis_tvalid
   );

    parameter FFT_SIZE = 4096;
    parameter SAMPLE_WIDTH = 16;
    parameter REAL_INPUT = 1;

    // Beginning of automatic inputs (from unused autoinst inputs)
    input		clk;			// To stft_left of stft_wrapper.v, ...
    input		m_axis_tready;		// To stft_left of stft_wrapper.v, ...
    input		resetn;			// To stft_left of stft_wrapper.v, ...
    input [2*`IN_AXI_WIDTH-1:0] s_axis_tdata;	// To stft_left of stft_wrapper.v, ...
    input [2*`IN_BYTE_COUNT-1:0] s_axis_tkeep;	// To stft_left of stft_wrapper.v, ...
    input		s_axis_tlast;		// To stft_left of stft_wrapper.v, ...
    input		s_axis_tvalid;		// To stft_left of stft_wrapper.v, ...
    // End of automatics
    
    // Beginning of automatic outputs (from unused autoinst outputs)
    output reg [`OUT_AXI_WIDTH-1:0] m_axis_tdata;	// From stft_left of stft_wrapper.v, ...
    output reg [`OUT_BYTE_COUNT-1:0] m_axis_tkeep;	// From stft_left of stft_wrapper.v, ...
    output reg		m_axis_tlast;		// From stft_left of stft_wrapper.v, ...
    output reg		m_axis_tvalid;		// From stft_left of stft_wrapper.v, ...
    output		s_axis_tready;		// From stft_left of stft_wrapper.v, ...
    // End of automatics

    wire reset;
    assign reset = ~resetn;

    wire fft_go;

    wire fft_busy_l;
    wire fft_busy_r;

    assign fft_go = ~fft_busy_l & ~fft_busy_r;
    // Mux AXI master stream: left channel writes output first, then right
    
    wire [`OUT_AXI_WIDTH-1:0] m_axis_tdata_l;
    wire [`OUT_BYTE_COUNT-1:0] m_axis_tkeep_l;
    wire m_axis_tlast_l;
    wire m_axis_tvalid_l;
    reg m_axis_tready_l;
    wire s_axis_tready_l;

    wire [`OUT_AXI_WIDTH-1:0] m_axis_tdata_r;
    wire [`OUT_BYTE_COUNT-1:0] m_axis_tkeep_r;
    wire m_axis_tlast_r;
    wire m_axis_tvalid_r;
    reg m_axis_tready_r;
    wire s_axis_tready_r;

    assign s_axis_tready = s_axis_tready_l & s_axis_tready_r;

    reg output_channel_q; 

    always @ (posedge clk) begin
        if (reset) begin
            output_channel_q <= 1'b0;
        end else begin
            if (output_channel_q == 1'b0) begin
                output_channel_q <= (m_axis_tlast_l & m_axis_tready_l) ? ~output_channel_q : output_channel_q;
            end else begin
                output_channel_q <= (m_axis_tlast_r & m_axis_tready_r) ? ~output_channel_q : output_channel_q;
            end
        end
    end



    always @* begin

        m_axis_tready_l = 1'b0;
        m_axis_tready_r = 1'b0;

        if (output_channel_q == 1'b0) begin
            m_axis_tdata = m_axis_tdata_l;
            m_axis_tkeep = m_axis_tkeep_l;
            m_axis_tlast = m_axis_tlast_l;
            m_axis_tvalid = m_axis_tvalid_l;
            m_axis_tready_l = m_axis_tready;
        end else begin
            m_axis_tdata = m_axis_tdata_r;
            m_axis_tkeep = m_axis_tkeep_r;
            m_axis_tlast = m_axis_tlast_r;
            m_axis_tvalid = m_axis_tvalid_r;
            m_axis_tready_r = m_axis_tready;
        end
    end

    stft_wrapper #(/*AUTOINSTPARAM*/
		   // Parameters
		   .FFT_SIZE		(FFT_SIZE),
		   .SAMPLE_WIDTH	(SAMPLE_WIDTH),
		   .REAL_INPUT		(REAL_INPUT)) stft_left
    (
     // Outputs
     .m_axis_tdata			(m_axis_tdata_l[`OUT_AXI_WIDTH-1:0]),
     .m_axis_tkeep			(m_axis_tkeep_l[`OUT_BYTE_COUNT-1:0]),
     .m_axis_tlast			(m_axis_tlast_l),
     .m_axis_tvalid			(m_axis_tvalid_l),
     .s_axis_tready			(s_axis_tready_l),
     .fft_busy              (fft_busy_l),
     // Inputs
     .clk				(clk),
     .m_axis_tready			(m_axis_tready_l),
     .reset				(reset),
     .s_axis_tdata			(s_axis_tdata[2*`IN_AXI_WIDTH-1:`IN_AXI_WIDTH]),
     .s_axis_tkeep			(s_axis_tkeep[2*`IN_BYTE_COUNT-1:`IN_BYTE_COUNT]),
     .s_axis_tlast			(s_axis_tlast),
     .s_axis_tvalid			(s_axis_tvalid),
     .fft_go                (fft_go));

    stft_wrapper #(/*AUTOINSTPARAM*/
		   // Parameters
		   .FFT_SIZE		(FFT_SIZE),
		   .SAMPLE_WIDTH	(SAMPLE_WIDTH),
		   .REAL_INPUT		(REAL_INPUT)) stft_right
    (
     // Outputs
     .m_axis_tdata			(m_axis_tdata_r[`OUT_AXI_WIDTH-1:0]),
     .m_axis_tkeep			(m_axis_tkeep_r[`OUT_BYTE_COUNT-1:0]),
     .m_axis_tlast			(m_axis_tlast_r),
     .m_axis_tvalid			(m_axis_tvalid_r),
     .s_axis_tready			(s_axis_tready_r),
     .fft_busy              (fft_busy_r),
     // Inputs
     .clk				(clk),
     .m_axis_tready			(m_axis_tready_r),
     .reset				(reset),
     .s_axis_tdata			(s_axis_tdata[`IN_AXI_WIDTH-1:0]),
     .s_axis_tkeep			(s_axis_tkeep[`IN_BYTE_COUNT-1:0]),
     .s_axis_tlast			(s_axis_tlast),
     .s_axis_tvalid			(s_axis_tvalid),
     .fft_go                (fft_go));

endmodule
