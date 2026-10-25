`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.07.2025 21:16:13
// Design Name: 
// Module Name: apb_slave_interface_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module apb_slave_interface_tb;

    // Inputs
    reg         PCLK;
    reg         PRESETn;
    reg  [2:0]  PADDR;
    reg         PWRITE;
    reg         PSEL;
    reg         PENABLE;
    reg  [7:0]  PWDATA;
    reg         ss;
    reg  [7:0]  miso_data;
    reg         receive_data;
    reg         tip;

    // Outputs
    wire [7:0]  PRDATA;
    wire        mstr;
    wire        cpol;
    wire        cpha;
    wire        lsbfe;
    wire [2:0]  spiswai;
    wire [2:0]  sppr;
    wire [2:0]  spr;
    wire        spi_interrupt_request;
    wire        PREADY;
    wire        PSLVERR;
    wire        send_data;
    wire [7:0]  mosi_data;
    wire [1:0]  spi_mode;

    // Instantiate DUT
    apb_slave_interface dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PADDR(PADDR),
        .PWRITE(PWRITE),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWDATA(PWDATA),
        .ss(ss),
        .miso_data(miso_data),
        .receive_data(receive_data),
        .tip(tip),
        .PRDATA(PRDATA),
        .mstr(mstr),
        .cpol(cpol),
        .cpha(cpha),
        .lsbfe(lsbfe),
        .spiswai(spiswai),
        .sppr(sppr),
        .spr(spr),
        .spi_interrupt_request(spi_interrupt_request),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),
        .send_data(send_data),
        .mosi_data(mosi_data),
        .spi_mode(spi_mode)
    );

    // Clock generation
    initial PCLK = 0;
    always #5 PCLK = ~PCLK;

    // Test procedure
    initial begin
        // Initialize
        PRESETn = 0;
        PADDR = 3'd0;
        PWRITE = 0;
        PSEL = 0;
        PENABLE = 0;
        PWDATA = 8'd0;
        ss = 0;
        miso_data = 8'h00;
        receive_data = 0;
        tip = 0;

        // Apply Reset
        #10 PRESETn = 1;

        // Write to control register (addr 0)
        apb_write(3'b000, 8'b10110110);  // control: mstr=1, cpol=0, cpha=1, lsbfe=1

        // Write to clk_div register (addr 1)
        apb_write(3'b001, 8'd50);

        // Write to tx_data register (addr 2)
        apb_write(3'b010, 8'hA5);

        // Write to spi_mode (addr 3)
        apb_write(3'b011, 8'b00000010);  // mode = 2

        // Simulate incoming data
        #10 miso_data = 8'h3C;
        receive_data = 1;
        #10 receive_data = 0;

        // Read from rx_data register (addr 2)
        apb_read(3'b010);

        // Activate transfer
        tip = 1;
        ss = 0;  // SS active low
        #10;
        tip = 0;
        ss = 1;

        // Print results
        #10;
        $display("mosi_data = %h", mosi_data);
        $display("send_data = %b", send_data);
        $display("SPI Mode  = %b", spi_mode);
        $display("mstr = %b, cpol = %b, cpha = %b, lsbfe = %b", mstr, cpol, cpha, lsbfe);

        #5000 $finish;
    end

    // APB Write Task
    task apb_write(input [2:0] addr, input [7:0] data);
    begin
        @(posedge PCLK);
        PADDR   <= addr;
        PWDATA  <= data;
        PWRITE  <= 1;
        PSEL    <= 1;
        PENABLE <= 0;

        @(posedge PCLK);
        PENABLE <= 1;

        @(posedge PCLK);
        PWRITE  <= 0;
        PSEL    <= 0;
        PENABLE <= 0;
    end
    endtask

    // APB Read Task
    task apb_read(input [2:0] addr);
    begin
        @(posedge PCLK);
        PADDR   <= addr;
        PWRITE  <= 0;
        PSEL    <= 1;
        PENABLE <= 0;

        @(posedge PCLK);
        PENABLE <= 1;

        @(posedge PCLK);
        $display("Read from %b = %h", addr, PRDATA);
        PSEL    <= 0;
        PENABLE <= 0;
    end
    endtask

endmodule



