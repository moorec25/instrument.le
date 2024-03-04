class axis_slave_monitor_t extends uvm_monitor;
    
    `uvm_component_utils(axis_slave_monitor_t);

    virtual axis_slave_if_t axis_vif;

    axis_slave_trans_t axis_trans;

    uvm_analysis_port #(axis_slave_trans_t) mon_analysis_port;

    logic channel = 0;

    rand bit [2:0] delay;
    constraint cycle_delay { delay dist {0:=50, [1:7]:/50}; }

    function new(string name = "axis_slave_monitor_t", uvm_component parent);
        super.new(name, parent);
        mon_analysis_port = new("mon_analysis_port", this);
        axis_trans = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axis_slave_if_t)::get(this, "", "axis_slave_vif", axis_vif)) begin
            `uvm_fatal("axis_slave_monitor", "axis_slave_vif not found")
        end
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        forever begin
            if (axis_vif.resetn == 0) begin
                axis_vif.tready = 0;
                wait (axis_vif.resetn == 1);
            end else begin
                axis_vif.tready = 0;
                this.randomize();
                repeat (delay) @ (posedge axis_vif.clk);
                axis_vif.tready = 1;
                wait(axis_vif.tvalid);
                @ (posedge axis_vif.clk);
                axis_trans.k_real = axis_vif.tdata[63:32];
                axis_trans.k_imag = axis_vif.tdata[31:0];
                axis_trans.channel = channel;
                mon_analysis_port.write(axis_trans);
                if (axis_vif.tlast) begin
                    channel = ~channel;
                    axis_vif.tready = 0;
                    @ (posedge axis_vif.clk);
                end
            end
        end
    endtask : run_phase

endclass
