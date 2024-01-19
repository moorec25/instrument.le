`include "fft_defs.vh"

module address_gen (/*AUTOARG*/
   // Outputs
   addr_gen_busy, fft_raddra, fft_raddrb, fft_waddra, fft_waddrb,
   fft_wea, fft_web, fft_data_valid, twiddle_addr,
   // Inputs
   clk, reset, addr_gen_go, fft_level
   );

    parameter FFT_SIZE = 4096;
    localparam BFLY_LATENCY = 7;
    
    input clk, reset;

    input addr_gen_go;
    output addr_gen_busy;

    input [$clog2(`LEVELS)-1:0] fft_level;

    output [`LEVELS-1:0] fft_raddra;
    output [`LEVELS-1:0] fft_raddrb;

    output [`LEVELS-1:0] fft_waddra;
    output [`LEVELS-1:0] fft_waddrb;

    output fft_wea;
    output fft_web;

    output fft_data_valid;

    output [`LEVELS-2:0] twiddle_addr;

    reg [`LEVELS-2:0] bfly_count_q = 0;

    reg [`LEVELS-1:0] fft_waddra_q [BFLY_LATENCY-1:0];
    reg [`LEVELS-1:0] fft_waddrb_q [BFLY_LATENCY-1:0];

    wire [`LEVELS-1:0] raddra_shift;
    wire [`LEVELS-1:0] raddrb_shift;

    reg [BFLY_LATENCY-1:0] fft_data_valid_q;

    assign raddra_shift = {bfly_count_q, 1'b0};
    assign raddrb_shift = {bfly_count_q, 1'b1};

    assign fft_raddra = ((raddra_shift << fft_level) | (raddra_shift >> (`LEVELS-fft_level))) & {`LEVELS{1'b1}};
    assign fft_raddrb = ((raddrb_shift << fft_level) | (raddrb_shift >> (`LEVELS-fft_level))) & {`LEVELS{1'b1}};

    assign fft_waddra = fft_waddra_q[BFLY_LATENCY-1];
    assign fft_waddrb = fft_waddrb_q[BFLY_LATENCY-1];

    assign fft_data_valid = fft_data_valid_q[BFLY_LATENCY-1];
    assign fft_wea = fft_data_valid;
    assign fft_web = fft_data_valid;

    reg [`LEVELS-1:0] twiddle_mask = 0;

    assign twiddle_addr = bfly_count_q & twiddle_mask[`LEVELS-2:0];

    assign addr_gen_busy = addr_gen_state_q == COUNTING;

    reg addr_gen_state_q;

    localparam IDLE=0,
        COUNTING=1;

    always @ (posedge clk) begin
        
        if (reset) begin
            addr_gen_state_q <= IDLE;
        end else begin

            case(addr_gen_state_q)
                IDLE: begin
                    addr_gen_state_q <= addr_gen_go ? COUNTING : IDLE;
                end

                COUNTING: begin
                    addr_gen_state_q <= &bfly_count_q ? IDLE : COUNTING;
                end
            endcase

        end
    end

    always @ (posedge clk) begin
        case (addr_gen_state_q)
            IDLE: begin
                twiddle_mask <= addr_gen_go ? {1'b1, twiddle_mask[`LEVELS-1:1]} : twiddle_mask;
            end

            COUNTING: begin
                bfly_count_q <= bfly_count_q + 1'b1;
                if (&bfly_count_q && fft_level == (`LEVELS-1)) begin
                    twiddle_mask <= {`LEVELS{1'b0}};
                end
            end
        endcase
    end

    integer i;
    always @ (posedge clk) begin
        fft_waddra_q[0] <= fft_raddra;
        fft_waddrb_q[0] <= fft_raddrb;
        fft_data_valid_q[0] <= addr_gen_state_q == COUNTING;
        for (i=0; i<BFLY_LATENCY-1; i=i+1) begin
            fft_waddra_q[i+1] <= fft_waddra_q[i];
            fft_waddrb_q[i+1] <= fft_waddrb_q[i];
            fft_data_valid_q[i+1] <= fft_data_valid_q[i];
        end
    end

endmodule
