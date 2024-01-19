`timescale 1ns / 1ps

import fft_pkg::*;
import uvm_pkg::*;
`include "mem_mux_if.sv"
`include "axis_master_if.sv"
`include "axis_slave_if.sv"
`include "fft_ctrl_if.sv"

module fft_tb;

    parameter FFT_SIZE=4096;
    parameter SAMPLE_WIDTH=16;
    parameter TWIDDLE_WIDTH=50;
    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire		fft_busy;		// From fft_dut of fft_wrapper.v
    // End of automatics
    /*AUTOREGINPUT*/
    // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
    reg			clk;			// To fft_dut of fft_wrapper.v
    reg         resetn;
    logic [`ADDR_WIDTH-1:0] fft_waddra;		// To mem_mux_if of mem_mux_if_t.v
    logic [`ADDR_WIDTH-1:0] fft_waddrb;		// To mem_mux_if of mem_mux_if_t.v
    logic [SAMPLE_WIDTH-1:0] fft_wdataa;		// To mem_mux_if of mem_mux_if_t.v
    logic [SAMPLE_WIDTH-1:0] fft_wdatab;		// To mem_mux_if of mem_mux_if_t.v
    logic			fft_wea;		// To mem_mux_if of mem_mux_if_t.v
    logic			fft_web;		// To mem_mux_if of mem_mux_if_t.v
    logic			wmem_id;		// To mem_mux_if of mem_mux_if_t.v
    // End of automatics

    initial begin
        clk = 1'b1;
        forever #4 clk = ~clk;
    end

    initial begin
        resetn = 0;
        #40
        resetn = 1;
    end

    axis_master_if_t axis_master_if (clk, resetn);
    axis_slave_if_t axis_slave_if (clk, resetn);
    fft_ctrl_if_t fft_ctrl_if (clk, resetn);

    fft_wrapper #(/*AUTOINSTPARAM*/
		  // Parameters
		  .FFT_SIZE		(FFT_SIZE),
		  .SAMPLE_WIDTH		(SAMPLE_WIDTH),
		  .TWIDDLE_WIDTH	(TWIDDLE_WIDTH)) fft
    (/*AUTOINST*/
     // Outputs
     .fft_busy				(fft_ctrl_if.fft_busy),
     .m_axis_tdata			(axis_slave_if.tdata),
     .m_axis_tkeep			(axis_slave_if.tkeep),
     .m_axis_tlast			(axis_slave_if.tlast),
     .m_axis_tvalid			(axis_slave_if.tvalid),
     .s_axis_tready			(axis_master_if.tready),
     // Inputs
     .clk				(clk),
     .fft_go				(fft_ctrl_if.fft_go),
     .m_axis_tready			(axis_slave_if.tready),
     .resetn				(resetn),
     .s_axis_tdata			(axis_master_if.tdata),
     .s_axis_tkeep			(axis_master_if.tkeep),
     .s_axis_tlast			(axis_master_if.tlast),
     .s_axis_tvalid			(axis_master_if.tvalid));
    
     bind fft mem_mux_if_t #(/*AUTOINSTPARAM*/
				 // Parameters
				 .FFT_SIZE		(FFT_SIZE),
				 .SAMPLE_WIDTH		(SAMPLE_WIDTH)) 
     mem_mux_if (/*AUTOINST*/
		 // Inputs
         .clk (clk),
		 .fft_waddra		(fft_waddra[`ADDR_WIDTH-1:0]),
		 .fft_waddrb		(fft_waddrb[`ADDR_WIDTH-1:0]),
		 .fft_wdataa		(fft_wdataa[`DATA_WIDTH-1:0]),
		 .fft_wdatab		(fft_wdatab[`DATA_WIDTH-1:0]),
		 .fft_wea		(fft_wea),
		 .fft_web		(fft_web),
		 .wmem_id		(wmem_id));


    initial begin
        uvm_config_db#(virtual mem_mux_if_t)::set(null, "", "mem_mux_vif", fft.mem_mux_if);
        uvm_config_db#(virtual axis_master_if_t)::set(null, "", "axis_master_vif", axis_master_if);
        uvm_config_db#(virtual axis_slave_if_t)::set(null, "", "axis_slave_vif", axis_slave_if);
        uvm_config_db#(virtual fft_ctrl_if_t)::set(null, "", "fft_ctrl_vif", fft_ctrl_if);
        run_test("fft_test");
    end

endmodule

// Local Variables:
// verilog-library-flags:("-y ../../sources_1/new/")
// End:
