class stft_env_t extends uvm_env;
    
    `uvm_component_utils(stft_env_t);

    axis_master_agent_t axis_master_agent;

    axis_slave_scoreboard_t axis_slave_scoreboard;
    axis_slave_monitor_t axis_slave_monitor;

    mem_mux_scoreboard_t channel0_mem_scoreboard;
    mem_mux_monitor_t channel0_mem_monitor;

    mem_mux_scoreboard_t channel1_mem_scoreboard;
    mem_mux_monitor_t channel1_mem_monitor;

    function new(string name = "stft_env_t", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axis_master_agent = axis_master_agent_t::type_id::create("axis_master_agent", this);
        axis_slave_scoreboard = axis_slave_scoreboard_t::type_id::create("axis_slave_scoreboard", this);
        axis_slave_monitor = axis_slave_monitor_t::type_id::create("axis_slave_monitor", this);

        channel0_mem_monitor = new("channel0_mem_monitor", this, "mem_mux_vif_l");
        channel0_mem_scoreboard = new("channel0_mem_scoreboard", this, "/home/carter/Documents/stft/stft.srcs/sim_1/fft_mem_wr_trace_0.txt");

        channel1_mem_monitor = new("channel1_mem_monitor", this, "mem_mux_vif_r");
        channel1_mem_scoreboard = new("channel1_mem_scoreboard", this, "/home/carter/Documents/stft/stft.srcs/sim_1/fft_mem_wr_trace_1.txt");
    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        axis_slave_monitor.mon_analysis_port.connect(axis_slave_scoreboard.axis_trans_imp);
        channel0_mem_monitor.mon_analysis_port.connect(channel0_mem_scoreboard.mem_mux_trans_imp);
        channel1_mem_monitor.mon_analysis_port.connect(channel1_mem_scoreboard.mem_mux_trans_imp);
    endfunction : connect_phase
    
endclass
