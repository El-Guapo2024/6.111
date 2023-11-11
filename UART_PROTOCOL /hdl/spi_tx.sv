`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
module spi_tx
       #(   parameter DATA_WIDTH = 8,
            parameter DATA_PERIOD = 100
        )
        ( input wire clk_in,
          input wire rst_in,
          input wire [DATA_WIDTH-1:0] data_in,
          input wire trigger_in,
          output logic data_out,
          output logic data_clk_out,
          output logic sel_out
        );
   parameter clock_counter_size = $clog2(DATA_PERIOD) ;
   logic [ clock_counter_size : 0 ]	clock_counter;
   parameter bit_counter_size = $clog2(DATA_WIDTH) ;
   logic [ bit_counter_size : 0 ]   bit_counter; 
   logic [DATA_WIDTH-1 : 0] data_in_temp ;

  // your code here
  
  
  always_ff @(posedge clk_in)begin
    if (rst_in)begin
      data_clk_out <= 0 ;
      bit_counter <= 0 ;
      clock_counter <=  0 ;
      sel_out <= 1 ;
    end else if(trigger_in) begin 
      sel_out <= 0 ;
      data_clk_out <= 0 ;
      bit_counter <= 0 ;
      clock_counter <=  0 ;
      data_in_temp <= data_in ;
      data_out <= data_in_temp[DATA_WIDTH-1-bit_counter];
    end else if (bit_counter == DATA_WIDTH) begin
      sel_out <= 1 ;
    end else begin
      if(clock_counter == (DATA_PERIOD/2)-1) begin
        if(data_clk_out == 1) begin 
          bit_counter <= bit_counter + 1 ; 
        end 
        clock_counter <= 0;
        data_clk_out <= ~data_clk_out;
      end else begin 
        clock_counter <= clock_counter + 1 ;
      end
      data_out = data_in_temp[DATA_WIDTH-1-bit_counter]; 
    end
  end

endmodule
`default_nettype wire // prevents system from inferring an undeclared logic (good practice)
