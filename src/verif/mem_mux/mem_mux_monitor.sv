`include "uvm_macros.svh"
`include "mem_mux_seq_item.sv"

import uvm_pkg::*;

class mem_mux_monitor_t extends uvm_monitor;

    `uvm_component_utils(mem_mux_monitor_t);

    virtual mem_mux_if_t vif;
    mem_mux_seq_item_t mem_mux_trans;
    
    uvm_analysis_port #(mem_mux_seq_item_t) mon_analysis_port;

    function new(string name = "mem_mux_monitor", uvm_component parent);
        super.new(name, parent);
        mem_mux_trans = new();
        mon_analysis_port = new ("mon_analysis_port", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (! uvm_config_db#(virtual mem_mux_if_t)::get(this, "", "mem_mux_vif", vif)) begin
            `uvm_error (get_type_name(), "mem_mux vif not found")
        end

    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        
        forever begin
            @ (posedge fft_tb.fft.clk);
            if (vif.fft_wea || vif.fft_web) begin
                `uvm_info("mem_mux_monitor", "write enabled", UVM_NONE)
                mem_mux_trans.fft_waddra = vif.fft_waddra;
                mem_mux_trans.fft_waddrb = vif.fft_waddrb;
                mem_mux_trans.fft_wdataa = vif.fft_wdataa;
                mem_mux_trans.fft_wdatab = vif.fft_wdatab;
                mem_mux_trans.wmem_id = vif.wmem_id;
                mon_analysis_port.write(mem_mux_trans);
            end
        end
        `uvm_info("mem_mux_monitor", "finishing run phase", UVM_NONE)
        
    endtask : run_phase
    
endclass
