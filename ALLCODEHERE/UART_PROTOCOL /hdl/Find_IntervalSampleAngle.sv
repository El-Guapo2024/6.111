`timescale 1ns / 1ps
`default_nettype none

module Find_IntervalSampleAngle (
    input wire clk_in,
    input wire rst_in,
    input wire[15:0] FirstSampleAngle,
    input wire[15:0] LastSampleAngle,
    input wire [15:0] package_Sample_Num ,
    input wire data_valid_in,
    output logic[15:0] IntervalSampleAngle,
    output logic data_valid_out,
    output logic busy_out,
    output logic error_out
    );

// Variables for divisor 
logic [15:0] dividend ;
logic [15:0] divisor ;
logic valid_division ; 
logic [15:0] quotient ;
logic [15:0] remainder ; 
logic division_done ;

divider #(.WIDTH(16)) mydividerx (
  .clk_in(clk_in),
  .rst_in(rst_in),
  .dividend_in(dividend),
  .divisor_in(divisor),
  .data_valid_in(valid_division),
  .quotient_out(quotient),
  .remainder_out(remainder),
  .data_valid_out(division_done),
  .error_out(error_out),
  .busy_out(busy_out));

always_comb begin 
  if( LastSampleAngle < FirstSampleAngle)begin 
    dividend = (23040+LastSampleAngle-FirstSampleAngle) ;
  end else begin 
    dividend = LastSampleAngle-FirstSampleAngle ;
  end 
  if(package_Sample_Num <= 1) begin
    divisor = 1 ;
  end else begin 
    divisor = package_Sample_Num -1 ;
  end 
end 

typedef enum {IDLE,CALCULATE,WAIT,OUTPUT} processing_state ;
processing_state state; //state of system!

  always_ff @(posedge clk_in)begin
    if (rst_in)begin
      IntervalSampleAngle <= 0 ;
      valid_division <= 0 ; 
    end else begin
    case(state)
    IDLE:
    begin
      valid_division <= 0 ;
      data_valid_out <= 0 ;
      state<= data_valid_in ? CALCULATE:IDLE ;
    end 
    CALCULATE:
    begin 
      if(package_Sample_Num == 1 )begin 
        IntervalSampleAngle <= 0  ; 
        state <= OUTPUT ; 
      end else if(LastSampleAngle < FirstSampleAngle) begin 
        if((FirstSampleAngle>17280) && (LastSampleAngle < 5706)) begin 
          valid_division <= 1 ;
          state <= WAIT ;
        end else begin 
          IntervalSampleAngle <= IntervalSampleAngle ;
          state <= OUTPUT ;
        end 
      end else begin 
        valid_division <= 1 ;
        state <= WAIT ;
      end 
    end 
    WAIT:
    begin 
    if(division_done)begin 
      valid_division <= 0 ; 
      IntervalSampleAngle <= quotient ;
      state <= OUTPUT;
    end else if(error_out) begin 
      state <= IDLE;
    end 
    end 
    OUTPUT:
    begin
        data_valid_out <= 1'b1 ; 
        state <= IDLE ;
    end 
    endcase
    end
  end
  
endmodule

`default_nettype wire
