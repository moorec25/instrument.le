module overlap_add (/*AUTOARG*/
   // Outputs
   axis_ifft2ola_tready, m_axis_tvalid, m_axis_tlast, m_axis_tdata,
   m_axis_tkeep,
   // Inputs
   clk, reset, axis_ifft2ola_tvalid, axis_ifft2ola_tlast,
   axis_ifft2ola_tdata, axis_ifft2ola_tkeep, m_axis_tready
   );
    
   parameter SAMPLE_WIDTH = 16;

   input clk, reset;
    
   input last_frame;
    // AXI stream signals

    input axis_ifft2ola_tvalid;
    input axis_ifft2ola_tlast;
    signed input [SAMPLE_WIDTH-1:0] axis_ifft2ola_tdata;
    input [SAMPLE_WIDTH/8:0] axis_ifft2ola_tkeep;
    output axis_ifft2ola_tready;

    output reg m_axis_tvalid;
    output m_axis_tlast;
    output [SAMPLE_WIDTH-1:0] m_axis_tdata;
    output [SAMPLE_WIDTH/8:0] m_axis_tkeep;
    input m_axis_tready;

    localparam IDLE = 0,
        READ0 = 1,
        READ1 = 2,
        FILL= 3,
        SEND = 4,
        OLA = 5,
        FLUSH = 6;


    reg [2:0] ola_state_q;

    reg [10:0] overlap_counter_q;
    reg [11:0] window_raddr_q;

    reg mult_valid_q;
    signed reg [15:0] window_mult_q;
    signed wire [31:0] window_mult_out;
    assign window_mult_out = window_sample * axis_ifft2ola_tdata;

    reg add_valid_q;
    signed reg [15:0] add_out_q;
    signed reg [15:0] add_in2;

    signed wire [15:0] window_sample;
    reg window_ena;

    wire [15:0] fifo_wdata;
    wire [15:0] fifo_rdata;
    reg fifo_wen;
    reg fifo_ren;
    wire fifo_empty;
    wire fifo_full;

    assign fifo_wdata = add_out_q;
    assign m_axis_tdata = fifo_rdata;

    assign axis_ifft2ola_tready = (ola_state_q == FILL) || (ola_state_q == OLA);

    always @ (posedge clk) begin
        if (reset) begin
            ola_state_q <= FILL;
            mult_valid_q <= 1'b0;
            m_axis_tvalid <= 1'b0;
        end else begin
            case (ola_state_q)
                IDLE: begin
                    ola_state_q <= READ0;
                end

                READ0: begin
                    ola_state_q <= READ1;
                end

                READ1: begin
                    ola_state_q <= fifo_empty ? FILL : OLA;
                    mult_valid_q <= 1'b0;
                end

                FILL: begin
                    ola_state_q <= fifo_full ? SEND : ola_state_q;
                    mult_valid_q <= axis_ifft2ola_tvalid;
                end

                SEND: begin
                    if (overlap_counter_q == 1024) begin
                        ola_state_q <= last_frame ? FLUSH : IDLE;
                    end
                end

                OLA: begin
                    ola_state_q <= (overlap_counter_q == 3072) ? FILL : ola_state_q;
                    mult_valid_q <= axis_ifft2ola_tvalid;
                end

                FLUSH: begin
                    ola_state_q <= fifo_empty ? IDLE: ola_state_q;
                end
            endcase
        end
    end

    always @ (posedge clk) begin

        case (ola_state_q)
            IDLE: begin
                window_raddr_q <= 12'd0;
                overlap_counter_q <= 11'd0;
            end
            
            READ0: begin
                window_raddr_q <= window_raddr_q + 1'b1;
            end

            READ1: begin
                window_raddr_q <= window_raddr_q + 1'b1;
            end

            FILL: begin
                window_raddr_q <= axis_ifft2ola_tvalid ? window_raddr_q + 1'b1 : window_raddr_q;
            end

            SEND: begin
                if (overlap_counter_q == 1024) begin
                    overlap_counter_q <= 11'd0;
                end else begin
                    overlap_counter_q <= m_axis_tready ? overlap_counter_q + 1'b1 : overlap_counter_q;
                end
            end

        endcase
    end

    always @ (posedge clk) begin
        window_mult_q <= window_mult_out[31:16];
        add_out_q <= window_mult_q + add_in2;
        add_valid_q <= mult_valid_q;
    end

    always @* begin
        window_ena = 1'b0;
        fifo_wen = 1'b0;
        fifo_ren = 1'b0;
        add_in2 = 16'd0;
        m_axis_tvalid = 1'b0;
        case (ola_state_q)
            IDLE: begin
                window_ena = 1'b1;
            end

            READ0: begin
                window_ena = 1'b1;
            end

            READ1: begin
                window_ena = 1'b1;
            end

            FILL: begin
                window_ena = axis_ifft2ola_tvalid;
                fifo_wen = add_valid_q & ~fifo_full;
                fifo_ren = fifo_full;
            end

            SEND: begin
                fifo_ren = m_axis_tready;
                m_axis_tvalid = 1'b1;
            end

            OLA: begin
                window_ena = axis_ifft2ola_tvalid;
                fifo_ren = axis_ifft2ola_tvalid;
                fifo_wen = add_valid_q;
                add_in2 = fifo_rdata;
            end

        endcase
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
