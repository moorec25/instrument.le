interface axis_slave_if_t(/*AUTOARG*/
   // Inputs
   clk, resetn
   );

    input clk, resetn;
    logic [63:0] tdata;
    logic [7:0] tkeep;
    logic tlast;
    logic tvalid;
    logic tready;
    
endinterface
