`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.07.2025 18:43:19
// Design Name: 
// Module Name: tb_spi_slave_control_select
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


`timescale 1ns / 1ps

module tb_spi_slave_control_select;

    reg         PCLK, PRESETn;
    reg         mstr, spiswai, send_data;
    reg  [1:0]  spi_mode;
    reg  [11:0] BaudRateDivisor;
    wire        receive_data, ss, tip;

    // Instantiate DUT
    spi_slave_control_select uut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .mstr(mstr),
        .spiswai(spiswai),
        .spi_mode(spi_mode),
        .send_data(send_data),
        .BaudRateDivisor(BaudRateDivisor),
        .receive_data(receive_data),
        .ss(ss),
        .tip(tip)
    );

    // Clock generation
    initial PCLK = 0;
    always #5 PCLK = ~PCLK;  // 100MHz clock

    initial begin
        $dumpfile("spi_slave_control_select.vcd");
        $dumpvars(0, tb_spi_slave_control_select);

        // Initial values
        PRESETn         = 0;
        mstr            = 0;
        spiswai         = 0;
        spi_mode        = 2'b00;
        send_data       = 0;
        BaudRateDivisor = 12'd5;
        #20;

        // Apply reset
        PRESETn = 1;
        #10;

        // Test Case 1: Normal operation with spi_mode = 00
        mstr      = 1;
        spiswai   = 0;
        send_data = 1;
        spi_mode  = 2'b00;
        #200;

        // Test Case 2: Change to spi_mode = 01
        spi_mode = 2'b01;
        #100;

        // Test Case 3: Disable via spiswai
        spiswai = 1;
        #100;

        #5000 $finish;
    end

endmodule

