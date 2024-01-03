class mem_mux_scoreboard_t extends uvm_scoreboard;
    
    `uvm_component_utils(mem_mux_scoreboard_t);

    uvm_analysis_imp #(mem_mux_seq_item_t, mem_mux_scoreboard_t) mem_mux_trans_imp;

    int mem_trace;

    mem_mux_seq_item_t trans_q[$];
    mem_mux_seq_item_t actual;
    mem_mux_seq_item_t expected;

    function new(string name = "mem_mux_scoreboard_t", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        mem_mux_trans_imp = new("mem_mux_trans_imp", this);
        expected = mem_mux_seq_item_t::type_id::create("expected", this);

        mem_trace = $fopen("/home/carter/Documents/instrument.le/out/angels/fft_mem_wr_trace.txt", "r");

    endfunction : build_phase

    virtual function void write(mem_mux_seq_item_t mem_trans);
        `uvm_info("mem_mux_scoreboard", $sformatf("Memory Write Transaction Contents: %s", mem_trans.sprint()), UVM_HIGH);
        trans_q.push_back(mem_trans);
    endfunction : write
        
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        while ($fscanf(mem_trace, "%x %x %x %x %x %x %d", expected.waddra, expected.wdataa_r, expected.wdataa_i, expected.waddrb, expected.wdatab_r, expected.wdatab_i, expected.wmem_id) == 7) begin
            wait(trans_q.size > 0);
            actual = trans_q.pop_front();
            if (actual.compare(expected)) begin
                `uvm_info("mem_mux_scoreboard", $sformatf("Memory Write Transaction Expected Contents: %s", expected.sprint()), UVM_HIGH);
                `uvm_info("mem_mux_scoreboard", "Write data matching", UVM_LOW)
            end else begin
                `uvm_info("mem_mux_scoreboard", $sformatf("Memory Write Transaction Expected Contents: %s", expected.sprint()), UVM_NONE);
                `uvm_info("mem_mux_scoreboard", $sformatf("Memory Write Transaction Actual Contents: %s", actual.sprint()), UVM_NONE);
                `uvm_fatal("mem_mux_scoreboard", "MEMORY WRITE MISMATCH OCURRED")
            end
        end
        phase.drop_objection(this);
    endtask : run_phase
endclass