class axis_slave_scoreboard_t extends uvm_scoreboard;
    
    `uvm_component_utils(axis_slave_scoreboard_t);

    uvm_analysis_imp #(axis_slave_trans_t, axis_slave_scoreboard_t) axis_trans_imp;
    int results_trace_l;
    int results_trace_r;

    axis_slave_trans_t left_q[$];
    axis_slave_trans_t right_q[$];
    axis_slave_trans_t actual_l;
    axis_slave_trans_t expected_l;
    axis_slave_trans_t actual_r;
    axis_slave_trans_t expected_r;

    function new(string name = "axis_slave_scoreboard_t", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        axis_trans_imp = new("axis_trans_imp", this);
        expected_l = axis_slave_trans_t::type_id::create("expected_l", this);
        expected_r = axis_slave_trans_t::type_id::create("expected_r", this);
        expected_l.channel = 0;
        expected_r.channel = 1;

        results_trace_l = $fopen("/home/carter/Documents/stft/stft.srcs/sim_1/stft_out_c_0.txt", "r");
        results_trace_r = $fopen("/home/carter/Documents/stft/stft.srcs/sim_1/stft_out_c_1.txt", "r");

    endfunction : build_phase
    
    virtual function void write(axis_slave_trans_t axis_trans);
        `uvm_info("axis_slave_scoreboard", "axis slave transaction recieved", UVM_HIGH)
        
        if (axis_trans.channel == 0) begin
            left_q.push_back(axis_trans);
        end else begin
            right_q.push_back(axis_trans);
        end

    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        fork

        begin
            while ($fscanf(results_trace_l, "%d %d", expected_l.k_real, expected_l.k_imag) == 2) begin
                wait(left_q.size > 0);
                actual_l = left_q.pop_front();
                if (actual_l.compare(expected_l)) begin
                    `uvm_info("axis_slave_scoreboard", "AXI stream data match", UVM_HIGH)
                end else begin
                    expected_l.print();
                    actual_l.print();
                    `uvm_fatal("axis_slave_scoreboard", "AXI stream mismatch")
                end
            end
        end

        begin
            while ($fscanf(results_trace_r, "%d %d", expected_r.k_real, expected_r.k_imag) == 2) begin
                wait(right_q.size > 0);
                actual_r = right_q.pop_front();
                if (actual_r.compare(expected_r)) begin
                    `uvm_info("axis_slave_scoreboard", "AXI stream data match", UVM_HIGH)
                end else begin
                    expected_r.print();
                    actual_r.print();
                    `uvm_fatal("axis_slave_scoreboard", "AXI stream mismatch")
                end
            end
        end

        join

        phase.drop_objection(this);
    endtask : run_phase
endclass
