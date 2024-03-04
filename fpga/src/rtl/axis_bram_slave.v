`include "fft_defs.vh"

module axis_bram_slave(/*AUTOARG*/
   // Outputs
   axis_bram_slave_busy, axis_s2mem_waddr, axis_s2mem_wdata,
   axis_s2mem_we, axis_win2fft_tready,
   // Inputs
   clk, reset, axis_bram_slave_go, axis_win2fft_tvalid,
   axis_win2fft_tlast, axis_win2fft_tdata, axis_win2fft_tkeep
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

    input axis_win2fft_tvalid;
    input axis_win2fft_tlast;
    input [`IN_AXI_WIDTH-1:0] axis_win2fft_tdata;
    input [`IN_BYTE_COUNT-1:0] axis_win2fft_tkeep;
    output axis_win2fft_tready;
    
    assign axis_bram_slave_busy = axis_bram_s_state_q != IDLE;
    // Will always be ready to accept data
    assign axis_win2fft_tready = axis_bram_s_state_q == WRITE;

    assign axis_s2mem_we = axis_win2fft_tready & axis_win2fft_tvalid;
    assign axis_s2mem_wdata = {{(`DATA_WIDTH/2 - SAMPLE_WIDTH){axis_win2fft_tdata[SAMPLE_WIDTH-1]}}, axis_win2fft_tdata, {`DATA_WIDTH/2{1'b0}}};

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
                    counter_q <=  axis_win2fft_tvalid ? counter_q + 1'b1 : counter_q;
                    if ((counter_q == FFT_SIZE-1) && axis_win2fft_tvalid) begin
                        axis_bram_s_state_q <= IDLE;
                    end
                end
            endcase
        end

    end

endmodule
