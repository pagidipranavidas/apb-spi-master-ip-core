`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.07.2025 13:49:21
// Design Name: 
// Module Name: shift_register_tb
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

module shift_register_tb;

    reg         PCLK;
    reg         PRESETn;
    reg         ss;
    reg         send_data;
    reg         lsbfe;
    reg         cpha;
    reg         cpol;
    reg         flag_low;
    reg         flag_high;
    reg  [2:0]  flags_low;
    reg  [2:0]  flags_high;
    reg  [7:0]  data_mosi;
    reg         miso;
    reg         receive_data;

    wire        mosi;
    wire [7:0]  data_miso;

    // Instantiate DUT
    shift_register uut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .ss(ss),
        .send_data(send_data),
        .lsbfe(lsbfe),
        .cpha(cpha),
        .cpol(cpol),
        .flag_low(flag_low),
        .flag_high(flag_high),
        .flags_low(flags_low),
        .flags_high(flags_high),
        .data_mosi(data_mosi),
        .miso(miso),
        .receive_data(receive_data),
        .mosi(mosi),
        .data_miso(data_miso)
    );

    // Clock generation
    initial PCLK = 0;
    always #5 PCLK = ~PCLK;

    reg [7:0] miso_shift_data = 8'hA5;  // 10100101
    integer i;

    initial begin
        $dumpfile("shift_register.vcd");
        $dumpvars(0, shift_register_tb);

        // Initialize
        PRESETn = 0; ss = 1; send_data = 0;
        lsbfe = 0; cpha = 0; cpol = 0;
        flag_low = 0; flag_high = 1;
        flags_low = 3'd1; flags_high = 3'd1;
        data_mosi = 8'h3C;
        miso = 0; receive_data = 0;

        #20 PRESETn = 1;  // release reset

        #10 ss = 0; send_data = 1;
        #10 send_data = 0;

        // Begin simulated MISO shifting
        for (i = 0; i < 8; i = i + 1) begin
            @(posedge PCLK);
            #1 miso = miso_shift_data[7 - i];  // MSB first
            $display("Time=%0t | MISO=%b | MOSI=%b | Count=%0d", $time, miso, mosi, uut.count);
            #9;
        end

        receive_data = 1;
        #10 receive_data = 0;

        $display("Received Data MISO: %b", data_miso);
        #5000 $finish;
    end

endmodule

