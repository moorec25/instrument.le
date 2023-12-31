`ifndef MEM_MUX_SEQ_ITEM_H
`define MEM_MUX_SEQ_ITEM_H
`include "fft_defs.vh"
`include "uvm_macros.svh"
import uvm_pkg::*;

class mem_mux_seq_item_t extends uvm_sequence_item;
    
    parameter FFT_SIZE = 4096;
    parameter DATA_WIDTH = 64;

    logic [`ADDR_WIDTH-1:0] fft_waddra;
    logic [`ADDR_WIDTH-1:0] fft_waddrb;
    logic [DATA_WIDTH-1:0] fft_wdataa;
    logic [DATA_WIDTH-1:0] fft_wdatab;
    logic wmem_id;

    `uvm_object_utils_begin(mem_mux_seq_item_t)
        `uvm_field_int(fft_waddra, UVM_ALL_ON)
        `uvm_field_int(fft_wdataa, UVM_ALL_ON)
        `uvm_field_int(fft_waddrb, UVM_ALL_ON)
        `uvm_field_int(fft_wdatab, UVM_ALL_ON)
        `uvm_field_int(wmem_id, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "mem_mux_seq_item_t");
        super.new(name);
    endfunction

    
endclass

`endif
