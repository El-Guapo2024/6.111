`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
module spi_rx
       #(  parameter DATA_WIDTH = 8
        )
        ( input wire clk_in,
          input wire rst_in,
          input wire data_in,
          input wire data_clk_in,
          input wire sel_in,
          output logic [DATA_WIDTH-1:0] data_out,
          output logic new_data_out
        );
    logic [$clog2(DATA_WIDTH) : 0 ]	bit_counter1 ;
    logic on ;
    logic clock_on;
    logic finish ;
    
    always_ff @(posedge clk_in) begin 
        
        if (rst_in == 1) begin
            finish <= 0 ;
            bit_counter1 <= 0 ;
            clock_on <= 0 ;
        // If is enabled 
        end else if(new_data_out == 1) begin
            new_data_out <= 0 ; 
        end else if( sel_in == 0 && finish == 1 ) begin
            if ( on == 1) begin 
                finish <= 0 ; 
                bit_counter1 <= 0 ;
            end
            on <= 0 ;
        end else if( sel_in == 1 && finish == 1) begin 
            on <= 1 ;
        end else if(sel_in == 0 ) begin 
            on <= 0 ;     
            if ( bit_counter1 >= DATA_WIDTH ) begin 
                new_data_out <= 1 ;
                finish <= 1 ;
            end else begin
                finish <= 0 ;
            end
            clock_on <= data_clk_in ;
            if(clock_on == 0 && data_clk_in == 1) begin 
                data_out[DATA_WIDTH-1-bit_counter1] <= data_in ;
                bit_counter1 <=  bit_counter1 + 1 ;
            end


        end else if (sel_in == 1 ) begin 
            on <= 1 ;
        end 
    end

endmodule
`default_nettype wire // prevents system from inferring an undeclared logic (good practice)
