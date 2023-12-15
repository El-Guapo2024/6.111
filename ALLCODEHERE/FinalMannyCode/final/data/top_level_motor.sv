`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module top_level(
  input wire clk_100mhz,
  input wire [15:0] sw, //all 16 input slide switches
  input wire [3:0] btn, //all four momentary button switches
  output logic [15:0] led, //16 green output LEDs (located right above switches)
  output logic [2:0] rgb0, //rgb led
  output logic [2:0] rgb1, //rgb led
  output logic [3:0] ss0_an,//anode control for upper four digits of seven-seg display
  output logic [3:0] ss1_an,//anode control for lower four digits of seven-seg display
  output logic [6:0] ss0_c, //cathode controls for the segments of upper four digits
  output logic [6:0] ss1_c, //cathod controls for the segments of lower four digits
  input wire GPIO0,
  input logic GPIO4
  output logic [3:0] s
  );
  assign led = sw; //for debugging
  //shut up those rgb LEDs (active high):
  assign rgb1= 0;
  assign rgb0 = 0;

  logic sys_rst;
  assign sys_rst = btn[0];

  reg [7:0] debug_data;
  wire encoderL, encoderR, pwmL, pwmR;

  assign encoderL = GPIO0;
  assign encoderR = GPIO4;

  // assign pmodb pins for motor inputs and controls
  motor_controller motor(
    .clk(clk_100mhz),
    .rst(sys_rst),
    .encoderL(encoderL),
    .encoderR(encoderR),
    .dirL(sw[0]),
    .dirR(sw[1]),
    .pwmL1(s[0]),
    .pwmL2(s[1]),
    .pwmR1(s[2]),
    .pwmR2(s[3]),
    .debug_data(debug_data)
  );

  // Now assign heading to 7 segment LED
  //7-segment display-related concepts:
  logic [31:0] val_to_display; //either the spi data or the btn_count data (default)
  logic [6:0] ss_c; //used to grab output cathode signal for 7s leds

  assign val_to_display = {debug_data, encoderL, encoderR, pwm_left, pwm_right, 4'hA};
 
  seven_segment_controller mssc(.clk_in(clk_100mhz),
                                .rst_in(sys_rst),
                                .val_in(val_to_display),
                                .cat_out(ss_c),
                                .an_out({ss0_an, ss1_an}));
  assign ss0_c = ss_c; //control upper four digit's cathodes!
  assign ss1_c = ss_c; //same as above but for lower four digits!

endmodule // top_level

`default_nettype wire