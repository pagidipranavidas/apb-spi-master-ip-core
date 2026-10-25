`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2025 19:29:48
// Design Name: 
// Module Name: baud_rate_generator
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


module baud_rate_generator (
    input        PCLK,
    input        PRESETn,
    input  [1:0] spi_mode,     // now fully used
    input        spiswai,
    input  [2:0] sppr,
    input  [2:0] spr,
    input        cpol,
    input        cpha,
    input        ss,

    output reg   sclk,
    output reg   flag_low,
    output reg   flag_high,
    output reg   flags_low,
    output reg   flags_high,
    output reg [11:0] BaudRateDivisor
);

    // Internal Signals
    reg [11:0] count;
    reg        pre_sclk;

    // Compute divisor: (SPPR + 1) * (2 ^ (SPR + 1))
    wire [11:0] br_divisor = (sppr + 1) * (1 << (spr + 1));

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            BaudRateDivisor <= 0;
        else
            BaudRateDivisor <= br_divisor;
    end

    // Counter and pre_sclk toggler
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            count <= 0;
            pre_sclk <= cpol;
        end
        else if (!spiswai && ss) begin
            if (count == BaudRateDivisor - 1) begin
                count <= 0;
                pre_sclk <= ~pre_sclk;
            end else begin
                count <= count + 1;
            end
        end
    end

    // SPI mode based sclk output (uses CPOL, CPHA, spi_mode[1:0])
    always @(*) begin
        case (spi_mode)
            2'b00: sclk = pre_sclk;     // CPOL=0, CPHA=0
            2'b01: sclk = ~pre_sclk;    // CPOL=0, CPHA=1
            2'b10: sclk = pre_sclk;     // CPOL=1, CPHA=0
            2'b11: sclk = ~pre_sclk;    // CPOL=1, CPHA=1
            default: sclk = pre_sclk;
        endcase
    end

    // Flag Logic from microarchitecture (with spi_mode and cpha involvement)
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            flag_low    <= 0;
            flag_high   <= 0;
            flags_low   <= 0;
            flags_high  <= 0;
        end else begin
            // Count comparison for 4 phases
            flag_low    <= (count == (BaudRateDivisor >> 2));       // 1/4
            flag_high   <= (count == (BaudRateDivisor >> 1));       // 1/2
            flags_low   <= (count == ((BaudRateDivisor * 3) >> 2)); // 3/4
            flags_high  <= (count == (BaudRateDivisor - 1));        // End
        end
    end

endmodule


