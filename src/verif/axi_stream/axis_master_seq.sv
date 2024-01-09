class axis_master_seq_t extends uvm_sequence #(axis_trans_t);
    
    `uvm_object_utils(axis_master_seq_t);

    int stim_trace;
    int sample;
    axis_trans_t req;

    function new(string name = "axis_master_seq_t");
        super.new(name);
    endfunction

    virtual task body();
        stim_trace = $fopen("/home/carter/Documents/instrument.le/out/random/fft_in.txt", "r");
        while ($fscanf(stim_trace, "%d", sample) == 1) begin
           req = axis_trans_t::type_id::create("req");
           req.data_r = sample;
           req.data_i = 0;
           wait_for_grant();
           send_request(req);
           `uvm_info("axis_master_seq", $sformatf("Sending axi stream master transaction to driver %s", req.sprint()), UVM_HIGH)
        end
    endtask
            
endclass

