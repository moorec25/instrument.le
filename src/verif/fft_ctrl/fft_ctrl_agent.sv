class fft_ctrl_agent_t extends uvm_agent;

    `uvm_component_utils(fft_ctrl_agent_t)

    fft_ctrl_driver_t driver;
    uvm_sequencer #(uvm_sequence_item) seqr;

    function new (string name = "fft_ctrl_agent_t", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver = fft_ctrl_driver_t::type_id::create("driver", this);
        seqr = uvm_sequencer#(uvm_sequence_item)::type_id::create("seqr", this);
    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(seqr.seq_item_export);
    endfunction : connect_phase
endclass
