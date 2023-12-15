`timescale 1ns / 1ps
`default_nettype none

module current_counter_tb();

  logic clk_in;
  logic rst_in;
  logic signal_in;
  logic [31:0] tally_out;

  current_counter uut
  (.clk_in(clk_in),
   .rst_in(rst_in),
   .signal_in(signal_in),
   .tally_out(tally_out)
  );

  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;
  end
  //initial block...this is our test simulation
  initial begin
    $dumpfile("current_tb.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,current_counter_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0;
    rst_in = 0;
    signal_in = 0;
    #6;
    rst_in = 1;
    #10;
    rst_in = 0;
    $display("Starting");
    #100;
    signal_in = 1;
    #200;
    signal_in = 0;
    #10;
    signal_in = 1;
    #10;
    signal_in = 0;
    #10;
    signal_in = 1;
    #1000;
    $display("Finishing");
    $finish;
  end
endmodule
`default_nettype wire