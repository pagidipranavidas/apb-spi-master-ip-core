`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2025 11:46:38
// Design Name: 
// Module Name: spi_master_top
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


module spi_master_top (
    input         PCLK,
    input         PRESETn,
    input  [2:0]  PADDR,
    input         PWRITE,
    input         PSEL,
    input         PENABLE,
    input  [7:0]  PWDATA,
    input  [7:0]  miso,             // ? Corrected to 8-bit input

    output [7:0]  PRDATA,
    output        PREADY,
    output        PSLVERR,
    output        MOSI,
    output        SCLK,
    output        SS,
    output        spi_interrupt_request
);

    // Internal wires for interconnection
    wire mstr, cpol, cpha, lsbfe;
    wire [2:0] spiswai, sppr, spr;
    wire [1:0] spi_mode;
    wire send_data;
    wire [7:0] mosi_data;
    wire [7:0] miso_data;
    wire receive_data;
    wire tip;
    wire flag_low, flag_high;
    wire [2:0] flags_low, flags_high;
    wire [11:0] BaudRateDivisor;

    // APB Slave Interface
    apb_slave_interface u_apb (
        .PCLK(PCLK), .PRESETn(PRESETn), .PADDR(PADDR), .PWRITE(PWRITE),
        .PSEL(PSEL), .PENABLE(PENABLE), .PWDATA(PWDATA), .ss(SS),
        .miso_data(miso_data), .receive_data(receive_data), .tip(tip),
        .PRDATA(PRDATA), .mstr(mstr), .cpol(cpol), .cpha(cpha), .lsbfe(lsbfe),
        .spiswai(spiswai), .sppr(sppr), .spr(spr),
        .spi_interrupt_request(spi_interrupt_request),
        .PREADY(PREADY), .PSLVERR(PSLVERR),
        .send_data(send_data), .mosi_data(mosi_data), .spi_mode(spi_mode)
    );

    // Baud Rate Generator
    baud_rate_generator u_brg (
        .PCLK(PCLK), .PRESETn(PRESETn), .spi_mode(spi_mode),
        .spiswai(spiswai[0]),
        .sppr(sppr), .spr(spr), .cpol(cpol), .cpha(cpha), .ss(SS),
        .sclk(SCLK), .flag_low(flag_low), .flag_high(flag_high),
        .flags_low(flags_low), .flags_high(flags_high),
        .BaudRateDivisor(BaudRateDivisor)
    );

    // Shift Register
    shift_register u_shift (
        .PCLK(PCLK), .PRESETn(PRESETn), .ss(SS), .send_data(send_data),
        .lsbfe(lsbfe), .cpha(cpha), .cpol(cpol),
        .flag_low(flag_low), .flag_high(flag_high),
        .flags_low(flags_low), .flags_high(flags_high),
        .data_mosi(mosi_data), .miso(miso[0]),        // Using bit-0 of 8-bit input
        .receive_data(receive_data), .mosi(MOSI), .data_miso(miso_data)
    );

    // Slave Control Select
    spi_slave_control_select u_ssc (
        .PCLK(PCLK), .PRESETn(PRESETn),
        .mstr(mstr), .spiswai(spiswai[0]),
        .spi_mode(spi_mode), .send_data(send_data),
        .BaudRateDivisor(BaudRateDivisor),
        .receive_data(receive_data), .ss(SS), .tip(tip)
    );

endmodule

