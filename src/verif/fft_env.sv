class fft_env_t extends uvm_env;

    `uvm_component_utils(fft_env_t);
    
    mem_mux_scoreboard_t mem_mux_scoreboard;
    mem_mux_monitor_t mem_mux_monitor;

    function new(string name = "fft_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mem_mux_scoreboard = mem_mux_scoreboard_t::type_id::create("mem_mux_scoreboard", this); 
        mem_mux_monitor = mem_mux_monitor_t::type_id::create("mem_mux_monitor", this);
    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        mem_mux_monitor.mon_analysis_port.connect(mem_mux_scoreboard.mem_mux_trans_imp);
    endfunction : connect_phase
endclass
