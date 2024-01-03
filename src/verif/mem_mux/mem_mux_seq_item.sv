class mem_mux_seq_item_t extends uvm_sequence_item;

    logic [15:0] waddra;
    logic [15:0] waddrb;
    logic [31:0] wdataa_r;
    logic [31:0] wdataa_i;
    logic [31:0] wdatab_r;
    logic [31:0] wdatab_i;
    logic [7:0] wmem_id;

    `uvm_object_utils_begin(mem_mux_seq_item_t)
        `uvm_field_int(waddra, UVM_ALL_ON)
        `uvm_field_int(wdataa_r, UVM_ALL_ON)
        `uvm_field_int(wdataa_i, UVM_ALL_ON)
        `uvm_field_int(waddrb, UVM_ALL_ON)
        `uvm_field_int(wdatab_r, UVM_ALL_ON)
        `uvm_field_int(wdatab_i, UVM_ALL_ON)
        `uvm_field_int(wmem_id, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "mem_mux_seq_item_t");
        super.new(name);
    endfunction

    
endclass
