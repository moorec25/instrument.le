class axis_master_seq_t extends uvm_sequence #(axis_master_trans_t);
    
    `uvm_object_utils(axis_master_seq_t);

    int stim_trace_l;
    int stim_trace_r;
    int sample_l, sample_r;
    axis_master_trans_t req;

    function new(string name = "axis_master_seq_t");
        super.new(name);
    endfunction

    virtual task body();
        stim_trace_l = $fopen("/home/carter/Documents/stft/stft.srcs/sim_1/stft_in_0.txt", "r");
        stim_trace_r = $fopen("/home/carter/Documents/stft/stft.srcs/sim_1/stft_in_1.txt", "r");
        while ($fscanf(stim_trace_l, "%d", sample_l) == 1 && $fscanf(stim_trace_r, "%d", sample_r) == 1) begin
           req = axis_master_trans_t::type_id::create("req");
           req.left_sample = sample_l;
           req.right_sample = sample_r;
           wait_for_grant();
           send_request(req);
           `uvm_info("axis_master_seq", $sformatf("Sending axi stream master transaction to driver %s", req.sprint()), UVM_HIGH)
        end
    endtask
            
endclass

