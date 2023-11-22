`timescale 1ns / 1ps
`default_nettype none

module scale(
  input wire [1:0] scale_in,
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  output logic [10:0] scaled_hcount_out,
  output logic [9:0] scaled_vcount_out,
  output logic valid_addr_out
);
  //always just default to scale 1
  //(you need to update/modify this to spec)!
  assign valid_addr_out = hcount_in <240 && vcount_in <320;
  assign scaled_hcount_out = hcount_in;
  assign scaled_vcount_out = vcount_in;
endmodule


`default_nettype wire

