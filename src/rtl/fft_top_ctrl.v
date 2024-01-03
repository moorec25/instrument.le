`include "fft_defs.vh"

module fft_top_ctrl(/*AUTOARG*/
   // Outputs
   fft_busy, axis_bram_slave_go, addr_gen_go, axis_bram_master_go,
   fft_level, wmem_id, rmem_id, axis_rx, axis_tx,
   // Inputs
   clk, reset, fft_go, axis_bram_slave_busy, addr_gen_busy,
   fft_data_valid, axis_bram_master_busy
   );

    parameter FFT_SIZE = 4096;
    localparam BFLY_LATENCY = 6; // Latency from issuing mem read to getting result

    input clk, reset;

    input fft_go;
    output fft_busy;

    input axis_bram_slave_busy;
    output reg axis_bram_slave_go;

    input addr_gen_busy;
    output reg addr_gen_go;
    input fft_data_valid;

    input axis_bram_master_busy;
    output reg axis_bram_master_go;

    output reg [$clog2(`LEVELS)-1:0] fft_level;

    output wmem_id;
    output rmem_id;

    output axis_rx;
    output axis_tx;

    reg [$clog2(BFLY_LATENCY):0] delay_counter_q;

    assign fft_busy = (fft_top_state_q != IDLE);

    assign rmem_id = fft_level[0];
    assign wmem_id = ~fft_level[0];

    assign axis_rx = (fft_top_state_q == AXIS_READ);
    assign axis_tx = (fft_top_state_q == AXIS_SEND);

    localparam IDLE = 0,
        AXIS_READ = 1,
        COMPUTE = 2,
        FLUSH_PIPE = 3,
        AXIS_SEND = 4;

    reg [2:0] fft_top_state_q;

    always @ (posedge clk) begin

        if (reset) begin
            fft_top_state_q <= IDLE;
        end else begin
            case (fft_top_state_q)
                
                IDLE: begin
                    fft_top_state_q <= fft_go ? AXIS_READ : IDLE;
                end

                AXIS_READ: begin
                    fft_top_state_q <= axis_bram_slave_busy ? AXIS_READ : COMPUTE;
                end

                COMPUTE: begin
                    fft_top_state_q <= addr_gen_busy ? COMPUTE : FLUSH_PIPE; 
                end

                FLUSH_PIPE: begin
                    if (~fft_data_valid) begin
                        fft_top_state_q <= (fft_level == `LEVELS-1) ? AXIS_SEND : COMPUTE;
                    end
                end

                AXIS_SEND: begin
                    fft_top_state_q <= axis_bram_master_busy ? AXIS_SEND : IDLE;
                end
                
            endcase
        end
    end

    always @ (posedge clk) begin
        case (fft_top_state_q)

            IDLE: begin
                fft_level <= {`LEVELS{1'b0}};
            end

            FLUSH_PIPE: begin
                if (~fft_data_valid) begin
                    fft_level <= fft_level + 1'b1;
                end
            end

        endcase
    end

    always @* begin
        axis_bram_slave_go = 1'b0;
        addr_gen_go = 1'b0;
        axis_bram_master_go = 1'b0;
        case (fft_top_state_q)

            IDLE: begin
                if (fft_go) begin
                    axis_bram_slave_go = 1'b1;
                end
            end

            AXIS_READ: begin
                if (~axis_bram_slave_busy) begin
                    addr_gen_go = 1'b1;
                end
            end

            COMPUTE: begin
            end

            FLUSH_PIPE: begin
                if (~fft_data_valid) begin
                    addr_gen_go = (fft_level == `LEVELS-1) ? 1'b0 : 1'b1;
                    axis_bram_master_go = (fft_level == `LEVELS-1) ? 1'b1 : 1'b0;
                end
            end

        endcase
    end

endmodule
