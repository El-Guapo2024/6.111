`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module top_level(
  input wire clk_100mhz,
  input wire [15:0] sw, //all 16 input slide switches
  input wire [3:0] btn, //all four momentary button switches
  output logic [15:0] led, //16 green output LEDs (located right above switches)
  //output logic [2:0] rgb0, //rgb led
  //output logic [2:0] rgb1, //rgb led
  //output logic spkl, spkr, //speaker outputs
 // output logic mic_clk, //microphone clock
  //input wire  mic_data //microphone data
  output logic [7:0] pmoda,
  output logic [3:0] s
  
  );

    logic rst_sys;
    assign rst_sys = btn[1];
    logic [7:0] dir1;
    logic [7:0] dir2;

    

    speed_control my_sc (
        .clk_in(clk_100mhz),
        .rst_in(rst_sys),
        .level_in_1(sw[7:0]),
        .level_in_2(~sw[15:8]),
        .direction_1(btn[2]),
        .direction_2(btn[3]),
        .pwm_out(s[3:0])
    );

    

endmodule // top_level
`default_nettype wire