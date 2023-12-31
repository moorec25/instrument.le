class fft_test extends uvm_test;
    
    `uvm_component_utils(fft_test);

    fft_env_t fft_env;
    function new(string name = "fft_test", uvm_component parent);
        super.new(name, parent);
        fft_env = fft_env_t::type_id::create("fft_env", this);
    endfunction

   virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
   endfunction : build_phase 

   virtual task run_phase(uvm_phase phase);
    `uvm_info("fft_test", "running test", UVM_NONE)
   endtask : run_phase

   virtual function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    `uvm_info("fft_test", "final phase", UVM_NONE)
    
   endfunction: final_phase
endclass
