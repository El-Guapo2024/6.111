//logic [7:0] urx_brx_data;
//logic urx_brx_valid;

//logic [7:0] btx_utx_data;
//logic btx_utx_start;
//logic utx_btx_done;

`default_nettype none
`timescale 1ns/1ps

module LiDAR_Protocol(
    input wire clk_in,
    input wire rst_in,
    input wire [7:0] urx_brx_data,
    input wire urx_brx_valid,
    output logic [7:0] btx_utx_data,
    output logic btx_utx_start ,
    output logic utx_btx_done
    );



endmodule
`default_nettype wire