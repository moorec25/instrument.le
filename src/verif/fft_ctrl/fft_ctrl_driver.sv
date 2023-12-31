class fft_ctrl_dirver_t extends uvm_driver #(transactionType);
    
    `uvm_component_utils(fft_ctrl_dirver_t);

    function new(string name = "fft_ctrl_dirver_t", uvm_component parent);
        super.new(name, parent);
    endfunction

    
endclass
