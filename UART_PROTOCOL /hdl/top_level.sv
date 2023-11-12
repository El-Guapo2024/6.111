`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module top_level(
  input wire clk_100mhz, //
  input wire [15:0] sw, //all 16 input slide switches
  input wire [3:0] btn, //all four momentary button switches
  output logic [15:0] led, //16 green output LEDs (located right above switches)
  output logic [3:0] ss0_an,//anode control for upper four digits of seven-seg display
  output logic [3:0] ss1_an,//anode control for lower four digits of seven-seg display
  output logic [6:0] ss0_c, //cathode controls for the segments of upper four digits
  output logic [6:0] ss1_c, //cathod controls for the segments of lower four digits
  output logic [2:0] rgb0, //rgb led
  output logic [2:0] rgb1, //rgb led
  output logic [7:0] pmoda, //output I/O used for UART Lidar 
  input wire [7:0] pmodb //input I/O used for UART IMU 
  );
 
logic sys_rst;
assign sys_rst = btn[0];

// This is the UART for the LiDAR
// pmoda[0] will be TX pmodb[0] will be RX
logic [7:0] btx_utx_data;
logic btx_utx_start;
logic utx_btx_done;

uart_tx #(.CLOCKS_PER_BAUD(868)) myTXLiDAR (
    .clk(clk_100mhz),
    .data_i(btx_utx_data),
    .start_i(btx_utx_start),
    .done_o(utx_btx_done),
    .tx(pmoda[0]));
 
logic [7:0] urx_brx_data;
logic urx_brx_valid;

uart_rx #(.CLOCKS_PER_BAUD(868)) myRXLiDAR (
    .clk(clk_100mhz),
    .rx(pmodb[0]),
    .data_o(urx_brx_data),
    .valid_o(urx_brx_valid));

/*----------------------------------------------------------------------------------------------*/
// From here below is the code for the uart 
//
/*----------------------------------------------------------------------------------------------*/
// pmoda[1] will be TX pmodb[1] will be RX

logic [7:0] btx_utx_data;
logic btx_utx_start;
logic utx_btx_done;

uart_tx #(.CLOCKS_PER_BAUD(868)) myTXIMU (
    .clk(clk_100mhz),
    .data_i(btx_utx_data),
    .start_i(btx_utx_start),
    .done_o(utx_btx_done),
    .tx(pmoda[1]));

logic [7:0] urx_brx_data;
logic urx_brx_valid;

uart_rx #(.CLOCKS_PER_BAUD(868)) myRXIMU (
    .clk(clk_100mhz),
    .rx(pmodb[1]),
    .data_o(urx_brx_data),
    .valid_o(urx_brx_valid));

endmodule // top_level
`default_nettype wire