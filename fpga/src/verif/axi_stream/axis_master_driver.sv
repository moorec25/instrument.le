class axis_master_driver_t extends uvm_driver #(axis_master_trans_t);
    
    `uvm_component_utils(axis_master_driver_t);

    virtual axis_master_if_t axis_vif;

    rand bit [2:0] delay;

    constraint cycle_delay { delay dist {0:=50, [1:7]:/50}; }

    function new(string name = "axis_master_driver_t", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axis_master_if_t)::get(this, "", "axis_master_vif", axis_vif)) begin
            `uvm_fatal("axis_master_driver", "axis_master_vif not found")
        end
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        axis_master_trans_t req;
        forever begin
            if(axis_vif.resetn == 0) begin
                axis_vif.tdata = 0;
                axis_vif.tkeep = 0;
                axis_vif.tlast = 0;
                axis_vif.tvalid = 0;
                wait (axis_vif.resetn == 1);
            end
            else begin
                axis_vif.tvalid = 0;
                this.randomize();
                repeat (delay+1) @ (posedge axis_vif.clk);
                `uvm_info("axis_master_driver", "Waiting for axi stream master transaction", UVM_HIGH)
                seq_item_port.get_next_item(req);
                `uvm_info("axis_master_driver", $sformatf("Getting axi stream transaction from sequencer %s", req.sprint()), UVM_HIGH)
                axis_vif.tvalid = 1;
                axis_vif.tkeep = 8'hff;
                axis_vif.tdata = {req.left_sample, req.right_sample};
                axis_vif.tlast = 0;
                wait(axis_vif.tready);
                @ (posedge axis_vif.clk);
                seq_item_port.item_done();
            end
        end
    endtask : run_phase     
    
endclass
