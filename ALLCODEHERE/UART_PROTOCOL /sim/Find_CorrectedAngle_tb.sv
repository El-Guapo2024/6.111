`timescale 1ns / 1ps
`default_nettype none


module Find_CorrectedAngles_tb();
  logic clk_in;
  logic rst_in;

  logic [15:0] FirstSampleAngle ;
  logic [15:0 ] IntervalSampleAngle;
  logic [15:0] package_Sample_Index ;
  logic [15:0] CurrentDistance ; 
  logic Find_CorrectAngle ;
  logic [15:0] angle_out ;
  logic [15:0] distance_out;
  logic new_data_out ; 




Find_CorrectedAngles  myAngleCorrector(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .FirstSampleAngle(FirstSampleAngle),
    .IntervalSampleAngle(IntervalSampleAngle), 
    .package_Sample_Index(package_Sample_Index),
    .distance(CurrentDistance),
    .data_valid_in(Find_CorrectAngle),
    .angle_out(angle_out),
    .distance_out(distance_out), 
    .data_valid_out(new_data_out)
    );


  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;
  end
  //initial block...this is our test simulation
  initial begin
    $dumpfile("Find_CorrectedAngles_tb.vcd"); //file to store value change dump (vcd)
    $dumpvars(0,Find_CorrectedAngles_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0;
    #10;
    rst_in <= 1 ;  
    #10;
    rst_in <= 0 ; 
    #10 ;
    FirstSampleAngle <=    16'b0001101010101010 ;
    package_Sample_Index <=  16'b0000000000000011 ;
    IntervalSampleAngle <= 16'b0000000100100010 ;
    CurrentDistance <=     16'b0000001011011001 ;
    Find_CorrectAngle <= 1'b1 ;
    #10 
    Find_CorrectAngle <= 1'b0 ;
    #10 
    $display("trig data clk");
    for(int i=0; i<100; i=i+1)begin
      #10;
    end
    $display("Finishing Sim"); //print nice message at end
    $finish;
  end
endmodule
`default_nettype wire