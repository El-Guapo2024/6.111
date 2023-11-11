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

    
    always_ff @(posedge clk_in) begin 
        
    end

endmodule
`default_nettype wire // prevents system from inferring an undeclared logic (good practice)
