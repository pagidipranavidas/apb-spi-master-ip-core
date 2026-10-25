`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.07.2025 20:55:17
// Design Name: 
// Module Name: apb_slave_interface
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


module apb_slave_interface (
    input           PCLK,
    input           PRESETn,
    input  [2:0]    PADDR,
    input           PWRITE,
    input           PSEL,
    input           PENABLE,
    input  [7:0]    PWDATA,
    input           ss,
    input  [7:0]    miso_data,
    input           receive_data,
    input           tip,

    output reg [7:0] PRDATA,
    output           mstr,
    output           cpol,
    output           cpha,
    output           lsbfe,
    output [2:0]     spiswai,
    output [2:0]     sppr,
    output [2:0]     spr,
    output           spi_interrupt_request,
    output reg       PREADY,
    output reg       PSLVERR,
    output           send_data,
    output [7:0]     mosi_data,
    output [1:0]     spi_mode
);

    // Internal registers
    reg [7:0] control_reg;
    reg [7:0] status_reg;
    reg [7:0] tx_data_reg;
    reg [7:0] rx_data_reg;
    reg [7:0] clk_div_reg;
    reg [1:0] spi_mode_reg;

    // Write and Read logic
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            control_reg <= 8'd0;
            status_reg  <= 8'd0;
            tx_data_reg <= 8'd0;
            rx_data_reg <= 8'd0;
            clk_div_reg <= 8'd0;
            spi_mode_reg <= 2'd0;
            PRDATA      <= 8'd0;
            PREADY      <= 1'b1;
            PSLVERR     <= 1'b0;
        end else if (PSEL && PENABLE) begin
            PREADY <= 1'b1;
            PSLVERR <= 1'b0;

            if (PWRITE) begin
                case (PADDR)
                    3'b000: control_reg  <= PWDATA;
                    3'b001: clk_div_reg  <= PWDATA;
                    3'b010: tx_data_reg  <= PWDATA;
                    3'b011: spi_mode_reg <= PWDATA[1:0];
                    default: PSLVERR     <= 1'b1;
                endcase
            end else begin
                case (PADDR)
                    3'b000: PRDATA <= control_reg;
                    3'b001: PRDATA <= clk_div_reg;
                    3'b010: PRDATA <= rx_data_reg;
                    3'b011: PRDATA <= status_reg;
                    default: PSLVERR <= 1'b1;
                endcase
            end
        end
    end

    // SPI receive logic
    always @(posedge PCLK) begin
        if (receive_data) begin
            rx_data_reg <= miso_data;
        end
    end

    // Output signal assignments from registers
    assign mstr  = control_reg[7];
    assign cpol  = control_reg[6];
    assign cpha  = control_reg[5];
    assign lsbfe = control_reg[4];
    assign spiswai = control_reg[3:1];
    assign spi_interrupt_request = status_reg[0];
    assign send_data = tip && !ss;
    assign mosi_data = tx_data_reg;
    assign spi_mode = spi_mode_reg;

    // Fixed (not mapped) outputs
    assign sppr = 3'b000; // Can be mapped as needed
    assign spr  = 3'b000; // Can be mapped as needed

endmodule
