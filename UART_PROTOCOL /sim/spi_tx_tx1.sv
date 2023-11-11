`timescale 1ns / 1ps
`default_nettype none

module spi_tx_tb();
  logic clk_in;
  logic rst_in;
  logic [15:0] data_in;
  logic trigger_in;

  logic data_out, data_clk_out,sel_out;

  spi_tx #(.DATA_WIDTH(8),.DATA_PERIOD(12)) uut
                  ( .clk_in(clk_in), .rst_in(rst_in),
                    .data_in(data_in),
                    .trigger_in(trigger_in),
                    .data_out(data_out),
                    .sel_out(sel_out),
                    .data_clk_out(data_clk_out));

  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;
  end
  //initial block...this is our test simulation
  initial begin
    $dumpfile("spi.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,spi_tx_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0;
    rst_in = 0;
    trigger_in = 0;

    data_in = 'b01011100; //16 long message, 2-wide bit duration
    #10;
    rst_in = 1;
    #10;
    rst_in = 0;
    #50;
    trigger_in = 1;
    #10;
    trigger_in = 0;
    $display("data_in = %16b ",data_in);
    $display("trig data clk");
    for(int i=0; i<300; i=i+1)begin
      $display("%b     %b    %b",trigger_in, data_out, data_clk_out);
      #10;
    end
    $display("Finishing Sim"); //print nice message at end
    $finish;
  end
endmodule
`default_nettype wire