class axis_slave_trans_t extends uvm_sequence_item;
    
    logic [31:0] k_real;
    logic [31:0] k_imag;
    logic channel;

    `uvm_object_utils_begin(axis_slave_trans_t)
        `uvm_field_int(k_real, UVM_ALL_ON);
        `uvm_field_int(k_imag, UVM_ALL_ON);
        `uvm_field_int(channel, UVM_ALL_ON);
    `uvm_object_utils_end

    function new(string name = "axis_slave_t");
        super.new(name);
    endfunction

    
endclass

