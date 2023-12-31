`include "uvm_macros.svh"
`include "mem_mux_seq_item.sv"

class mem_mux_scoreboard_t extends uvm_scoreboard;
    
    `uvm_component_utils(mem_mux_scoreboard_t);

    uvm_analysis_imp #(mem_mux_seq_item_t, mem_mux_scoreboard_t) mem_mux_trans_imp;
    mem_mux_seq_item_t trans_q[$];

    function new(string name = "mem_mux_scoreboard_t", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mem_mux_trans_imp = new("mem_mux_trans_imp", this);
    endfunction : build_phase

    virtual function void write(mem_mux_seq_item_t mem_trans);
        $display("memory transaction recieved");
        `uvm_info("mem_mux_scoreboard", $sformatf("Contents: %s", mem_trans.sprint()), UVM_NONE);
        trans_q.push_back(mem_trans);
    endfunction : write
        
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        wait(trans_q.size > 0);
        `uvm_info("mem_mux_scoreboard", "transaction occured", UVM_NONE)
        phase.drop_objection(this);
    endtask : run_phase
endclass
