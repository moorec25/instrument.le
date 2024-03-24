`include "fft_defs.vh"

module axis_bram_slave_inv(/*AUTOARG*/
   // Outputs
   axis_bram_slave_busy, axis_s2mem_waddra, axis_s2mem_wdataa,
   axis_s2mem_wea, axis_s2mem_waddrb, axis_s2mem_wdatab,
   axis_s2mem_web, s_axis_tready,
   // Inputs
   clk, reset, axis_bram_slave_go, s_axis_tvalid,
   s_axis_tlast, s_axis_tdata, s_axis_tkeep
   );

    parameter FFT_SIZE = 4096;
    parameter SAMPLE_WIDTH = 16;
    
    input clk, reset;

    // Go signal
    input axis_bram_slave_go;

    // Busy signal
    output axis_bram_slave_busy;

    // BRAM write address and data
    output [`ADDR_WIDTH-1:0] axis_s2mem_waddra; 
    output [`DATA_WIDTH-1:0] axis_s2mem_wdataa;
    output axis_s2mem_wea;

    output [`ADDR_WIDTH-1:0] axis_s2mem_waddrb; 
    output [`DATA_WIDTH-1:0] axis_s2mem_wdatab;
    output axis_s2mem_web;

    // AXI stream signals

    input s_axis_tvalid;
    input s_axis_tlast;
    input [63:0] s_axis_tdata;
    input [7:0] s_axis_tkeep;
    output s_axis_tready;
    
    assign axis_bram_slave_busy = axis_bram_s_state_q != IDLE;
    // Will always be ready to accept data
    assign s_axis_tready = axis_bram_s_state_q == WRITE;

    assign axis_s2mem_wea = s_axis_tready & s_axis_tvalid;
    assign axis_s2mem_wdataa = {s_axis_tdata[43:32], s_axis_tdata[21:0]};
    assign axis_s2mem_waddra = {1'b0, counter_q};

    wire [21:0] conjugate;
    assign conjugate = ~s_axis_tdata[21:0] + 1;
    assign axis_s2mem_web = s_axis_tready & s_axis_tvalid & (|counter_q[`ADDR_WIDTH-2:0]);
    assign axis_s2mem_wdatab = {s_axis_tdata[43:32], conjugate};
    assign axis_s2mem_waddrb = FFT_SIZE - counter_q;

    reg [`ADDR_WIDTH-1:0] counter_q = {(`ADDR_WIDTH){1'b0}};

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
                    if ((counter_q == FFT_SIZE/2) && s_axis_tvalid) begin
                        axis_bram_s_state_q <= IDLE;
                    end
                end
            endcase
        end

    end

endmodule
