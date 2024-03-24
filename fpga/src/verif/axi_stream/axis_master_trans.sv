class axis_master_trans_t extends uvm_sequence_item;
    
    logic [15:0] left_sample;
    logic [15:0] right_sample;
    logic last;

    `uvm_object_utils_begin(axis_master_trans_t)
        `uvm_field_int(left_sample, UVM_ALL_ON);
        `uvm_field_int(right_sample, UVM_ALL_ON);
        `uvm_field_int(last, UVM_ALL_ON);
    `uvm_object_utils_end

    function new(string name = "axis_master_trans_t");
        super.new(name);
    endfunction

    
endclass

