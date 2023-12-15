`timescale 1ns / 1ps
`default_nettype none

`ifdef SYNTHESIS
`define FPATH(X) `"X`"
`else /* ! SYNTHESIS */
`define FPATH(X) `"data/X`"
`endif  /* ! SYNTHESIS */

module write_word  (
  input wire pixel_clk_in,
  input wire rst_in,
  input wire [10:0]  hcount_in, x_in,
  input wire [9:0]   vcount_in, y_in,
  input wire [5:0] word_in [9:0],
  output logic [7:0] red_out,
  output logic [7:0] green_out,
  output logic [7:0] blue_out
  );


  logic [7:0]red_out1 ; 
  logic [7:0]green_out1 ;
  logic [7:0]blue_out1; 
 //use this in the first part of checkoff 01:
  //instance of image sprite.
  draw_letter #(
    .WIDTH(119),
    .HEIGHT(82))
    letter1 (
    .pixel_clk_in(pixel_clk_in),
    .rst_in(rst_in),
    .hcount_in(hcount_in),   //TODO: needs to use pipelined signal (PS1)
    .vcount_in(vcount_in),   //TODO: needs to use pipelined signal (PS1)
    .x_in(x_in),
    .y_in(y_in),
    .select_letter(word_in[0]),
    .red_out(red_out1),
    .green_out(green_out1),
    .blue_out(blue_out1));


  logic [7:0]red_out2 ; 
  logic [7:0]green_out2 ;
  logic [7:0]blue_out2; 
  logic [10:0] x_in2 = x_in + 20 ; 
 //use this in the first part of checkoff 01:
  //instance of image sprite.
  draw_letter #(
    .WIDTH(119),
    .HEIGHT(82))
    letter2 (
    .pixel_clk_in(pixel_clk_in),
    .rst_in(rst_in),
    .hcount_in(hcount_in),   //TODO: needs to use pipelined signal (PS1)
    .vcount_in(vcount_in),   //TODO: needs to use pipelined signal (PS1)
    .x_in(x_in2),
    .y_in(y_in),
    .select_letter(word_in[1]),
    .red_out(red_out2),
    .green_out(green_out2),
    .blue_out(blue_out2));


  logic [7:0]red_out3 ; 
  logic [7:0]green_out3 ;
  logic [7:0]blue_out3; 
  logic [10:0] x_in3 = x_in + 40 ;
 //use this in the first part of checkoff 01:
  //instance of image sprite.
  draw_letter #(
    .WIDTH(119),
    .HEIGHT(82))
    letter3 (
    .pixel_clk_in(pixel_clk_in),
    .rst_in(rst_in),
    .hcount_in(hcount_in),   //TODO: needs to use pipelined signal (PS1)
    .vcount_in(vcount_in),   //TODO: needs to use pipelined signal (PS1)
    .x_in(x_in3),
    .y_in(y_in),
    .select_letter(word_in[2]),
    .red_out(red_out3),
    .green_out(green_out3),
    .blue_out(blue_out3));


  logic [7:0]red_out4 ; 
  logic [7:0]green_out4 ;
  logic [7:0]blue_out4; 
  logic [10:0] x_in4 = x_in+60;
 //use this in the first part of checkoff 01:
  //instance of image sprite.
  draw_letter #(
    .WIDTH(119),
    .HEIGHT(82))
    letter4 (
    .pixel_clk_in(pixel_clk_in),
    .rst_in(rst_in),
    .hcount_in(hcount_in),   //TODO: needs to use pipelined signal (PS1)
    .vcount_in(vcount_in),   //TODO: needs to use pipelined signal (PS1)
    .x_in(x_in4),
    .y_in(y_in),
    .select_letter(word_in[3]),
    .red_out(red_out4),
    .green_out(green_out4),
    .blue_out(blue_out4));

  logic [7:0]red_out5 ; 
  logic [7:0]green_out5 ;
  logic [7:0]blue_out5; 
  logic [10:0]x_in5 = x_in+80;
 //use this in the first part of checkoff 01:
  //instance of image sprite.
  draw_letter #(
    .WIDTH(119),
    .HEIGHT(82))
    letter5 (
    .pixel_clk_in(pixel_clk_in),
    .rst_in(rst_in),
    .hcount_in(hcount_in),   //TODO: needs to use pipelined signal (PS1)
    .vcount_in(vcount_in),   //TODO: needs to use pipelined signal (PS1)
    .x_in(x_in5),
    .y_in(y_in),
    .select_letter(word_in[4]),
    .red_out(red_out5),
    .green_out(green_out5),
    .blue_out(blue_out5));


  logic [7:0]red_out6 ; 
  logic [7:0]green_out6 ;
  logic [7:0]blue_out6; 
  logic [10:0] x_in6 = x_in + 100;
 //use this in the first part of checkoff 01:
  //instance of image sprite.
  draw_letter #(
    .WIDTH(119),
    .HEIGHT(82))
    letter6 (
    .pixel_clk_in(pixel_clk_in),
    .rst_in(rst_in),
    .hcount_in(hcount_in),   //TODO: needs to use pipelined signal (PS1)
    .vcount_in(vcount_in),   //TODO: needs to use pipelined signal (PS1)
    .x_in(x_in6),
    .y_in(y_in),
    .select_letter(word_in[5]),
    .red_out(red_out6),
    .green_out(green_out6),
    .blue_out(blue_out6));


  logic [7:0]red_out7 ; 
  logic [7:0]green_out7 ;
  logic [7:0]blue_out7; 
  logic [10:0] x_in7 = x_in+120;
 //use this in the first part of checkoff 01:
  //instance of image sprite.
  draw_letter #(
    .WIDTH(119),
    .HEIGHT(82))
    letter7 (
    .pixel_clk_in(pixel_clk_in),
    .rst_in(rst_in),
    .hcount_in(hcount_in),   //TODO: needs to use pipelined signal (PS1)
    .vcount_in(vcount_in),   //TODO: needs to use pipelined signal (PS1)
    .x_in(x_in7),
    .y_in(y_in),
    .select_letter(word_in[6]),
    .red_out(red_out7),
    .green_out(green_out7),
    .blue_out(blue_out7));


  logic [7:0]red_out8 ; 
  logic [7:0]green_out8 ;
  logic [7:0]blue_out8; 
  logic [10:0] x_in8 = x_in+140;
 //use this in the first part of checkoff 01:
  //instance of image sprite.
  draw_letter #(
    .WIDTH(119),
    .HEIGHT(82))
    letter8 (
    .pixel_clk_in(pixel_clk_in),
    .rst_in(rst_in),
    .hcount_in(hcount_in),   //TODO: needs to use pipelined signal (PS1)
    .vcount_in(vcount_in),   //TODO: needs to use pipelined signal (PS1)
    .x_in(x_in8),
    .y_in(y_in),
    .select_letter(word_in[7]),
    .red_out(red_out8),
    .green_out(green_out8),
    .blue_out(blue_out8));

  logic [7:0]red_out9 ; 
  logic [7:0]green_out9 ;
  logic [7:0]blue_out9; 
  logic [10:0] x_in9 = x_in + 160 ;
 //use this in the first part of checkoff 01:
  //instance of image sprite.
  draw_letter #(
    .WIDTH(119),
    .HEIGHT(82))
    letter9 (
    .pixel_clk_in(pixel_clk_in),
    .rst_in(rst_in),
    .hcount_in(hcount_in),   //TODO: needs to use pipelined signal (PS1)
    .vcount_in(vcount_in),   //TODO: needs to use pipelined signal (PS1)
    .x_in(x_in9),
    .y_in(y_in),
    .select_letter(word_in[8]),
    .red_out(red_out9),
    .green_out(green_out9),
    .blue_out(blue_out9));


  logic [7:0]red_out10 ; 
  logic [7:0]green_out10 ;
  logic [7:0]blue_out10; 
  logic [10:0] x_in10 = x_in + 180 ;
 //use this in the first part of checkoff 01:
  //instance of image sprite.
  draw_letter #(
    .WIDTH(119),
    .HEIGHT(82))
    letter10 (
    .pixel_clk_in(pixel_clk_in),
    .rst_in(rst_in),
    .hcount_in(hcount_in),   //TODO: needs to use pipelined signal (PS1)
    .vcount_in(vcount_in),   //TODO: needs to use pipelined signal (PS1)
    .x_in(x_in10),
    .y_in(y_in),
    .select_letter(word_in[9]),
    .red_out(red_out10),
    .green_out(green_out10),
    .blue_out(blue_out10));

always_comb begin 
    red_out = red_out1 +red_out2 +red_out2 +red_out3+red_out4 +red_out5 +red_out6 +red_out7 +red_out8 +red_out9 +red_out10;
    blue_out = blue_out1 + blue_out2 +blue_out3 + blue_out4 + blue_out5 + blue_out6 + blue_out7 + blue_out8 +blue_out9 + blue_out10 ;
    green_out = green_out1 + green_out2+ green_out3 + green_out4 + green_out5 + green_out6 + green_out7 + green_out8 + green_out9 + green_out10 ; 
end 


endmodule






`default_nettype none
