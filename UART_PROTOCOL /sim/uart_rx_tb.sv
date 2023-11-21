`timescale 1ns / 1ps
`default_nettype none


module uart_rx_tb();

  logic clk_in;
  logic rst_in;
  logic tx;

  logic [7:0] data_to_lidar;
  logic send_data_lidar;
  logic is_data_sent_lidar;

uart_tx #(.CLOCKS_PER_BAUD(868)) myTXLiDAR (
    .clk(clk_in),
    .data_i(data_to_lidar),
    .start_i(send_data_lidar),
    .done_o(is_data_sent_lidar),
    .tx(tx));
 
logic [7:0] data_from_lidar;
logic data_received_lidar;

uart_rx #(.CLOCKS_PER_BAUD(868)) myRXLiDAR (
    .clk(clk_in),
    .rx(tx),
    .data_o(data_from_lidar),
    .valid_o(data_received_lidar));
 
  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;
  end
  //initial block...this is our test simulation
  initial begin
    $dumpfile("uart_rx_tb.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,uart_rx_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0;
    data_to_lidar = 8'hEA; //16 long message, 2-wide bit duration
    #10;
    send_data_lidar = 1'b1 ; 
    #10;
    send_data_lidar = 1'b0;
    $display("trig data clk");
    for(int i=0; i<300; i=i+1)begin
      #400;
    end
    data_to_lidar = 8'hA0;
    #10;
    send_data_lidar = 1'b1;
    #10
    send_data_lidar = 1'b0;
    $display("trig data clk");
    for(int i=0; i<300; i=i+1)begin

      #300;
    end
    $display("Finishing Sim"); //print nice message at end
    $finish;
  end
endmodule
`default_nettype wire