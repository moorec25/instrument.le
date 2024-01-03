class axis_slave_scoreboard_t extends uvm_scoreboard;
    
    `uvm_component_utils(axis_slave_scoreboard_t);

    uvm_analysis_imp #(axis_trans_t, axis_slave_scoreboard_t) axis_trans_imp;
    int results_trace;
    int r;
    int i;

    axis_trans_t trans_q[$];
    axis_trans_t actual;
    axis_trans_t expected;

    function new(string name = "axis_slave_scoreboard_t", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        axis_trans_imp = new("axis_trans_imp", this);
        expected = axis_trans_t::type_id::create("expected", this);

        results_trace = $fopen("/home/carter/Documents/instrument.le/out/angels/fft_out_c.txt", "r");
    endfunction : build_phase
    
    virtual function void write(axis_trans_t axis_trans);
        `uvm_info("axis_slave_scoreboard", "axis slave transaction recieved", UVM_NONE)
        
        trans_q.push_back(axis_trans);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        while ($fscanf(results_trace, "%d %d", r, i) == 2) begin
            expected.data_r = r;
            expected.data_i = i;
            wait(trans_q.size > 0);
            actual = trans_q.pop_front();
            if (actual.compare(expected)) begin
                `uvm_info("axis_slave_scoreboard", "AXI stream data match", UVM_LOW)
            end else begin
                actual.print();
                expected.print();
                `uvm_error("axis_slave_scoreboard", "AXI stream mismatch")
            end
        end
        phase.drop_objection(this);
    endtask : run_phase
endclass
