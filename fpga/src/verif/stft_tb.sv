`timescale 1ns / 1ps

import uvm_pkg::*;
import stft_pkg::*;

`include "axis_master_if.sv"
`include "axis_slave_if.sv"
`include "mem_mux_if.sv"

module stft_tb;

    parameter FFT_SIZE=4096;
    parameter SAMPLE_WIDTH=16;

    /*AUTOREGINPUT*/;
    // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
    reg			clk;			// To DUT of stft.v
    reg resetn;
    // End of automatics

    axis_master_if_t axis_master_if (clk, resetn);
    axis_slave_if_t axis_slave_if (clk, resetn);

    stereo_stft #(
	   // Parameters
	   .FFT_SIZE			(FFT_SIZE),
	   .SAMPLE_WIDTH		(SAMPLE_WIDTH),
       .REAL_INPUT           (1)) DUT
    (
     // Outputs
     .s_axis_tready			(axis_master_if.tready),
     .m_axis_tvalid			(axis_slave_if.tvalid),
     .m_axis_tlast			(axis_slave_if.tlast),
     .m_axis_tdata			(axis_slave_if.tdata[63:0]),
     .m_axis_tkeep			(axis_slave_if.tkeep[7:0]),
     // Inputs
     .clk				(clk),
     .resetn				(resetn),
     .s_axis_tvalid			(axis_master_if.tvalid),
     .s_axis_tlast			(axis_master_if.tlast),
     .s_axis_tdata			(axis_master_if.tdata[31:0]),
     .s_axis_tkeep			(axis_master_if.tkeep[3:0]),
     .m_axis_tready			(axis_slave_if.tready));

     mem_mux_if_t mem_mux_if_l (
         .clk (clk),
		 .fft_waddra		(DUT.stft_left.fft.fft_waddra[11:0]),
		 .fft_waddrb		(DUT.stft_left.fft.fft_waddrb[11:0]),
		 .fft_wdataa		(DUT.stft_left.fft.fft_wdataa[43:0]),
		 .fft_wdatab		(DUT.stft_left.fft.fft_wdatab[43:0]),
		 .fft_wea		(DUT.stft_left.fft.fft_wea),
		 .fft_web		(DUT.stft_left.fft.fft_web),
		 .wmem_id		(DUT.stft_left.fft.wmem_id));

     mem_mux_if_t mem_mux_if_r (
         .clk (clk),
		 .fft_waddra		(DUT.stft_right.fft.fft_waddra[11:0]),
		 .fft_waddrb		(DUT.stft_right.fft.fft_waddrb[11:0]),
		 .fft_wdataa		(DUT.stft_right.fft.fft_wdataa[43:0]),
		 .fft_wdatab		(DUT.stft_right.fft.fft_wdatab[43:0]),
		 .fft_wea		(DUT.stft_right.fft.fft_wea),
		 .fft_web		(DUT.stft_right.fft.fft_web),
		 .wmem_id		(DUT.stft_right.fft.wmem_id));

     initial begin
         clk = 1'b1;
         forever #4 clk = ~clk;
     end

     initial begin
         resetn = 0;
         #40
         resetn = 1;
     end
    
     initial begin
         uvm_config_db#(virtual axis_master_if_t)::set(null, "", "axis_master_vif", axis_master_if);
         uvm_config_db#(virtual axis_slave_if_t)::set(null, "", "axis_slave_vif", axis_slave_if);
         uvm_config_db#(virtual mem_mux_if_t)::set(null, "", "mem_mux_vif_l", mem_mux_if_l);
         uvm_config_db#(virtual mem_mux_if_t)::set(null, "", "mem_mux_vif_r", mem_mux_if_r);
         run_test("stft_test");
     end
endmodule

// Local Variables:
// verilog-library-flags:("-y ../../sources_1/new/")
// End:
