`include "fft_defs.vh"
// AXI stream bram master
// Writes out content of bram as an AXI stream

module axis_bram_master(/*AUTOARG*/
   // Outputs
   axis_bram_master_busy, axis_mem2m_raddr, axis_mem2m_clken,
   m_axis_tvalid, m_axis_tlast, m_axis_tdata, m_axis_tkeep,
   // Inputs
   clk, reset, axis_bram_master_go, axis_mem2m_rdata, m_axis_tready
   );

    parameter SAMPLE_WIDTH = 16;
    parameter FFT_SIZE = 4096;

    input clk, reset;

    // Go signal
    input axis_bram_master_go;

    // Busy signal
    output axis_bram_master_busy;

    // BRAM raddr, clk enable, rdata;
    output reg [`ADDR_WIDTH-1:0] axis_mem2m_raddr;
    output axis_mem2m_clken;
    input [`DATA_WIDTH-1:0] axis_mem2m_rdata;

    // AXI stream signals
    output m_axis_tvalid;
    output m_axis_tlast;
    output [`AXI_WIDTH-1:0] m_axis_tdata;
    output [`BYTE_COUNT-1:0] m_axis_tkeep;
    input m_axis_tready;

    wire [`AXI_WIDTH/2-1:0] data_r;
    wire [`AXI_WIDTH/2-1:0] data_i;

    // States
    localparam IDLE = 6'b000001,
        READING0    = 6'b000010,
        READING1    = 6'b000100,
        READ_SEND   = 6'b001000,
        SEND0       = 6'b010000,
        SEND1       = 6'b100000;

    // Tell tool to use one hot encoding for FSM
    (* fsm_encoding = "one_hot" *) reg [5:0] axis_master_state_q;

    wire done_reading;
    assign done_reading = &axis_mem2m_raddr;

    assign axis_bram_master_busy = axis_master_state_q != IDLE;

    assign m_axis_tkeep = {`BYTE_COUNT{1'b1}}; // Will always be using all bytes so tie tkeep high

    // Sign extend data and pack into 64 bits
    assign data_r = { {(`AXI_WIDTH/2-`DATA_WIDTH/2){axis_mem2m_rdata[`DATA_WIDTH-1]}}, axis_mem2m_rdata[`DATA_WIDTH-1:`DATA_WIDTH/2] };
    assign data_i = { {(`AXI_WIDTH/2-`DATA_WIDTH/2){axis_mem2m_rdata[`DATA_WIDTH/2-1]}}, axis_mem2m_rdata[`DATA_WIDTH/2-1:0] };
    assign m_axis_tdata = {data_r, data_i}; // Wire memory read data to stream data port

    // Write data is valid in these 3 states
    assign m_axis_tvalid = (axis_master_state_q == READ_SEND) | (axis_master_state_q == SEND0) | (axis_master_state_q == SEND1);
    // Last write occurs in state SEND1
    assign m_axis_tlast = axis_master_state_q == SEND1;

    assign axis_mem2m_clken = m_axis_tvalid ? m_axis_tready : 1'b1; // Stall mem read pipeline when slave not ready

    always @ (posedge clk) begin

        if (reset) begin
            axis_master_state_q <= IDLE;
        end else begin

            // BRAM read / AXI stream send state machine
            // IDLE: wait for go signal, initiate first memory read on go
            // READING0: Initiate second mem read
            // READING1: Initiate third mem read
            // READ_SEND: Data from first mem read available
            // Begin writing to stream
            // Continue reading from memory 
            // Once all reads have been issued, perform the last 2 writes
            // After last write, go back to idle

            case (axis_master_state_q)
                IDLE: begin
                    if (axis_bram_master_go) begin
                        axis_master_state_q <= READING0;
                    end
                end

                READING0: begin
                    axis_master_state_q <= READING1;
                end

                READING1: begin
                    axis_master_state_q <= READ_SEND;
                end

                READ_SEND: begin
                    if (done_reading) begin
                        axis_master_state_q <= SEND0;
                    end
                end

                SEND0: begin
                    if (m_axis_tready) begin
                        axis_master_state_q <= SEND1;
                    end
                end

                SEND1: begin
                    if (m_axis_tready) begin
                        axis_master_state_q <= IDLE;
                    end
                end

            endcase
        end
    end

    // Data path
    // Increment read address depending on state
    // Done in a seperate always block because reset isn't being used for address
    // If put in same always block as the state machine, synthesis tool will
    // use the reset signal to clock gate the address register and add a bunch
    // of logic
    
    always @ (posedge clk) begin
        case (axis_master_state_q)
            IDLE: begin
                axis_mem2m_raddr <= {`ADDR_WIDTH{1'b0}};
            end

            READING0: begin
                axis_mem2m_raddr <= axis_mem2m_raddr + 1'b1;
            end

            READING1: begin
                axis_mem2m_raddr <= axis_mem2m_raddr + 1'b1;
            end

            READ_SEND: begin
                axis_mem2m_raddr <= m_axis_tready ? axis_mem2m_raddr + 1'b1 : axis_mem2m_raddr;
            end

        endcase
    end

endmodule
