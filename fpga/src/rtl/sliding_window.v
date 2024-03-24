`include "fft_defs.vh"

module sliding_window (/*AUTOARG*/
   // Outputs
   s_axis_tready, axis_win2fft_tvalid, axis_win2fft_tlast,
   axis_win2fft_tdata, axis_win2fft_tkeep,
   // Inputs
   clk, reset, s_axis_tvalid, s_axis_tlast, s_axis_tdata,
   s_axis_tkeep, axis_win2fft_tready
   );

    parameter FFT_SIZE = 4096;
    parameter SAMPLE_WIDTH = 16;
      
    localparam IDLE = 0,
        READ0 = 1,
        READ1 = 2,
        MULT = 3,
        SEND = 4,
        FLUSH0 = 5,
        FLUSH1 = 6,
        FLUSH2 = 7;
    input clk, reset;

    // AXI stream signals
    input s_axis_tvalid;
    input s_axis_tlast;
    input [`IN_AXI_WIDTH-1:0] s_axis_tdata;
    input [`IN_BYTE_COUNT-1:0] s_axis_tkeep;
    output s_axis_tready;

    output axis_win2fft_tvalid;
    output axis_win2fft_tlast;
    output [`IN_AXI_WIDTH-1:0] axis_win2fft_tdata;
    output [`IN_BYTE_COUNT-1:0] axis_win2fft_tkeep;
    input axis_win2fft_tready;

    reg [$clog2(FFT_SIZE)-1:0] window_raddr_q;
    wire signed [SAMPLE_WIDTH-1:0] window_sample;
    wire window_ena;

    wire fifo_full;
    wire [SAMPLE_WIDTH-1:0] fifo_wdata;
    wire fifo_wen;

    wire fifo_empty;
    wire signed [SAMPLE_WIDTH-1:0] fifo_rdata;
    wire fifo_ren;
    wire fifo_read_states;

    reg signed [SAMPLE_WIDTH-1:0] fifo_rdata_q;

    wire signed [2*SAMPLE_WIDTH-1:0] window_mult_out;
    assign window_mult_out = fifo_rdata_q * window_sample;

    reg [SAMPLE_WIDTH-1:0] window_mult_q;

    reg overlap; // Status flag for when overlapping samples are being recirculated

    reg last_sample;

    assign axis_win2fft_tlast = 1'b0;
    assign axis_win2fft_tkeep = {`IN_BYTE_COUNT{1'b1}};
    assign axis_win2fft_tdata = window_mult_q;
    assign axis_win2fft_tvalid = (reader_state_q == SEND || reader_state_q == FLUSH0 || reader_state_q == FLUSH1 || reader_state_q == FLUSH2);

    assign fifo_read_states = (reader_state_q == READ0 || reader_state_q == READ1 || reader_state_q == MULT || reader_state_q == SEND);
    assign fifo_ren = axis_win2fft_tvalid ? axis_win2fft_tready & fifo_read_states: fifo_read_states;
    assign window_ena = fifo_ren;

    // AXI slave / FIFO writer
    assign s_axis_tready = reader_state_q == IDLE & ~fifo_full;
    assign fifo_wen = s_axis_tready ? s_axis_tvalid : (overlap & axis_win2fft_tready);
    assign fifo_wdata = s_axis_tready ? s_axis_tdata : fifo_rdata;

    // FIFO reader
    
    reg [2:0] reader_state_q;

    always @ (posedge clk) begin
        if (reset) begin
            reader_state_q <= IDLE;
            window_raddr_q <= 12'h000;
            overlap <= 1'b0;
            last_sample <= 1'b0;
        end else begin
            case (reader_state_q)
                IDLE: begin
                    reader_state_q <= fifo_full ? READ0 : IDLE;
                end

                READ0: begin
                    reader_state_q <= READ1;
                    window_raddr_q <= window_raddr_q + 1'b1;
                end

                READ1: begin
                    reader_state_q <= MULT;
                    window_raddr_q <= window_raddr_q + 1'b1;
                end

                MULT: begin
                    reader_state_q <= SEND;
                    window_raddr_q <= window_raddr_q + 1'b1;
                end

                SEND: begin
                    window_raddr_q <= axis_win2fft_tready ? window_raddr_q + 1'b1 : window_raddr_q;
                    overlap <= (window_raddr_q > 12'h3ff) & ~last_sample;
                    if (&window_raddr_q & axis_win2fft_tready) begin
                        reader_state_q <= FLUSH0;
                    end
                end

                FLUSH0: begin
                    if (axis_win2fft_tready) begin
                        reader_state_q <= FLUSH1;
                        overlap <= 1'b0;
                    end
                end

                FLUSH1: begin
                    if (axis_win2fft_tready) begin
                        reader_state_q <= FLUSH2;
                    end
                end

                FLUSH2: begin
                    if (axis_win2fft_tready) begin
                        reader_state_q <= IDLE;
                    end
                end

            endcase
            if (last_sample == 1'b1) begin
                last_sample <= ~fifo_empty;
            end else begin
                last_sample <= s_axis_tlast;
            end
        end
    end

    integer i;
    always @ (posedge clk) begin
        fifo_rdata_q <= fifo_ren ? fifo_rdata : fifo_rdata_q;
        window_mult_q <= axis_win2fft_tready ? window_mult_out[2*SAMPLE_WIDTH-2:SAMPLE_WIDTH-1] : window_mult_q;
    end

    rom1p16x4096 window_rom
    (
        .addra(window_raddr_q),
        .clka(clk),
        .douta(window_sample),
        .ena(window_ena)
    );

    fifo16x4096 sample_fifo
    (
        .clk(clk),
        .srst(reset),
        .full(fifo_full),
        .din(fifo_wdata),
        .wr_en(fifo_wen),
        .empty(fifo_empty),
        .dout(fifo_rdata),
        .rd_en(fifo_ren)
    );
 
endmodule
