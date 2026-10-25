`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.07.2025 13:27:48
// Design Name: 
// Module Name: shift_register
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


module shift_register (
    input  wire        PCLK,
    input  wire        PRESETn,
    input  wire        ss,
    input  wire        send_data,
    input  wire        lsbfe,
    input  wire        cpha,
    input  wire        cpol,
    input  wire        flag_low,
    input  wire        flag_high,
    input  wire [2:0]  flags_low,
    input  wire [2:0]  flags_high,
    input  wire [7:0]  data_mosi,
    input  wire        miso,
    input  wire        receive_data,

    output reg         mosi,
    output reg  [7:0]  data_miso
);

    reg [7:0] shift_reg;
    reg [2:0] count;
    reg       internal_clk;

    // Simulate SPI clock phase/polarity behavior
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            internal_clk <= cpol;
        else
            internal_clk <= ~internal_clk;  // toggling on every clk edge (emulates SPI clk behavior)
    end

    wire shift_enable;
    assign shift_enable = (cpha == 0) ? (internal_clk == ~cpol) : (internal_clk == cpol);

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            shift_reg  <= 8'b0;
            data_miso  <= 8'b0;
            count      <= 3'b0;
            mosi       <= 1'b0;
        end else if (!ss) begin  // Active-low chip select
            if (send_data) begin
                shift_reg <= data_mosi;
                count     <= 3'd7;
                mosi      <= lsbfe ? data_mosi[0] : data_mosi[7];
            end else if (shift_enable) begin
                if ((flag_low && (count == flags_low)) || (flag_high && (count == flags_high))) begin
                    if (lsbfe) begin
                        shift_reg <= {miso, shift_reg[7:1]};
                        mosi      <= shift_reg[0];  // next bit to shift out
                    end else begin
                        shift_reg <= {shift_reg[6:0], miso};
                        mosi      <= shift_reg[7];
                    end
                    if (count != 0)
                        count <= count - 1;
                end

                // Store received byte when complete
                if (count == 3'd0 && receive_data) begin
                    data_miso <= shift_reg;
                end
            end
        end
    end

endmodule

