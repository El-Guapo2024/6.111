`timescale 1ns / 1ps
`default_nettype none

module center_of_mass (
                         input wire clk_in,
                         input wire rst_in,
                         input wire [10:0] x_in,
                         input wire [9:0]  y_in,
                         input wire valid_in,
                         input wire tabulate_in,
                         output logic [10:0] x_out,
                         output logic [9:0] y_out,
                         output logic valid_out);

  //your design here!

localparam total_pixels = 1024*768 ; 
logic [31:0] sum_of_y_pixels ; 
logic [31:0] sum_of_x_pixels ; 
logic [31:0] tally_of_pixels ; 
logic [31:0] remainder_x;
logic [31:0] remainder_y;
logic [31:0] quotient_x ;
logic [31:0] quotient_y;

logic valid_division; 
logic valid_out_x ; 
logic valid_out_y ; 
logic error_x ;
logic error_y ; 
logic busy_x ; 
logic busy_y ;
logic finish_x ;
logic finish_y ; 




divider mydividerx ( .clk_in(clk_in),
                  .rst_in(rst_in),
                  .dividend_in(sum_of_x_pixels),
                  .divisor_in(tally_of_pixels),
                  .data_valid_in(valid_division),
                  .quotient_out(quotient_x),
                  .remainder_out(remainder_x),
                  .data_valid_out(valid_out_x),
                  .error_out(error_x),
                  .busy_out(busy_x));

divider mydividery ( .clk_in(clk_in),
                  .rst_in(rst_in),
                  .dividend_in(sum_of_y_pixels),
                  .divisor_in(tally_of_pixels),
                  .data_valid_in(valid_division),
                  .quotient_out(quotient_y),
                  .remainder_out(remainder_y),
                  .data_valid_out(valid_out_y),
                  .error_out(error_y),
                  .busy_out(busy_y));
 

  typedef enum {SUMMING=0, VALID_NUMBERS=1, START_DIVISION=2, WAIT_DIVISION=3, OUTPUT_DIVISION=4, RESET = 5} processing_state ;
  processing_state state; //state of system!
always_ff @(posedge clk_in) begin 
  if(rst_in) begin
    x_out <= 0 ;
    y_out <= 0 ;
    sum_of_x_pixels <= 0 ;
    sum_of_y_pixels <= 0 ;
    tally_of_pixels <= 0 ; 
    valid_division <= 0 ;
    valid_out <= 0 ;
  end else begin
    case(state) 
    SUMMING:
    begin
      if(valid_in) begin 
        sum_of_x_pixels <= sum_of_x_pixels + x_in ; 
        sum_of_y_pixels <= sum_of_y_pixels + y_in ;
        tally_of_pixels <= tally_of_pixels +   1  ;
      end 
      state <= tabulate_in ? VALID_NUMBERS : SUMMING ;
    end
    VALID_NUMBERS:
    begin
      if(tally_of_pixels == 0 ) begin 
        state <= RESET ; 
      end else begin 
        state <= START_DIVISION ;
      end 
    end
    START_DIVISION:
    begin
      valid_division <= 1 ; 
      state <= (busy_y == 1 || busy_x == 1 ) ? WAIT_DIVISION : START_DIVISION ; 
    end
    WAIT_DIVISION:
    begin
      valid_division <= 0 ; 
      x_out <= valid_out_x ? quotient_x[10:0]: x_out ;
      y_out <= valid_out_y ? quotient_y[9:0]: y_out ;
      state <= (busy_y == 0 && busy_x == 0 ) ? OUTPUT_DIVISION : WAIT_DIVISION ; 
    end
    OUTPUT_DIVISION:
    begin
      x_out <= valid_out_x ? quotient_x[10:0]: x_out ;
      y_out <= valid_out_y ? quotient_y[9:0]: y_out ;
      state <= RESET ; 
      valid_out <= 1 ;
    end
    RESET:
    begin
      state <= SUMMING; 
      sum_of_x_pixels <= 0 ;
      sum_of_y_pixels <= 0 ;
      tally_of_pixels <= 0 ; 
      valid_out <= 0 ; 
    end 
    endcase
  end
end


endmodule


`default_nettype wire
