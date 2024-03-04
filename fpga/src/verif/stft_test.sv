class stft_test extends uvm_test;
    
    `uvm_component_utils(stft_test);

    stft_env_t stft_env;
    axis_master_seq_t axis_master_seq;

    function new(string name = "stft_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        stft_env = stft_env_t::type_id::create("stft_env", this);
        axis_master_seq = axis_master_seq_t::type_id::create("axis_master_seq", this);
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
            axis_master_seq.start(stft_env.axis_master_agent.seqr);
        phase.drop_objection(this);
    endtask : run_phase
    
endclass
