`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.07.2025 18:37:34
// Design Name: 
// Module Name: spi_slave_control_select
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


module spi_slave_control_select (
    input         PCLK,
    input         PRESETn,
    input         mstr,
    input         spiswai,
    input  [1:0]  spi_mode,
    input         send_data,
    input  [11:0] BaudRateDivisor,  // Changed to 12 bits
    output        receive_data,
    output        ss,
    output        tip
);

    reg         ss_reg, tip_reg, rcv_reg;
    reg  [15:0] count;
    wire [15:0] target;
    wire        cond1, cond2;
    wire        enable_logic;
    wire        ss_next, tip_next, rcv_next;

    // Baud Rate Target calculation
    assign target = BaudRateDivisor * 16;

    // SPI mode condition checks
    assign cond1 = (spi_mode == 2'b00);
    assign cond2 = (spi_mode == 2'b01);

    // Enable logic based on spiswai, mstr and spi_mode
    assign enable_logic = (~spiswai) & ((cond1 & mstr) | (cond2 & mstr));

    // Next-state logic
    assign rcv_next = enable_logic && (count <= target - 1) ? send_data : rcv_reg;
    assign ss_next  = enable_logic && (count <= target - 1) ? 1'b0 : 1'b1;
    assign tip_next = ~ss_next;

    // Sequential logic
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            count    <= 16'hffff;
            rcv_reg  <= 1'b0;
            ss_reg   <= 1'b1;
            tip_reg  <= 1'b0;
        end else begin
            if (enable_logic) begin
                if (count <= target - 1)
                    count <= count + 1;
                else
                    count <= 16'hffff;
            end else begin
                count <= 16'hffff;
            end

            rcv_reg <= rcv_next;
            ss_reg  <= ss_next;
            tip_reg <= tip_next;
        end
    end

    // Output assignments
    assign receive_data = rcv_reg;
    assign ss           = ss_reg;
    assign tip          = tip_reg;

endmodule

