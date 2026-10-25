`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2025 20:07:13
// Design Name: 
// Module Name: tb_baud_rate_generator
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


`timescale 1ns/1ps

module tb_baud_rate_generator;

    reg        PCLK;
    reg        PRESETn;
    reg [1:0]  spi_mode;
    reg        spiswai;
    reg [2:0]  sppr;
    reg [2:0]  spr;
    reg        cpol;
    reg        cpha;
    reg        ss;

    wire       sclk;
    wire       flag_low, flag_high, flags_low, flags_high;
    wire [11:0] BaudRateDivisor;

    // Instantiate the DUT
    baud_rate_generator uut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .spi_mode(spi_mode),
        .spiswai(spiswai),
        .sppr(sppr),
        .spr(spr),
        .cpol(cpol),
        .cpha(cpha),
        .ss(ss),
        .sclk(sclk),
        .flag_low(flag_low),
        .flag_high(flag_high),
        .flags_low(flags_low),
        .flags_high(flags_high),
        .BaudRateDivisor(BaudRateDivisor)
    );

    // Clock Generation: 100 MHz
    always #5 PCLK = ~PCLK;

    initial begin
        $display("---- Starting Baud Generator Simulation ----");

        // Initial state
        PCLK = 0;
        PRESETn = 0;
        spi_mode = 2'b00;
        spiswai = 0;
        sppr = 3'b000;
        spr = 3'b000;
        cpol = 0;
        cpha = 0;
        ss = 0;

        #20 PRESETn = 1;
        #10 ss = 1; // Select the slave

        // Test Mode 0 (CPOL=0, CPHA=0)
        sppr = 3'b001; // divisor base = 2
        spr = 3'b011;  // multiplier = 2^4 = 16 ? divisor = 2×16 = 32
        spi_mode = 2'b00;
        cpol = 0;
        cpha = 0;
        #500;

        // Test Mode 3 (CPOL=1, CPHA=1)
        sppr = 3'b010;
        spr = 3'b010; // 3 × 8 = 24
        spi_mode = 2'b11;
        cpol = 1;
        cpha = 1;
        #500;

        // Test Mode 2 (CPOL=1, CPHA=0)
        sppr = 3'b011;
        spr = 3'b001; // 4 × 4 = 16
        spi_mode = 2'b10;
        cpol = 1;
        cpha = 0;
        #500;
       #5000 $finish;
    end

endmodule

