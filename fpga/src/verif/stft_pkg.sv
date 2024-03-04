package stft_pkg;
    
    import uvm_pkg::*;
    import axis_master_pkg::*;
    import axis_slave_pkg::*;

    `include "uvm_macros.svh"

    `include "mem_mux/mem_mux_seq_item.sv"
    `include "mem_mux/mem_mux_monitor.sv"
    `include "mem_mux/mem_mux_scoreboard.sv"

    `include "stft_env.sv"
    `include "stft_test.sv"
endpackage
