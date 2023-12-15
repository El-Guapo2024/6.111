`timescale 1ns / 1ps
`default_nettype none

module uart_imu_tb();

    logic clk;
    logic rst;
    logic rx;
    logic tx;
    logic [15:0] heading;
    logic [7:0] debug_data [4:0];

    uart_imu uut( 
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx),
        .heading(heading),
        .debug_data(debug_data)
    );

    logic[7:0] data_sent [4:0];

    // Parameters and type definitions
    parameter CLOCK_FREQ = 100_000_000;  // 100 MHz
    parameter BAUD_RATE = 115200;        // 115200 bps
    parameter DATA_BITS = 8;             // 8-bit data
    parameter STOP_BITS = 1;             // 1 stop bit
    parameter PARITY_BIT = 0;            // No parity
    parameter BOOT_TIME = 8_000_000;     // 80 ms in clock cycles
    parameter BAUD_RATE_DIVISOR = CLOCK_FREQ / BAUD_RATE; // Baud rate divisor

    always begin
        #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk = !clk;
    end
    //initial block...this is our test simulation
    initial begin
        $dumpfile("uart_imu.vcd"); //file to store value change dump (vcd)
        $dumpvars(0,uart_imu_tb);
        $display("Starting Sim"); //print nice message at start
        clk = 0;
        rst = 0;
        rx = 1;
        #10;
        rst = 1;
        #10;
        rst = 0;
        $display("Wait for Boot up");
        #10_000_00;
        $display("Should be setting opr_mode");
        for(integer i = 0; i < 5; i++)begin
            #8680; //start bit
            for(integer j = 0; j < 8; j++) begin
                #4340;
                data_sent[i][j] = tx;
                #4340;
            end
            #8680; //Stop bit
        end
        $display("%8h, %8h, %8h, %8h, %8h", data_sent[0], data_sent[1], data_sent[2], data_sent[3], data_sent[4]);
        #10000;
        $display("Now going to send error message for opr_mode set-up");
        data_sent[0][7:0] = 8'hEE;
        data_sent[1][7:0] = 8'h03;
        for(integer i = 0; i < 5; i++)begin
            rx = 0;
            #8680; //start bit
            for(integer j = 0; j < 8; j++) begin
                rx = data_sent[i][j];
                #8680;
            end
            rx = 1;
            #8680; //Stop bit
        end
        $display("Finished sending error message hope to get setting opr_mode again");
        data_sent[0][7:0] = 8'h00;
        data_sent[1][7:0] = 8'h00;
        for(integer i = 0; i < 5; i++)begin
            #8680; //start bit
            for(integer j = 0; j < 8; j++) begin
                #4340;
                data_sent[i][j] = tx;
                #4340;
            end
            #8680; //Stop bit
        end
        $display("%8h, %8h, %8h, %8h, %8h", data_sent[0], data_sent[1], data_sent[2], data_sent[3], data_sent[4]);
        #10000;
        $display("Simulation finished");
        $finish;
    end
endmodule
`default_nettype wire