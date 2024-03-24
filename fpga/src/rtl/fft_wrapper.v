`include "fft_defs.vh"

module fft_wrapper(/*AUTOARG*/
   // Outputs
   m_axis_tvalid, m_axis_tlast, m_axis_tkeep, m_axis_tdata, fft_busy,
   axis_win2fft_tready,
   // Inputs
   m_axis_tready, fft_go, clk, axis_win2fft_tvalid,
   axis_win2fft_tlast, axis_win2fft_tkeep, axis_win2fft_tdata, reset
   );

    parameter FFT_SIZE = 4096;
    parameter SAMPLE_WIDTH = 16;
    parameter REAL_INPUT = 1;

    input reset;
    /*AUTOINPUT*/
    // Beginning of automatic inputs (from unused autoinst inputs)
    input [`IN_AXI_WIDTH-1:0] axis_win2fft_tdata;// To axis_slave of axis_bram_slave.v
    input [`IN_BYTE_COUNT-1:0] axis_win2fft_tkeep;// To axis_slave of axis_bram_slave.v
    input		axis_win2fft_tlast;	// To axis_slave of axis_bram_slave.v
    input		axis_win2fft_tvalid;	// To axis_slave of axis_bram_slave.v
    input		clk;			// To top_ctrl of fft_top_ctrl.v, ...
    input		fft_go;			// To top_ctrl of fft_top_ctrl.v
    input		m_axis_tready;		// To axis_master of axis_bram_master.v
    // End of automatics
    /*AUTOOUTPUT*/
    // Beginning of automatic outputs (from unused autoinst outputs)
    output		axis_win2fft_tready;	// From axis_slave of axis_bram_slave.v
    output		fft_busy;		// From top_ctrl of fft_top_ctrl.v
    output [`OUT_AXI_WIDTH-1:0] m_axis_tdata;	// From axis_master of axis_bram_master.v
    output [`OUT_BYTE_COUNT-1:0] m_axis_tkeep;	// From axis_master of axis_bram_master.v
    output		m_axis_tlast;		// From axis_master of axis_bram_master.v
    output		m_axis_tvalid;		// From axis_master of axis_bram_master.v
    // End of automatics
    
    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire		addr_gen_busy;		// From agu of address_gen.v
    wire		addr_gen_go;		// From top_ctrl of fft_top_ctrl.v
    wire		axis_bram_master_busy;	// From axis_master of axis_bram_master.v
    wire		axis_bram_master_go;	// From top_ctrl of fft_top_ctrl.v
    wire		axis_bram_slave_busy;	// From axis_slave of axis_bram_slave.v
    wire		axis_bram_slave_go;	// From top_ctrl of fft_top_ctrl.v
    wire		axis_mem2m_clken;	// From axis_master of axis_bram_master.v
    wire [`ADDR_WIDTH-1:0] axis_mem2m_raddr;	// From axis_master of axis_bram_master.v
    wire [`DATA_WIDTH-1:0] axis_mem2m_rdata;	// From mem of memory_mux.v
    wire		axis_rx;		// From top_ctrl of fft_top_ctrl.v
    wire [`ADDR_WIDTH-1:0] axis_s2mem_waddra;	// From axis_slave of axis_bram_slave.v
    wire [`ADDR_WIDTH-1:0] axis_s2mem_waddrb;	// From axis_slave of axis_bram_slave.v
    wire [`DATA_WIDTH-1:0] axis_s2mem_wdataa;	// From axis_slave of axis_bram_slave.v
    wire [`DATA_WIDTH-1:0] axis_s2mem_wdatab;	// From axis_slave of axis_bram_slave.v
    wire		axis_s2mem_wea;		// From axis_slave of axis_bram_slave.v
    wire		axis_s2mem_web;		// From axis_slave of axis_bram_slave.v
    wire		axis_tx;		// From top_ctrl of fft_top_ctrl.v
    wire		fft_data_valid;		// From agu of address_gen.v
    wire [$clog2(`LEVELS)-1:0] fft_level;	// From top_ctrl of fft_top_ctrl.v
    wire [`LEVELS-1:0]	fft_raddra;		// From agu of address_gen.v
    wire [`LEVELS-1:0]	fft_raddrb;		// From agu of address_gen.v
    wire [`DATA_WIDTH-1:0] fft_rdataa;		// From mem of memory_mux.v
    wire [`DATA_WIDTH-1:0] fft_rdatab;		// From mem of memory_mux.v
    wire [`LEVELS-1:0]	fft_waddra;		// From agu of address_gen.v
    wire [`LEVELS-1:0]	fft_waddrb;		// From agu of address_gen.v
    wire [`DATA_WIDTH-1:0] fft_wdataa;		// From bfu of butterfly.v
    wire [`DATA_WIDTH-1:0] fft_wdatab;		// From bfu of butterfly.v
    wire		fft_wea;		// From agu of address_gen.v
    wire		fft_web;		// From agu of address_gen.v
    wire		rmem_id;		// From top_ctrl of fft_top_ctrl.v
    wire [`TWIDDLE_WIDTH-1:0] twiddle;		// From twiddles of twiddle_rom.v
    wire [`LEVELS-2:0]	twiddle_addr;		// From agu of address_gen.v
    wire		wmem_id;		// From top_ctrl of fft_top_ctrl.v
    // End of automatics
    
    wire scale = fft_level[0];
    fft_top_ctrl #(/*AUTOINSTPARAM*/
		   // Parameters
		   .FFT_SIZE		(FFT_SIZE)) top_ctrl
    (/*AUTOINST*/
     // Outputs
     .fft_busy				(fft_busy),
     .axis_bram_slave_go		(axis_bram_slave_go),
     .addr_gen_go			(addr_gen_go),
     .axis_bram_master_go		(axis_bram_master_go),
     .fft_level				(fft_level[$clog2(`LEVELS)-1:0]),
     .wmem_id				(wmem_id),
     .rmem_id				(rmem_id),
     .axis_rx				(axis_rx),
     .axis_tx				(axis_tx),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .fft_go				(fft_go),
     .axis_bram_slave_busy		(axis_bram_slave_busy),
     .addr_gen_busy			(addr_gen_busy),
     .fft_data_valid			(fft_data_valid),
     .axis_bram_master_busy		(axis_bram_master_busy));

    butterfly #(/*AUTOINSTPARAM*/
		// Parameters
		.FFT_SIZE		(FFT_SIZE),
		.SAMPLE_WIDTH		(SAMPLE_WIDTH)) bfu
    (/*AUTOINST*/
     // Outputs
     .fft_wdataa			(fft_wdataa[`DATA_WIDTH-1:0]),
     .fft_wdatab			(fft_wdatab[`DATA_WIDTH-1:0]),
     // Inputs
     .clk				(clk),
     .fft_rdataa			(fft_rdataa[`DATA_WIDTH-1:0]),
     .fft_rdatab			(fft_rdatab[`DATA_WIDTH-1:0]),
     .twiddle				(twiddle[`TWIDDLE_WIDTH-1:0]),
     .scale				(scale));

    address_gen #(/*AUTOINSTPARAM*/
		  // Parameters
		  .FFT_SIZE		(FFT_SIZE)) agu
    (/*AUTOINST*/
     // Outputs
     .addr_gen_busy			(addr_gen_busy),
     .fft_raddra			(fft_raddra[`LEVELS-1:0]),
     .fft_raddrb			(fft_raddrb[`LEVELS-1:0]),
     .fft_waddra			(fft_waddra[`LEVELS-1:0]),
     .fft_waddrb			(fft_waddrb[`LEVELS-1:0]),
     .fft_wea				(fft_wea),
     .fft_web				(fft_web),
     .fft_data_valid			(fft_data_valid),
     .twiddle_addr			(twiddle_addr[`LEVELS-2:0]),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .addr_gen_go			(addr_gen_go),
     .fft_level				(fft_level[$clog2(`LEVELS)-1:0]));

    memory_mux #(/*AUTOINSTPARAM*/
		 // Parameters
		 .FFT_SIZE		(FFT_SIZE),
		 .SAMPLE_WIDTH		(SAMPLE_WIDTH)) mem
    (/*AUTOINST*/
     // Outputs
     .fft_rdataa			(fft_rdataa[`DATA_WIDTH-1:0]),
     .fft_rdatab			(fft_rdatab[`DATA_WIDTH-1:0]),
     .axis_mem2m_rdata			(axis_mem2m_rdata[`DATA_WIDTH-1:0]),
     // Inputs
     .clk				(clk),
     .axis_rx				(axis_rx),
     .axis_tx				(axis_tx),
     .wmem_id				(wmem_id),
     .rmem_id				(rmem_id),
     .fft_raddra			(fft_raddra[`ADDR_WIDTH-1:0]),
     .fft_raddrb			(fft_raddrb[`ADDR_WIDTH-1:0]),
     .fft_waddra			(fft_waddra[`ADDR_WIDTH-1:0]),
     .fft_waddrb			(fft_waddrb[`ADDR_WIDTH-1:0]),
     .fft_wdataa			(fft_wdataa[`DATA_WIDTH-1:0]),
     .fft_wdatab			(fft_wdatab[`DATA_WIDTH-1:0]),
     .fft_wea				(fft_wea),
     .fft_web				(fft_web),
     .axis_s2mem_wea			(axis_s2mem_wea),
     .axis_s2mem_waddra			(axis_s2mem_waddra[`ADDR_WIDTH-1:0]),
     .axis_s2mem_wdataa			(axis_s2mem_wdataa[`DATA_WIDTH-1:0]),
     .axis_s2mem_web			(axis_s2mem_web),
     .axis_s2mem_waddrb			(axis_s2mem_waddrb[`ADDR_WIDTH-1:0]),
     .axis_s2mem_wdatab			(axis_s2mem_wdatab[`DATA_WIDTH-1:0]),
     .axis_mem2m_clken			(axis_mem2m_clken),
     .axis_mem2m_raddr			(axis_mem2m_raddr[`ADDR_WIDTH-1:0]));

    twiddle_rom #(/*AUTOINSTPARAM*/
		  // Parameters
		  .FFT_SIZE		(FFT_SIZE)) twiddles
    (/*AUTOINST*/
     // Outputs
     .twiddle				(twiddle[`TWIDDLE_WIDTH-1:0]),
     // Inputs
     .clk				(clk),
     .twiddle_addr			(twiddle_addr[$clog2(`NUM_TWIDDLES)-1:0]));

    axis_bram_master #(/*AUTOINSTPARAM*/
		       // Parameters
		       .SAMPLE_WIDTH	(SAMPLE_WIDTH),
		       .FFT_SIZE	(FFT_SIZE),
		       .REAL_INPUT	(REAL_INPUT)) axis_master
    (/*AUTOINST*/
     // Outputs
     .axis_bram_master_busy		(axis_bram_master_busy),
     .axis_mem2m_raddr			(axis_mem2m_raddr[`ADDR_WIDTH-1:0]),
     .axis_mem2m_clken			(axis_mem2m_clken),
     .m_axis_tvalid			(m_axis_tvalid),
     .m_axis_tlast			(m_axis_tlast),
     .m_axis_tdata			(m_axis_tdata[`OUT_AXI_WIDTH-1:0]),
     .m_axis_tkeep			(m_axis_tkeep[`OUT_BYTE_COUNT-1:0]),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .axis_bram_master_go		(axis_bram_master_go),
     .axis_mem2m_rdata			(axis_mem2m_rdata[`DATA_WIDTH-1:0]),
     .m_axis_tready			(m_axis_tready));

    axis_bram_slave #(/*AUTOINSTPARAM*/
		      // Parameters
		      .FFT_SIZE		(FFT_SIZE),
		      .SAMPLE_WIDTH	(SAMPLE_WIDTH)) axis_slave
    (/*AUTOINST*/
     // Outputs
     .axis_bram_slave_busy		(axis_bram_slave_busy),
     .axis_s2mem_waddra			(axis_s2mem_waddra[`ADDR_WIDTH-1:0]),
     .axis_s2mem_wdataa			(axis_s2mem_wdataa[`DATA_WIDTH-1:0]),
     .axis_s2mem_wea			(axis_s2mem_wea),
     .axis_s2mem_waddrb			(axis_s2mem_waddrb[`ADDR_WIDTH-1:0]),
     .axis_s2mem_wdatab			(axis_s2mem_wdatab[`DATA_WIDTH-1:0]),
     .axis_s2mem_web			(axis_s2mem_web),
     .axis_win2fft_tready		(axis_win2fft_tready),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .axis_bram_slave_go		(axis_bram_slave_go),
     .axis_win2fft_tvalid		(axis_win2fft_tvalid),
     .axis_win2fft_tlast		(axis_win2fft_tlast),
     .axis_win2fft_tdata		(axis_win2fft_tdata[`IN_AXI_WIDTH-1:0]),
     .axis_win2fft_tkeep		(axis_win2fft_tkeep[`IN_BYTE_COUNT-1:0]));

endmodule
