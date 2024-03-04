class mem_mux_monitor_t extends uvm_monitor;

    `uvm_component_utils(mem_mux_monitor_t);

    virtual mem_mux_if_t vif;
    mem_mux_seq_item_t mem_mux_trans;

    string if_name;
    
    uvm_analysis_port #(mem_mux_seq_item_t) mon_analysis_port;

    function new(string name = "mem_mux_monitor", uvm_component parent, string if_name = "mem_mux_vif");
        super.new(name, parent);
        mem_mux_trans = new();
        mon_analysis_port = new ("mon_analysis_port", this);
        this.if_name = if_name;
        
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (! uvm_config_db#(virtual mem_mux_if_t)::get(this, "", this.if_name, vif)) begin
            `uvm_fatal(get_type_name(), this.if_name)
        end

    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        
        forever begin
            @ (posedge vif.clk);
            if (vif.fft_wea || vif.fft_web) begin
                `uvm_info("mem_mux_monitor", "Memory Write Enabled", UVM_HIGH)
                mem_mux_trans.waddra = vif.fft_waddra;
                mem_mux_trans.waddrb = vif.fft_waddrb;
                mem_mux_trans.wdataa_r = $signed(vif.fft_wdataa[43:22]);
                mem_mux_trans.wdataa_i = $signed(vif.fft_wdataa[21:0]);
                mem_mux_trans.wdatab_r = $signed(vif.fft_wdatab[43:22]);
                mem_mux_trans.wdatab_i = $signed(vif.fft_wdatab[21:0]);
                mem_mux_trans.wmem_id = vif.wmem_id;
                mon_analysis_port.write(mem_mux_trans);
            end
        end

    endtask : run_phase
    
endclass
