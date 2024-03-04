class axis_master_agent_t extends uvm_agent;

    `uvm_component_utils(axis_master_agent_t)

    axis_master_driver_t driver;
    uvm_sequencer #(axis_master_trans_t) seqr;

    function new (string name = "axis_master_agent_t", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver = axis_master_driver_t::type_id::create("driver", this);
        seqr = uvm_sequencer#(axis_master_trans_t)::type_id::create("seqr", this);
    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(seqr.seq_item_export);
    endfunction : connect_phase

endclass
