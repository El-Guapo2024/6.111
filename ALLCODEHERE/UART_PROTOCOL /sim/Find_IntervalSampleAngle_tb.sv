`timescale 1ns / 1ps
`default_nettype none


module Find_IntervalSampleAngle_tb();
  logic clk_in;
  logic rst_in;

  logic [15:0] FirstSampleAngle ;
  logic [15:0] LastSampleAngle ; 
  logic [15:0 ] IntervalSampleAngle;
  logic [15:0] package_Sample_Num ;
  logic Find_CorrectAngle ;
  logic Find_IntervalAngle ;
  logic Found_IntervalAngle ;
  logic busy_out; 
  logic error_out ;
// Find_Interval Angle Module 
Find_IntervalSampleAngle myIntervalAngle (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .FirstSampleAngle(FirstSampleAngle),
    .LastSampleAngle(LastSampleAngle),
    .package_Sample_Num(package_Sample_Num),
    .data_valid_in(Find_IntervalAngle),
    .IntervalSampleAngle(IntervalSampleAngle),
    .data_valid_out(Found_IntervalAngle),
    .busy_out(busy_out),
    .error_out(error_out)
    );

  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;
  end
  //initial block...this is our test simulation
  initial begin
    $dumpfile("Find_IntervalSampleAngle_tb.vcd"); //file to store value change dump (vcd)
    $dumpvars(0, Find_IntervalSampleAngle_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0 ;
    #10;
    rst_in <= 1 ;
    #10;
    rst_in <= 0 ; 
    #10 
    FirstSampleAngle <= 16'b0001101010101010 ;
    LastSampleAngle <=  16'b0010101010001010 ;
    package_Sample_Num <= 16'b0000000000011111 ;
    Find_IntervalAngle <= 1 ; 
    #10 
    Find_IntervalAngle <= 0 ; 
    $display("trig data clk");
    for(int i=0; i<1000; i=i+1)begin
      #10;
    end
    $display("Finishing Sim"); //print nice message at end
    $finish;
  end
endmodule
`default_nettype wire