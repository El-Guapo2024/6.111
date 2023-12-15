// IMU SV

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
  input wire GPIO1,
  output logic GPIO4
  //input wire [7:0] pmodb //input I/O used for IR input (part 1)
  );
  //assign led = sw; //for debugging
  //shut up those rgb LEDs (active high):
  assign rgb1= 0;
  assign rgb0 = 0;

  logic sys_rst;
  assign sys_rst = btn[0];

  reg [4:0] state_debug;

  // Assign pmodb uart pins
  //logic rx_signal, tx_signal;
  //assign rx_signal = pmodb[3];
  //assign pmodb[4] = tx_signal;

  logic[15:0] heading, debug;

  uart_imu_new uut( 
    .clk(clk_100mhz),
    .rst(sys_rst),
    .rx(GPIO1),
    .tx(GPIO4),
    .heading(heading),
    .debug(debug),
    .state_debug(state_debug)
  );

  assign led[15:0] = state_debug;

  // Now assign heading to 7 segment LED
  //7-segment display-related concepts:
  logic [31:0] val_to_display; //either the spi data or the btn_count data (default)
  logic [6:0] ss_c; //used to grab output cathode signal for 7s leds
 
  seven_segment_controller mssc(.clk_in(clk_100mhz),
                                .rst_in(sys_rst),
                                .val_in(val_to_display),
                                .cat_out(ss_c),
                                .an_out({ss0_an, ss1_an}));
  assign ss0_c = ss_c; //control upper four digit's cathodes!
  assign ss1_c = ss_c; //same as above but for lower four digits!

  assign val_to_display = {16'hFF, heading};

  //uart_module variables

endmodule // top_level

`default_nettype wire

// ---------------------------------------------

// // Motor controller sv

// `timescale 1ns / 1ps
// `default_nettype none // prevents system from inferring an undeclared logic (good practice)

// module top_level(
//   input wire clk_100mhz,
//   input wire [15:0] sw, //all 16 input slide switches
//   input wire [3:0] btn, //all four momentary button switches
//   input wire GPIO0,
//   input wire GPIO4,
//   output logic [15:0] led, //16 green output LEDs (located right above switches)
//   output logic [2:0] rgb0, //rgb led
//   output logic [2:0] rgb1, //rgb led
//   output logic [3:0] ss0_an,//anode control for upper four digits of seven-seg display
//   output logic [3:0] ss1_an,//anode control for lower four digits of seven-seg display
//   output logic [6:0] ss0_c, //cathode controls for the segments of upper four digits
//   output logic [6:0] ss1_c, //cathod controls for the segments of lower four digits
//   output logic [3:0] s
//   );
//   assign led = sw; //for debugging
//   //shut up those rgb LEDs (active high):
//   assign rgb1= 0;
//   assign rgb0 = 0;

//   logic sys_rst;
//   assign sys_rst = btn[0];

//   reg [7:0] debug_data;
//   wire encoderL, encoderR, distance, imu_heading;

//   assign encoderL = GPIO0;
//   assign encoderR = GPIO4;

//   assign imu_heading = sw[0];
//   assign distance = sw[1];

//   // assign pmodb pins for motor inputs and controls
//   motor_controller motor(
//     .clk(clk_100mhz),
//     .rst(sys_rst),
//     .encoderL(encoderL),
//     .encoderR(encoderR),
//     .imu_heading(imu_heading),
//     .distance(distance),
//     .pwmL1(s[0]),
//     .pwmL2(s[1]),
//     .pwmR1(s[2]),
//     .pwmR2(s[3]),
//     .debug_data(debug_data)
//   );

//   // Now assign heading to 7 segment LED
//   //7-segment display-related concepts:
//   logic [31:0] val_to_display; //either the spi data or the btn_count data (default)
//   logic [6:0] ss_c; //used to grab output cathode signal for 7s leds

//   assign val_to_display = {debug_data, 3'b000, encoderL, 3'b000, encoderR, 12'h000, s[3:0]};
 
//   seven_segment_controller mssc(.clk_in(clk_100mhz),
//                                 .rst_in(sys_rst),
//                                 .val_in(val_to_display),
//                                 .cat_out(ss_c),
//                                 .an_out({ss0_an, ss1_an}));
//   assign ss0_c = ss_c; //control upper four digit's cathodes!
//   assign ss1_c = ss_c; //same as above but for lower four digits!

// endmodule // top_level

// `default_nettype wire

// ARDUINO SV

// `timescale 1ns / 1ps
// `default_nettype none // prevents system from inferring an undeclared logic (good practice)

// module top_level(
//   input wire clk_100mhz,
//   input wire [15:0] sw, //all 16 input slide switches
//   input wire [3:0] btn, //all four momentary button switches
//   //input wire GPIO1,
//   //input wire GPIO2,
//   output wire GPIO3,
//   input wire GPIO4,
//   output logic [15:0] led, //16 green output LEDs (located right above switches)
//   output logic [2:0] rgb0, //rgb led
//   output logic [2:0] rgb1, //rgb led
//   output logic [3:0] ss0_an,//anode control for upper four digits of seven-seg display
//   output logic [3:0] ss1_an,//anode control for lower four digits of seven-seg display
//   output logic [6:0] ss0_c, //cathode controls for the segments of upper four digits
//   output logic [6:0] ss1_c //cathod controls for the segments of lower four digits
//   //input wire [7:0] pmodb //input I/O used for IR input (part 1)
//   );
//   //assign led = sw; //for debugging
//   //shut up those rgb LEDs (active high):
//   assign rgb1= 0;
//   assign rgb0 = 0;

//   logic sys_rst;
//   assign sys_rst = btn[0];

//   // Set up arduino communication
//   logic [15:0] heading, distance;
//   logic [1:0] state_debug;
//   logic [47:0] rx_debug;
//   logic rx_valid;

//   uart_arduino arduino(
//     .clk(clk_100mhz),
//     .rst(sys_rst),
//     .rx(GPIO4),
//     .tx(GPIO3),
//     .heading(heading),
//     .distance(distance),
//     .state_debug(state_debug),
//     .rx_debug(rx_debug),
//     .rx_valid_o(rx_valid)
//   );

//   // Now assign rx_debug to 7 segment LED
//   //7-segment display-related concepts:
//   logic [31:0] val_to_display; //either the spi data or the btn_count data (default)
//   logic [6:0] ss_c; //used to grab output cathode signal for 7s leds
 
//   seven_segment_controller mssc(.clk_in(clk_100mhz),
//                                 .rst_in(sys_rst),
//                                 .val_in(val_to_display),
//                                 .cat_out(ss_c),
//                                 .an_out({ss0_an, ss1_an}));
//   assign ss0_c = ss_c; //control upper four digit's cathodes!
//   assign ss1_c = ss_c; //same as above but for lower four digits!

//   assign val_to_display = rx_debug[31:0];
//   assign led = {~GPIO4, state_debug[0], 2'b00, rx_valid, 3'b000, rx_debug[39:32]};

// endmodule // top_level

// `default_nettype wire

// Arduino with motor

// `timescale 1ns / 1ps
// `default_nettype none // prevents system from inferring an undeclared logic (good practice)

// module top_level(
//   input wire clk_100mhz,
//   input wire [15:0] sw, //all 16 input slide switches
//   input wire [3:0] btn, //all four momentary button switches
//   input wire GPIO1,
//   input wire GPIO2,
//   output wire GPIO3,
//   input wire GPIO4,
//   output logic [15:0] led, //16 green output LEDs (located right above switches)
//   output logic [2:0] rgb0, //rgb led
//   output logic [2:0] rgb1, //rgb led
//   output logic [3:0] ss0_an,//anode control for upper four digits of seven-seg display
//   output logic [3:0] ss1_an,//anode control for lower four digits of seven-seg display
//   output logic [6:0] ss0_c, //cathode controls for the segments of upper four digits
//   output logic [6:0] ss1_c, //cathod controls for the segments of lower four digits
//   output logic [3:0] s
//   );
//   //assign led = sw; //for debugging
//   //shut up those rgb LEDs (active high):
//   assign rgb1= 0;
//   assign rgb0 = 0;

//   logic sys_rst;
//   assign sys_rst = btn[0];

//   // Set up arduino communication
//   logic [15:0] heading, distance;
//   logic [1:0] state_debug;
//   logic [39:0] rx_debug;
//   logic rx_valid;
 

//   uart_arduino arduino(
//     .clk(clk_100mhz),
//     .rst(sys_rst),
//     .rx(GPIO4),
//     .tx(GPIO3),
//     .heading(heading),
//     .distance(distance),
//     .state_debug(state_debug),
//     .rx_debug(rx_debug),
//     .rx_valid_o(rx_valid)
//   );

//   // Set up motor control module
//   reg [2:0] debug_data, prev_state;
//   wire encoderL, encoderR;
//   assign encoderL = GPIO1;
//   assign encoderR = GPIO2;
//   logic distance_motor, heading_motor, enable;
//   logic [15:0] turn_heading;
//   reg [31:0] counter;


//  // assign pmodb pins for motor inputs and controls
//   motor_controller motor(
//     .clk(clk_100mhz),
//     .rst(sys_rst),
//     .encoderL(encoderL),
//     .encoderR(encoderR),
//     .imu_heading(heading_motor),
//     .distance(distance_motor),
//     .enable(enable),
//     .pwmL1(s[0]),
//     .pwmL2(s[1]),
//     .pwmR1(s[2]),
//     .pwmR2(s[3]),
//     .debug_data(debug_data)
//   );

//   // motor controller handling for heading motor, distance motor and enable
//   always_ff @(posedge clk_100mhz) begin
//     if (sys_rst) begin
//         // reset logic
//         heading_motor <= 0;
//         distance_motor <= 0;
//         enable <= 0;
//         prev_state <= 0;
//         turn_heading <= 0;
//     end else begin
//       // enable logic: once we get sensor status good then we can enable motors to move right now will only move is sensors are working.
//       enable <= (state_debug == 2'b01) ? 1'b1: 1'b0;

//       // distance logic: if distance read is less than 16
//       distance_motor <= (distance < 25) ? 1'b1: 1'b0;

//       // heading logic is a bit harder
//       prev_state <= debug_data;
//       // first store heading if state is moving into right or left
//       //if (prev_state != debug_data && (debug_data == 2 || debug_data == 4)) begin
//       //  turn_heading <= heading;
//       if(debug_data == 3'b001 || debug_data == 3'b011 ) begin
//         turn_heading <= heading;
//         heading_motor <= 0 ; 
//       end else if (debug_data == 2 || debug_data == 4) begin
//         if(debug_data == 2) begin 
//           if ((heading > turn_heading)) begin
//             if((heading - turn_heading ) > 80) begin
//               heading_motor <= 1;
//             end else begin
//               heading_motor <= 0;
//             end
//           end else begin
//             if((turn_heading - heading ) > 80) begin
//               heading_motor <= 1;
//             end else begin
//               heading_motor <= 0;
//             end
//           end
//         end else begin 
//           if ((heading > turn_heading)) begin
//             if((heading - turn_heading ) > 75) begin
//               heading_motor <= 1;
//             end else begin
//               heading_motor <= 0;
//             end
//           end else begin
//             if((turn_heading - heading ) > 75) begin
//               heading_motor <= 1;
//             end else begin
//               heading_motor <= 0;
//             end
//           end
//         end 
//       end
//     end
//   end

//   // Now assign rx_debug to 7 segment LED
//   //7-segment display-related concepts:
//   logic [31:0] val_to_display; //either the spi data or the btn_count data (default)
//   logic [6:0] ss_c; //used to grab output cathode signal for 7s leds
 
//   seven_segment_controller mssc(.clk_in(clk_100mhz),
//                                 .rst_in(sys_rst),
//                                 .val_in(val_to_display),
//                                 .cat_out(ss_c),
//                                 .an_out({ss0_an, ss1_an}));
//   assign ss0_c = ss_c; //control upper four digit's cathodes!
//   assign ss1_c = ss_c; //same as above but for lower four digits!

//   always_ff @(posedge clk_100mhz) begin
//     if(sys_rst) begin

//     end else begin
//       if(counter < 5_000_000)begin
//         counter <= counter + 1;
//       end else begin
//         counter <= 0;
//         val_to_display = rx_debug[31:0];
//       end
//     end
//   end

//   //assign val_to_display = rx_debug[31:0];
//   //assign led = {~GPIO4, state_debug[0], debug_data, rx_valid, 3'b000, rx_debug[39:32]};
//   assign led [15] = ~GPIO4 ; 
//   assign led[14] = state_debug[0]; 
//   assign led[13:11] = debug_data ;
//   assign led[10] = rx_valid ;
//   assign led [9:8] = 2'b00 ;
//   assign led [7:0] = rx_debug[39:32] ;

// endmodule // top_level

// `default_nettype wire