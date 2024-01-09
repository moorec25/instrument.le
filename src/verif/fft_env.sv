class fft_env_t extends uvm_env;

    `uvm_component_utils(fft_env_t);
    
    mem_mux_scoreboard_t mem_mux_scoreboard;
    mem_mux_monitor_t mem_mux_monitor;

    axis_master_agent_t axis_master_agent;

    axis_slave_scoreboard_t axis_slave_scoreboard;
    axis_slave_monitor_t axis_slave_monitor;

    fft_ctrl_agent_t fft_ctrl_agent;

    function new(string name = "fft_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mem_mux_scoreboard = mem_mux_scoreboard_t::type_id::create("mem_mux_scoreboard", this); 
        mem_mux_monitor = mem_mux_monitor_t::type_id::create("mem_mux_monitor", this);
        axis_master_agent = axis_master_agent_t::type_id::create("axis_master_agent", this);
        axis_slave_scoreboard = axis_slave_scoreboard_t::type_id::create("axis_slave_scoreboard", this);
        axis_slave_monitor = axis_slave_monitor_t::type_id::create("axis_slave_monitor", this);
        fft_ctrl_agent = fft_ctrl_agent_t::type_id::create("fft_ctrl_agent", this);
    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        mem_mux_monitor.mon_analysis_port.connect(mem_mux_scoreboard.mem_mux_trans_imp);
        axis_slave_monitor.mon_analysis_port.connect(axis_slave_scoreboard.axis_trans_imp);
    endfunction : connect_phase
endclass
