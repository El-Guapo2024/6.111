// set the timestep on the internal simulation clock
`timescale 1ns / 1ps
`default_nettype none
 
//The timescale specifies the timestep size (1ns) and time resolution of rounding (1ps)
//we'll usually use 1ns/1ps in our class
 
module pwm_tb();
 
  //make inputs and outputs of appropriate size for the module testing:
  logic clk_in;
  logic rst_in;
  logic [7:0] level_in;
  logic pwm_out;
 
  //create an instance of the module. UUT= unit under test, but call it whatever:
  //always use named port convention when declaring (it is much easier to protect from bugs)
  pwm uut(.clk_in(clk_in), .rst_in(rst_in), .level_in(level_in), .pwm_out(pwm_out));

  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;
  end


  //All simulations start with the the "initial block's top
  // They then run forward in order like regular code.
  //lines that are one after the other happen "instaneously together"
  //Time passes using the # notation. (#10 is 10 nanoseconds)
  // set the initial values of the module inputs
  initial begin
    $dumpfile("pwm_tb.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,pwm_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0;
    rst_in = 0;
    level_in = 0;
    #6;
    rst_in = 1;
    #10;
    rst_in = 0;
    $display("Starting");
    #20;
    level_in = 0;
    #10000;
    level_in = 10;
    #10000;
    level_in = 25;
    #10000;
    level_in = 50;
    #10000;
    level_in = 88;
    #10000;
    level_in = 95;
    #10000;
    level_in = 100;
    #10000;
    $display("Finishing");
    $finish;
  end
endmodule // pwm_tb
`default_nettype wire