class axis_trans_t extends uvm_sequence_item;
    
    logic [31:0] data_r;
    logic [31:0] data_i;

    `uvm_object_utils_begin(axis_trans_t)
        `uvm_field_int(data_r, UVM_ALL_ON);
        `uvm_field_int(data_i, UVM_ALL_ON);
    `uvm_object_utils_end

    function new(string name = "axis_trans_t");
        super.new(name);
    endfunction

    
endclass

