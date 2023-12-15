`timescale 1ns / 1ps
`default_nettype none

module uart_imu_new_tb();

    logic clk;
    logic rst;
    logic rx;
    logic tx;
    logic [15:0] heading;

    uart_imu_new uut( 
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx),
        .heading(heading)
    );

    logic[7:0] data_sent [4:0];

    always begin
        #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk = !clk;
    end
    //initial block...this is our test simulation
    initial begin
        $dumpfile("uart_imu_new.vcd"); //file to store value change dump (vcd)
        $dumpvars(0,uart_imu_new_tb);
        $display("Starting Sim"); //print nice message at start
    // set IDLE logic
        clk = 0;
        rst = 0;
        rx = 1;
    // rst system
        #10;
        rst = 1;
        #10;
        rst = 0;
    // Wait for Boot up
        $display("Wait for Boot up");
        #1_000_000;
    // Setting opr_mode
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
        #100;
        $display("Now going to send error message for opr_mode set-up");
        data_sent[0][7:0] = 8'hEE;
        data_sent[1][7:0] = 8'h03;
        for(integer i = 0; i < 2; i++)begin
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
        $display("Now going to send correct message for opr_mode set-up");
        data_sent[0][7:0] = 8'hEE;
        data_sent[1][7:0] = 8'h01;
        for(integer i = 0; i < 2; i++)begin
            rx = 0;
            #8680; //start bit
            for(integer j = 0; j < 8; j++) begin
                rx = data_sent[i][j];
                #8680;
            end
            rx = 1;
            #8680; //Stop bit
        end
    // checking CALI_READ
        $display("Finished sending error message hope to get CALI_READ message");
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
        #100;
        $display("Now going to send error message for CALI_READ");
        data_sent[0][7:0] = 8'hEE;
        data_sent[1][7:0] = 8'h00;
        for(integer i = 0; i < 2; i++)begin
            rx = 0;
            #8680; //start bit
            for(integer j = 0; j < 8; j++) begin
                rx = data_sent[i][j];
                #8680;
            end
            rx = 1;
            #8680; //Stop bit
        end
        $display("Finished sending error message hope to get CALI_READ message");
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
        #100;
        $display("Now going to send correct message for CALI_READ");
        data_sent[0][7:0] = 8'hBB;
        data_sent[1][7:0] = 8'hFF;
        for(integer i = 0; i < 2; i++)begin
            rx = 0;
            #8680; //start bit
            for(integer j = 0; j < 8; j++) begin
                rx = data_sent[i][j];
                #8680;
            end
            rx = 1;
            #8680; //Stop bit
        end
    // Reading MSB and LSB correct
        $display("Finished sending correct message hope to get MSB message");
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
        #100;
        $display("Now going to send correct message for MSB");
        data_sent[0][7:0] = 8'hBB;
        data_sent[1][7:0] = 8'h01;
        for(integer i = 0; i < 2; i++)begin
            rx = 0;
            #8680; //start bit
            for(integer j = 0; j < 8; j++) begin
                rx = data_sent[i][j];
                #8680;
            end
            rx = 1;
            #8680; //Stop bit
        end
        $display("Finished sending correct message hope to get LSB message");
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
        #100;
        $display("Now going to send correct message for LSB");
        data_sent[0][7:0] = 8'hBB;
        data_sent[1][7:0] = 8'hFF;
        for(integer i = 0; i < 2; i++)begin
            rx = 0;
            #8680; //start bit
            for(integer j = 0; j < 8; j++) begin
                rx = data_sent[i][j];
                #8680;
            end
            rx = 1;
            #8680; //Stop bit
        end
        $display("Finished sending correct message hope to get MSB message");
        $display("%16h", heading);
    // Reading MSB and Error
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
        #100;
        $display("Now going to send error message for MSB");
        data_sent[0][7:0] = 8'hCC;
        data_sent[1][7:0] = 8'hCC;
        for(integer i = 0; i < 2; i++)begin
            rx = 0;
            #8680; //start bit
            for(integer j = 0; j < 8; j++) begin
                rx = data_sent[i][j];
                #8680;
            end
            rx = 1;
            #8680; //Stop bit
        end
        $display("Finished sending error message hope to get MSB message");
    // Reading LSB and error
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
        #100;
        $display("Now going to send correct message for MSB");
        data_sent[0][7:0] = 8'hBB;
        data_sent[1][7:0] = 8'h08;
        for(integer i = 0; i < 2; i++)begin
            rx = 0;
            #8680; //start bit
            for(integer j = 0; j < 8; j++) begin
                rx = data_sent[i][j];
                #8680;
            end
            rx = 1;
            #8680; //Stop bit
        end
        $display("Finished sending correct message hope to get LSB message");
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
        #100;
        $display("Now going to send error message for LSB");
        data_sent[0][7:0] = 8'hCC;
        data_sent[1][7:0] = 8'hCC;
        for(integer i = 0; i < 2; i++)begin
            rx = 0;
            #8680; //start bit
            for(integer j = 0; j < 8; j++) begin
                rx = data_sent[i][j];
                #8680;
            end
            rx = 1;
            #8680; //Stop bit
        end
        $display("Finished sending error message hope to get LSB message");
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
        #100;
        $display("Now going to send correct message for LSB");
        data_sent[0][7:0] = 8'hBB;
        data_sent[1][7:0] = 8'h88;
        for(integer i = 0; i < 2; i++)begin
            rx = 0;
            #8680; //start bit
            for(integer j = 0; j < 8; j++) begin
                rx = data_sent[i][j];
                #8680;
            end
            rx = 1;
            #8680; //Stop bit
        end
        $display("Finished sending correct message hope to get MSB message");
        $display("%16h", heading);
        #1000;
        $display("Simulation finished");
        $finish;
    end
endmodule

`default_nettype wire