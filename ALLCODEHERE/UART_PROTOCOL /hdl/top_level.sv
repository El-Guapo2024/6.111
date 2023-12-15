`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module top_level(
  input wire clk_100mhz, //
  input wire [2:0] sw, //all 16 input slide switches
  input wire [3:0] btn, //all four momentary button switches
  input wire [1:0] pmodb, //input I/O used for UART IMU 
  output logic [15:0] led, //16 green output LEDs (located right above switches)
  output logic [3:0] ss0_an,//anode control for upper four digits of seven-seg display
  output logic [3:0] ss1_an,//anode control for lower four digits of seven-seg display
  output logic [6:0] ss0_c, //cathode controls for the segments of upper four digits
  output logic [6:0] ss1_c, //cathod controls for the segments of lower four digits
  //output logic [2:0] rgb0, //rgb led
  //output logic [2:0] rgb1, //rgb led
  output logic [1:0] pmoda //output I/O used for UART Lidar 
  );
 /*
  ila_0 myIla
  (
    .clk(clk_100mhz),
    .probe0(pmoda[0]),
    .probe1(pmodb[0]),
    .probe2(1'b0),
    .probe3(1'b0),
    .probe4(1'b0),
    .probe5(1'b0),
    .probe6(1'b0),
    .probe7(1'b0),
    .probe8(1'b0),
    .probe9(1'b0),
    .probe10(1'b0),
    .probe11(1'b0),
    .probe12(1'b0),
    .probe13(1'b0),
    .probe14(1'b0),
    .probe15(1'b0),
    .probe16(1'b0),
    .probe17(1'b0),
    .probe18(1'b0),
    .probe19(1'b0));

*/
logic sys_rst;
assign sys_rst = btn[0];

 //code to grab new full code when indicated by module!
  //code to grab and display any errors that you may generate!
  always_ff @(posedge clk_100mhz)begin
    if(sys_rst) begin
      val_to_display <= 32'hFFFF ;
    end else if (btn[2]) begin 
      val_to_display <= angle_distance ;
    end 
  end

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
 
// Lidar Highly Modularized 
logic clock ; 

always_ff @(posedge clk_100mhz) begin 
  clock <= ~clock ;
end 

logic RunLidarBool;
logic New_Point_Data ;
logic [31:0] angle_distance ;
assign RunLidarBool = 1 ; 
logic rx_lidar;
logic tx_lidar;
logic [2:0] lidar_error_out ;
logic [2:0] Start_protocol_error_out ; 

assign led  [2:0] = lidar_error_out ;
assign led [5:3] = Start_protocol_error_out;
assign pmoda [1] = tx_lidar ;
assign pmoda [0] = clock ;
assign rx_lidar = pmodb[0] ;
assign led [15] = ~tx_lidar ;
assign led [14] = ~rx_lidar ; 
//assign pmoda [1] = clock ;
Lidar_Mini_TopLevel myLidar(
    .clk_in(clk_100mhz),
    .rst_in(sys_rst),
    .rx_in(rx_lidar),
    .run_protocol_in(1'b1) ,
    .tx_out(tx_lidar),
    .state_out(lidar_error_out),
    .LiDAR_Start_out(Start_protocol_error_out),
    .new_data_out(New_Point_Data),
    .angle_distance_out(angle_distance)
    );




endmodule // top_level
`default_nettype wire