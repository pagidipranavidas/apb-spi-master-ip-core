`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2025 11:57:04
// Design Name: 
// Module Name: tb_spi_master_top
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


// Updated tb_spi_master_top with proper send_data triggering sequence

module tb_spi_master_top;

    // Inputs
    reg         PCLK;
    reg         PRESETn;
    reg  [2:0]  PADDR;
    reg         PWRITE;
    reg         PSEL;
    reg         PENABLE;
    reg  [7:0]  PWDATA;
    reg  [7:0]  miso;             // 8-bit for testing

    // Outputs
    wire [7:0]  PRDATA;
    wire        PREADY;
    wire        PSLVERR;
    wire        MOSI;
    wire        SCLK;
    wire        SS;
    wire        spi_interrupt_request;

    // Instantiate the DUT
    spi_master_top dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PADDR(PADDR),
        .PWRITE(PWRITE),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWDATA(PWDATA),
        .miso(miso),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),
        .MOSI(MOSI),
        .SCLK(SCLK),
        .SS(SS),
        .spi_interrupt_request(spi_interrupt_request)
    );

    // Clock generation
    initial PCLK = 0;
    always #5 PCLK = ~PCLK;

    // Test sequence
    initial begin
        $display("Starting SPI Master Top Testbench...");
        PADDR   = 3'b000;
        PWRITE  = 0;
        PSEL    = 0;
        PENABLE = 0;
        PWDATA  = 8'h00;
        miso    = 8'h00;

        // Apply Reset
        PRESETn = 0;
        #20;
        PRESETn = 1;

        // Write to control_reg (addr = 0): mstr=1, cpol=0, cpha=1, lsbfe=0
        apb_write(3'b000, 8'b10010000);

        // Write to clk_div_reg (addr = 1)
        apb_write(3'b001, 8'd4);  // SPPR=0, SPR=4 => BRDIV = 16

        // Write to tx_data_reg (addr = 2)
        apb_write(3'b010, 8'hA5);  // MOSI data = 0xA5

        // Write to spi_mode_reg (addr = 3)
        apb_write(3'b011, 8'b00000001);  // mode = 01

        // Set up send_data condition: tip = 1, ss = 1 then ss = 0
        #10;
        force dut.u_apb.tip = 1;
        force dut.u_apb.ss  = 1;
        #20;
        force dut.u_apb.ss  = 0;

        // Simulate MISO receive pattern: 0x3C = 00111100
        miso = 8'b00111100;
        repeat (8) begin
            #10 miso = {miso[6:0], 1'b0};
        end

        // Read status_reg (addr = 3)
        #50;
        apb_read(3'b011);

        // Read back PRDATA from rx_data_reg (addr = 2)
        apb_read(3'b010);

        // Display outputs
        #20;
        $display("PRDATA = %h", PRDATA);
        $display("MOSI = %b, SCLK = %b, SS = %b", MOSI, SCLK, SS);
        $display("Interrupt = %b", spi_interrupt_request);

        #5000 $finish;
    end

    // Task for APB write transaction
    task apb_write(input [2:0] addr, input [7:0] data);
        begin
            @(posedge PCLK);
            PADDR   = addr;
            PWDATA  = data;
            PWRITE  = 1;
            PSEL    = 1;
            PENABLE = 0;

            @(posedge PCLK);
            PENABLE = 1;

            @(posedge PCLK);
            PSEL    = 0;
            PENABLE = 0;
            PWRITE  = 0;
        end
    endtask

    // Task for APB read transaction
    task apb_read(input [2:0] addr);
        begin
            @(posedge PCLK);
            PADDR   = addr;
            PWRITE  = 0;
            PSEL    = 1;
            PENABLE = 0;

            @(posedge PCLK);
            PENABLE = 1;

            @(posedge PCLK);
            $display("READ [0x%0x] = %h", addr, PRDATA);
            PSEL    = 0;
            PENABLE = 0;
        end
    endtask

endmodule



