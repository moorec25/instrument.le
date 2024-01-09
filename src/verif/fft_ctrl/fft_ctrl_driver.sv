class fft_ctrl_driver_t extends uvm_driver #(uvm_sequence_item);
    
    `uvm_component_utils(fft_ctrl_driver_t);

    virtual fft_ctrl_if_t fft_ctrl_vif;

    function new(string name = "fft_ctrl_driver_t", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual fft_ctrl_if_t)::get(this, "", "fft_ctrl_vif", fft_ctrl_vif)) begin
            `uvm_fatal("fft_ctrl_driver", "fft_ctrl_vif not found")
        end
    endfunction : build_phase
    
    virtual task run_phase(uvm_phase phase);
        uvm_sequence_item req;
        forever begin
            if (fft_ctrl_vif.resetn == 0) begin
                fft_ctrl_vif.fft_go = 0;
                wait (fft_ctrl_vif.resetn == 1);
            end
            else begin
                seq_item_port.get_next_item(req);
                @ (posedge fft_ctrl_vif.clk);
                fft_ctrl_vif.fft_go = 1;
                wait(fft_ctrl_vif.fft_busy);
                @ (posedge fft_ctrl_vif.clk);
                fft_ctrl_vif.fft_go = 0;
                wait(~fft_ctrl_vif.fft_busy);
                @ (posedge fft_ctrl_vif.clk);
                seq_item_port.item_done();
            end
        end
    endtask : run_phase
endclass
