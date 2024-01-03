`timescale 1ns / 1ps

import fft_pkg::*;
import uvm_pkg::*;
`include "mem_mux_if.sv"
`include "axis_master_if.sv"
`include "axis_slave_if.sv"

module fft_tb;

    parameter FFT_SIZE=4096;
    parameter DATA_WIDTH=64;
    parameter TWIDDLE_WIDTH=32;
    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire		fft_busy;		// From fft_dut of fft_wrapper.v
    wire [DATA_WIDTH-1:0] m_axis_tdata;		// From fft_dut of fft_wrapper.v
    wire [`BYTE_COUNT-1:0] m_axis_tkeep;	// From fft_dut of fft_wrapper.v
    wire		m_axis_tlast;		// From fft_dut of fft_wrapper.v
    wire		m_axis_tvalid;		// From fft_dut of fft_wrapper.v
    wire		s_axis_tready;		// From fft_dut of fft_wrapper.v
    // End of automatics
    /*AUTOREGINPUT*/
    // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
    reg			clk;			// To fft_dut of fft_wrapper.v
    reg			fft_go;			// To fft_dut of fft_wrapper.v
    logic [`ADDR_WIDTH-1:0] fft_waddra;		// To mem_mux_if of mem_mux_if_t.v
    logic [`ADDR_WIDTH-1:0] fft_waddrb;		// To mem_mux_if of mem_mux_if_t.v
    logic [DATA_WIDTH-1:0] fft_wdataa;		// To mem_mux_if of mem_mux_if_t.v
    logic [DATA_WIDTH-1:0] fft_wdatab;		// To mem_mux_if of mem_mux_if_t.v
    logic			fft_wea;		// To mem_mux_if of mem_mux_if_t.v
    logic			fft_web;		// To mem_mux_if of mem_mux_if_t.v
    wire        m_axis_tready;
    reg			resetn;			// To fft_dut of fft_wrapper.v
    reg [DATA_WIDTH-1:0] s_axis_tdata;		// To fft_dut of fft_wrapper.v
    reg [`BYTE_COUNT-1:0] s_axis_tkeep;		// To fft_dut of fft_wrapper.v
    reg			s_axis_tlast;		// To fft_dut of fft_wrapper.v
    reg			s_axis_tvalid;		// To fft_dut of fft_wrapper.v
    logic			wmem_id;		// To mem_mux_if of mem_mux_if_t.v
    // End of automatics

    initial begin
        clk = 1'b1;
        forever #4 clk = ~clk;
    end

    initial begin
        resetn = 0;
        fft_go = 0;
        #40
        resetn = 1;
        #12
        fft_go = 1;
        #8
        fft_go = 0;
    end

    axis_master_if_t axis_master_if (clk, resetn);
    axis_slave_if_t axis_slave_if (clk, resetn);

    fft_wrapper #(/*AUTOINSTPARAM*/
		  // Parameters
		  .FFT_SIZE		(FFT_SIZE),
		  .DATA_WIDTH		(DATA_WIDTH),
		  .TWIDDLE_WIDTH	(TWIDDLE_WIDTH)) fft
    (/*AUTOINST*/
     // Outputs
     .fft_busy				(fft_busy),
     .m_axis_tdata			(axis_slave_if.tdata),
     .m_axis_tkeep			(axis_slave_if.tkeep),
     .m_axis_tlast			(axis_slave_if.tlast),
     .m_axis_tvalid			(axis_slave_if.tvalid),
     .s_axis_tready			(axis_master_if.tready),
     // Inputs
     .clk				(clk),
     .fft_go				(fft_go),
     .m_axis_tready			(axis_slave_if.tready),
     .resetn				(resetn),
     .s_axis_tdata			(axis_master_if.tdata),
     .s_axis_tkeep			(axis_master_if.tkeep),
     .s_axis_tlast			(axis_master_if.tlast),
     .s_axis_tvalid			(axis_master_if.tvalid));
    
     bind fft mem_mux_if_t #(/*AUTOINSTPARAM*/
				 // Parameters
				 .FFT_SIZE		(FFT_SIZE),
				 .DATA_WIDTH		(DATA_WIDTH)) 
     mem_mux_if (/*AUTOINST*/
		 // Inputs
         .clk (clk),
		 .fft_waddra		(fft_waddra[`ADDR_WIDTH-1:0]),
		 .fft_waddrb		(fft_waddrb[`ADDR_WIDTH-1:0]),
		 .fft_wdataa		(fft_wdataa[DATA_WIDTH-1:0]),
		 .fft_wdatab		(fft_wdatab[DATA_WIDTH-1:0]),
		 .fft_wea		(fft_wea),
		 .fft_web		(fft_web),
		 .wmem_id		(wmem_id));


    initial begin
        uvm_config_db#(virtual mem_mux_if_t)::set(null, "", "mem_mux_vif", fft.mem_mux_if);
        uvm_config_db#(virtual axis_master_if_t)::set(null, "", "axis_master_vif", axis_master_if);
        uvm_config_db#(virtual axis_slave_if_t)::set(null, "", "axis_slave_vif", axis_slave_if);
        run_test("fft_test");
    end

endmodule

// Local Variables:
// verilog-library-flags:("-y ../../sources_1/new/")
// End:
