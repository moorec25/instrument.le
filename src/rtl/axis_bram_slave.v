`include "fft_defs.vh"

module axis_bram_slave(/*AUTOARG*/
   // Outputs
   axis_bram_slave_busy, axis_s2mem_waddr, axis_s2mem_wdata,
   axis_s2mem_we, s_axis_tready,
   // Inputs
   clk, reset, axis_bram_slave_go, s_axis_tvalid, s_axis_tlast,
   s_axis_tdata, s_axis_tkeep
   );

    parameter FFT_SIZE = 4096;
    parameter SAMPLE_WIDTH = 16;
    
    input clk, reset;

    // Go signal
    input axis_bram_slave_go;

    // Busy signal
    output axis_bram_slave_busy;

    // BRAM write address and data
    output [`ADDR_WIDTH-1:0] axis_s2mem_waddr; 
    output [`DATA_WIDTH-1:0] axis_s2mem_wdata;
    output axis_s2mem_we;

    // AXI stream signals

    input s_axis_tvalid;
    input s_axis_tlast;
    input [`AXI_WIDTH-1:0] s_axis_tdata;
    input [`BYTE_COUNT-1:0] s_axis_tkeep;
    output s_axis_tready;
    
    assign axis_bram_slave_busy = axis_bram_s_state_q != IDLE;
    // Will always be ready to accept data
    assign s_axis_tready = axis_bram_s_state_q == WRITE;

    assign axis_s2mem_we = s_axis_tready & s_axis_tvalid;
    assign axis_s2mem_wdata = {s_axis_tdata[`AXI_WIDTH/2+`DATA_WIDTH/2-1:`AXI_WIDTH/2], s_axis_tdata[`DATA_WIDTH/2-1:0]};

    reg [`ADDR_WIDTH-1:0] counter_q = {`ADDR_WIDTH{1'b0}};

    // Write to memory in bit reversed order
    generate
        for (genvar i=0; i<`ADDR_WIDTH; i=i+1) begin
            assign axis_s2mem_waddr[i] = counter_q[`ADDR_WIDTH-1-i];
        end
    endgenerate


    localparam IDLE = 0,
        WRITE = 1;

    reg axis_bram_s_state_q;

    always @ (posedge clk) begin
        
        if (reset) begin
            axis_bram_s_state_q <= IDLE;
        end else begin
            case (axis_bram_s_state_q)
                IDLE: begin
                    if (axis_bram_slave_go) begin
                        axis_bram_s_state_q <= WRITE;
                    end
                    counter_q <= {`ADDR_WIDTH{1'b0}};
                end

                WRITE: begin
                    counter_q <=  s_axis_tvalid ? counter_q + 1'b1 : counter_q;
                    if ((counter_q == FFT_SIZE-1) && s_axis_tvalid) begin
                        axis_bram_s_state_q <= IDLE;
                    end
                end
            endcase
        end

    end

endmodule
