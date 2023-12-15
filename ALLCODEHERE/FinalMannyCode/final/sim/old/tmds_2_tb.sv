`timescale 1ns / 1ps
`default_nettype none


module tmds_2_tb();

  logic clk_in;
  logic rst_in;
	logic [7:0] data_in;
	logic [1:0] control_in;
	logic ve_in;
	logic [9:0] tmds_out;
  tmds_encoder uut(
  .clk_in(clk_in),
  .rst_in(rst_in),
  .data_in(data_in),  // video data (red, green or blue)
  .control_in(control_in),  // control data
  .ve_in(ve_in),  // video data enable, to choose between CD (when VDE=0) and VD (when VDE=1)
  .tmds_out(tmds_out)
  );

  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;
  end
  //initial block...this is our test simulation
  initial begin
    $dumpfile("tmds_2_tb.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,tmds_2_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0;
    rst_in = 1;
    control_in = 0;
    ve_in = 1;
    data_in = 0;;
    #10;
    rst_in=0;
    for(int i = 0; i<1024; i = i+1)begin
      data_in = i;
      #10;
    end
    control_in = 0;
    #100;
    control_in = 1;
    #100;
    control_in = 2;
    #100;
    control_in = 3;
    #100;
    ve_in = 0;
    control_in = 0;
    #100;
    control_in = 1;
    #100;
    control_in = 2;
    #100;
    control_in = 3;
    #100;
    ve_in = 1;
    #10;
    for(int i = 0; i<1024; i = i+1)begin
      data_in = 255-i;
      #10;
    end
    #500;
    $display("Finishing Sim"); //print nice message at end
    $finish;
  end
endmodule
`default_nettype wire