`include "fft_defs.vh"

module memory_mux (/*AUTOARG*/
   // Outputs
   fft_rdataa, fft_rdatab, axis_mem2m_rdata,
   // Inputs
   clk, axis_rx, axis_tx, wmem_id, rmem_id, fft_raddra, fft_raddrb,
   fft_waddra, fft_waddrb, fft_wdataa, fft_wdatab, fft_wea, fft_web,
   axis_s2mem_we, axis_s2mem_waddr, axis_s2mem_wdata,
   axis_mem2m_clken, axis_mem2m_raddr
   );

    parameter FFT_SIZE = 4096;
    parameter SAMPLE_WIDTH = 16;

    input clk;

    input axis_rx;
    input axis_tx;

    input wmem_id;
    input rmem_id;

    input [`ADDR_WIDTH-1:0] fft_raddra;
    input [`ADDR_WIDTH-1:0] fft_raddrb;

    output [`DATA_WIDTH-1:0] fft_rdataa;
    output [`DATA_WIDTH-1:0] fft_rdatab;

    input [`ADDR_WIDTH-1:0] fft_waddra;
    input [`ADDR_WIDTH-1:0] fft_waddrb;

    input [`DATA_WIDTH-1:0] fft_wdataa;
    input [`DATA_WIDTH-1:0] fft_wdatab;

    input fft_wea;
    input fft_web;

    input axis_s2mem_we;
    input [`ADDR_WIDTH-1:0] axis_s2mem_waddr;
    input [`DATA_WIDTH-1:0] axis_s2mem_wdata;

    input axis_mem2m_clken;
    input [`ADDR_WIDTH-1:0] axis_mem2m_raddr;
    output [`DATA_WIDTH-1:0] axis_mem2m_rdata;

    reg [`ADDR_WIDTH-1:0] mem0_addra;
    reg [`DATA_WIDTH-1:0] mem0_dina;
    reg mem0_wea;
    reg mem0_ena;
    wire [`DATA_WIDTH-1:0] mem0_douta;

    reg [`ADDR_WIDTH-1:0] mem0_addrb;
    reg [`DATA_WIDTH-1:0] mem0_dinb;
    reg mem0_web;
    wire [`DATA_WIDTH-1:0] mem0_doutb;

    reg [`ADDR_WIDTH-1:0] mem1_addra;
    reg [`DATA_WIDTH-1:0] mem1_dina;
    reg mem1_wea;
    reg mem1_ena;
    wire [`DATA_WIDTH-1:0] mem1_douta;

    reg [`ADDR_WIDTH-1:0] mem1_addrb;
    reg [`DATA_WIDTH-1:0]mem1_dinb;
    reg mem1_web;
    wire [`DATA_WIDTH-1:0] mem1_doutb;

    assign axis_mem2m_rdata = mem0_douta;
    assign fft_rdataa = (rmem_id == 0) ? mem0_douta : mem1_douta;
    assign fft_rdatab = (rmem_id == 0) ? mem0_doutb : mem1_doutb;

    always @* begin
        mem0_addra = fft_raddra;
        mem0_dina = {`DATA_WIDTH{1'b0}};
        mem0_wea = 1'b0;
        mem0_ena = 1'b1;
        mem0_addrb = fft_raddrb;
        mem0_dinb = {`DATA_WIDTH{1'b0}};
        mem0_web = 1'b0;
        if (axis_rx) begin
            mem0_addra = axis_s2mem_waddr;
            mem0_dina = axis_s2mem_wdata;
            mem0_wea = axis_s2mem_we;
            mem0_ena = 1'b1;
        end
        else if (axis_tx) begin
            mem0_addra = axis_mem2m_raddr;
            mem0_dina = {`DATA_WIDTH{1'b0}};
            mem0_wea = 1'b0;
            mem0_ena = axis_mem2m_clken;
        end
        else if (wmem_id == 0) begin
            mem0_addra = fft_waddra;
            mem0_dina = fft_wdataa;
            mem0_wea = fft_wea;
            mem0_ena = 1'b1;
            mem0_addrb = fft_waddrb;
            mem0_dinb = fft_wdatab;
            mem0_web = fft_web;
        end
    end

    always @* begin
        if (wmem_id == 1) begin
            mem1_addra = fft_waddra;
            mem1_dina = fft_wdataa;
            mem1_wea = fft_wea;
            mem1_ena = 1'b1;
            mem1_addrb = fft_waddrb;
            mem1_dinb = fft_wdatab;
            mem1_web = fft_web;
        end
        else begin
            mem1_addra = fft_raddra;
            mem1_dina = {`DATA_WIDTH{1'b0}};
            mem1_wea = 1'b0;
            mem1_ena = 1'b1;
            mem1_addrb = fft_raddrb;
            mem1_dinb = {`DATA_WIDTH{1'b0}};
            mem1_web = 1'b0;
        end
    end

    ram2p44x4096 mem0 (
        .clka(clk),
        .addra(mem0_addra),
        .dina(mem0_dina),
        .douta(mem0_douta),
        .wea(mem0_wea),
        .ena(mem0_ena),
        .clkb(clk),
        .addrb(mem0_addrb),
        .dinb(mem0_dinb),
        .doutb(mem0_doutb),
        .web(mem0_web)
    );

    ram2p44x4096 mem1 (
        .clka(clk),
        .addra(mem1_addra),
        .dina(mem1_dina),
        .douta(mem1_douta),
        .wea(mem1_wea),
        .ena(mem1_ena),
        .clkb(clk),
        .addrb(mem1_addrb),
        .dinb(mem1_dinb),
        .doutb(mem1_doutb),
        .web(mem1_web)
    );

endmodule
