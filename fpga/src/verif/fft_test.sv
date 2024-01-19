class fft_test extends uvm_test;
    
    `uvm_component_utils(fft_test);

    fft_env_t fft_env;
    axis_master_seq_t axis_master_seq;
    fft_ctrl_seq_t fft_ctrl_seq;

    function new(string name = "fft_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        fft_env = fft_env_t::type_id::create("fft_env", this);
        axis_master_seq = axis_master_seq_t::type_id::create("axis_master_seq", this);
        fft_ctrl_seq = fft_ctrl_seq_t::type_id::create("fft_ctrl_seq", this);
   endfunction : build_phase 

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        repeat(2) begin
            fork
                fft_ctrl_seq.start(fft_env.fft_ctrl_agent.seqr);

                axis_master_seq.start(fft_env.axis_master_agent.seqr);
            join
        end
        phase.drop_objection(this);
    endtask : run_phase

    virtual function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        `uvm_info("fft_test", "final phase", UVM_NONE)
   endfunction: final_phase
endclass
