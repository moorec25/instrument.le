class fft_ctrl_seq_t extends uvm_sequence #(uvm_sequence_item);
    
    `uvm_object_utils(fft_ctrl_seq_t);

    uvm_sequence_item req;

    function new(string name = "fft_ctrl_seq_t");
        super.new(name);
    endfunction

    virtual task body();
        req = uvm_sequence_item::type_id::create("req");
        wait_for_grant();
        send_request(req);
        `uvm_info("fft_ctrl_seq", "Sending FFT Go signal", UVM_NONE)
        wait_for_item_done();
        `uvm_info("fft_ctrl_seq", "FFT Done", UVM_NONE)
    endtask
        
endclass
