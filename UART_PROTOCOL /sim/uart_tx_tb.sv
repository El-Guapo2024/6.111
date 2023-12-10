`timescale 1ns / 1ps
`default_nettype none


module uart_tx_tb();
 // Uart TX at 115200 8n1
logic clk_in;
logic [7:0] data_in;
logic btx_utx_start;
logic utx_btx_done;
logic tx ;
uart_tx #(.CLOCKS_PER_BAUD(868)) myTXLiDAR (
    .clk(clk_in),
    .data_i(data_in),
    .start_i(btx_utx_start),
    .done_o(utx_btx_done),
    .tx(tx));


  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;
  end
  //initial block...this is our test simulation
  initial begin
    $dumpfile("uart_tx_tb.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,uart_tx_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0;  
    data_in = 8'hFF; //16 long message, 2-wide bit duration
    #10;
    btx_utx_start = 1'b1;
    #10;
    btx_utx_start = 1'b0;
    $display("data_in = %8b ",data_in);
    $display("trig data clk");
    for(int i=0; i<300; i=i+1)begin
      $display("%b   %b    %b %b ",tx, data_in, btx_utx_start,utx_btx_done);
      #400;
    end
    data_in = 8'b10000001;
    #10;
    btx_utx_start = 1'b1;
    #10;
    btx_utx_start = 1'b0;
    $display("trig data clk");
    for(int i=0; i<300; i=i+1)begin
      $display("%b   %b    %b %b ",tx, data_in, btx_utx_start,utx_btx_done);
      #400;
    end
    $display("Finishing Sim"); //print nice message at end
    $finish;
  end
endmodule
`default_nettype wire