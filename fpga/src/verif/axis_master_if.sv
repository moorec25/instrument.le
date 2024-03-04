interface axis_master_if_t(/*AUTOARG*/
   // Inputs
   clk, resetn
   );

    input clk, resetn;
    logic [31:0] tdata;
    logic [3:0] tkeep;
    logic tlast;
    logic tvalid;
    logic tready;
    
endinterface
