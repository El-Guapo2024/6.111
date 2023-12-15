`timescale 1ns / 1ps
`default_nettype none

module top_level(
  input wire clk_100mhz,
  input wire [15:0] sw, //all 16 input slide switches
  input wire [3:0] btn, //all four momentary button switches
  output logic [15:0] led, //16 green output LEDs (located right above switches)
  output logic [2:0] rgb0, //rgb led
  output logic [2:0] rgb1, //rgb led
  output logic [2:0] hdmi_tx_p, //hdmi output signals (blue, green, red)
  output logic [2:0] hdmi_tx_n, //hdmi output signals (negatives)
  output logic hdmi_clk_p, hdmi_clk_n, //differential hdmi clock
  output logic [6:0] ss0_c,
  output logic [6:0] ss1_c,
  output logic [3:0] ss0_an,
  output logic [3:0] ss1_an,
  input wire [7:0] pmoda,
  input wire [2:0] pmodb,
  output logic pmodbclk,
  output logic pmodblock
  );
  
  //assign led = sw;
  assign led[15] = ~pmoda[0];

  //shut up those rgb LEDs (active high):
  assign rgb1= 0;
  assign rgb0 = 0;
  /* have btnd control system reset */
  logic sys_rst;
  assign sys_rst = btn[0];

  //Clocking Variables:
  logic clk_pixel, clk_5x; //clock lines
  logic locked; //locked signal (we'll leave unused but still hook it up)

  //clock manager...creates 74.25 Hz and 5 times 74.25 MHz for pixel and TMDS
  hdmi_clk_wiz_720p mhdmicw (.clk_pixel(clk_pixel),.clk_tmds(clk_5x),
          .reset(0), .locked(locked), .clk_ref(clk_100mhz));

  //signals related to driving the video pipeline
  logic [10:0] hcount;
  logic [9:0] vcount;
  logic vert_sync;
  logic hor_sync;
  logic active_draw;
  logic new_frame;
  logic [5:0] frame_count;

  //from week 04! (make sure you include in your hdl)
  video_sig_gen mvg(
      .clk_pixel_in(clk_pixel),
      .rst_in(sys_rst),
      .hcount_out(hcount),
      .vcount_out(vcount),
      .vs_out(vert_sync),
      .hs_out(hor_sync),
      .ad_out(active_draw),
      .nf_out(new_frame),
      .fc_out(frame_count));

  logic [7:0] img_red, img_green, img_blue;

  //x_com and y_com are the image sprite locations
  logic [10:0] x_com;
  logic [9:0] y_com;
  logic pop;
  //update center of mass x_com, y_com based on new_com signal
  always_ff @(posedge clk_pixel)begin
    if (sys_rst)begin
      x_com <= 0;
      y_com <= 0;
      pop <= 0;
    end if(btn[1])begin
      //do some random stuff here to popocat
    end
  end

  logic [5:0] word[9:0] ;
  assign word[0] = 6'd21 ;
  assign word[1] = 6'd8 ;
  assign word[2] = 6'd18 ;
  assign word[3] = 6'd20 ;
  assign word[4] = 6'd0 ;
  assign word[5] = 6'd11 ;
  assign word[6] = 6'd8 ;
  assign word[7] = 6'd25 ;
  assign word[8] = 6'd4 ;
  assign word[9] = 6'd17 ;
  //use this in the first part of checkoff 01:
  //instance of image sprite.
  write_word myWord (
    .pixel_clk_in(clk_pixel),
    .rst_in(sys_rst),
    .hcount_in(hcount),   //TODO: needs to use pipelined signal (PS1)
    .vcount_in(vcount),   //TODO: needs to use pipelined signal (PS1)
    .x_in(10'd360),
    .y_in(9'd360),
    .word_in(word),
    .red_out(img_red),
    .green_out(img_green),
    .blue_out(img_blue));

  logic [7:0] red, green, blue;


  // Account for frame buffer 
  logic [7:0] lidar_red;
  logic [7:0] lidar_green;
  logic [7:0] lidar_blue;
  assign lidar_red = frame_buff?8'hff:8'h00;
  assign lidar_green = frame_buff?8'hff:8'h00;
  assign lidar_blue = frame_buff?8'hff:8'h00;
  logic [7:0] square ;
  assign red = img_red+lidar_red;
  assign green = img_green+lidar_green;
  assign blue = img_blue+lidar_blue;

  logic [9:0] tmds_10b [0:2]; //output of each TMDS encoder!
  logic tmds_signal [2:0]; //output of each TMDS serializer!

  //three tmds_encoders (blue, green, red)
  //blue should have {vert_sync and hor_sync for control signals)
  //red and green have nothing
  tmds_encoder tmds_red(
    .clk_in(clk_pixel),
    .rst_in(sys_rst),
    .data_in(red),
    .control_in(2'b0),
    .ve_in(active_draw),
    .tmds_out(tmds_10b[2]));

  tmds_encoder tmds_green(
    .clk_in(clk_pixel),
    .rst_in(sys_rst),
    .data_in(green),
    .control_in(2'b0),
    .ve_in(active_draw),
    .tmds_out(tmds_10b[1]));

  tmds_encoder tmds_blue(
    .clk_in(clk_pixel),
    .rst_in(sys_rst),
    .data_in(blue),
    .control_in({vert_sync,hor_sync}),
    .ve_in(active_draw),
    .tmds_out(tmds_10b[0]));

  //four tmds_serializers (blue, green, red, and clock)
  tmds_serializer red_ser(
    .clk_pixel_in(clk_pixel),
    .clk_5x_in(clk_5x),
    .rst_in(sys_rst),
    .tmds_in(tmds_10b[2]),
    .tmds_out(tmds_signal[2]));

  tmds_serializer green_ser(
    .clk_pixel_in(clk_pixel),
    .clk_5x_in(clk_5x),
    .rst_in(sys_rst),
    .tmds_in(tmds_10b[1]),
    .tmds_out(tmds_signal[1]));

  tmds_serializer blue_ser(
    .clk_pixel_in(clk_pixel),
    .clk_5x_in(clk_5x),
    .rst_in(sys_rst),
    .tmds_in(tmds_10b[0]),
    .tmds_out(tmds_signal[0]));

  //output buffers generating differential signal:
  OBUFDS OBUFDS_blue (.I(tmds_signal[0]), .O(hdmi_tx_p[0]), .OB(hdmi_tx_n[0]));
  OBUFDS OBUFDS_green(.I(tmds_signal[1]), .O(hdmi_tx_p[1]), .OB(hdmi_tx_n[1]));
  OBUFDS OBUFDS_red  (.I(tmds_signal[2]), .O(hdmi_tx_p[2]), .OB(hdmi_tx_n[2]));
  OBUFDS OBUFDS_clock(.I(clk_pixel), .O(hdmi_clk_p), .OB(hdmi_clk_n));

  assign ss0_c = 0; //ss_c; //control upper four digit's cathodes!
  assign ss1_c = 0; //ss_c; //same as above but for lower four digits!

  // For input into Frame buff 
  logic valid_addr; 
  logic [16:0] img_addr ;
  logic [1:0] valid_addr_pipe ; 
  logic frame_buff ;
  logic frame_buff_raw ;
  always_ff @(posedge clk_pixel)begin
    valid_addr_pipe[0] <= valid_addr;
    valid_addr_pipe[1] <= valid_addr_pipe[0];
  end
  assign frame_buff = valid_addr_pipe[1]?frame_buff_raw:1'b0;
  
  always_comb begin 
    if((hcount >1 && hcount< 360)&&( vcount> 1 && vcount<360)) begin
      img_addr = (hcount)+(vcount)*360 ;
      valid_addr = 1 ;
    end else begin
      img_addr = 0 ;
      valid_addr = 0 ;
    end 
  end 

  //outputs of the recover module
  logic pixel_data_rec; // pixel data from recovery module
  logic [10:0] hcount_rec; //hcount from recovery module
  logic [9:0] vcount_rec; //vcount from recovery module
  logic  data_valid_rec; 
  logic[2:0] lidar_state ; 
  assign led[2:0] = lidar_state;
  assign led[3] = pixel_data_rec ;
  assign led[4] = valid_addr ;
  assign led[5] = frame_buff;
  assign led[6] = data_valid_rec ;
  lidar myLidar(
    .clk_in(clk_pixel),

    .rx_in(pmoda[0]),
    .rst_in(sys_rst),
    .valid_pixel_out(data_valid_rec),
    .pixel_out(pixel_data_rec),
    .hcount_out(hcount_rec),
    .vcount_out(vcount_rec),
    .state_out(lidar_state)
  );
  

 //two-port BRAM used to hold image from camera.
  //because camera is producing video for 320 by 240 pixels at ~30 fps
  //but our display is running at 720p at 60 fps, there's no hope to have the
  //production and consumption of information be synchronized in this system
  //instead we use a frame buffer as a go-between. The camera places pixels in at
  //its own rate, and we pull them out for display at the 720p rate/requirement
  //this avoids the whole sync issue. It will however result in artifacts when you
  //introduce fast motion in front of the camera. These lines/tears in the image
  //are the result of unsynced frame-rewriting happening while displaying. It won't
  //matter for slow movement
  //also note the camera produces a 320*240 image, but we display it 240 by 320
  //(taken care of by the rotate module below).

  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(1), //each entry in this memory is 16 bits
    .RAM_DEPTH(360*360)) 
    frame_buffer (
    .addra(hcount_rec + 360*vcount_rec), //pixels are stored using this math
    .clka(clk_pixel),
    .wea(data_valid_rec),
    .dina(pixel_data_rec),
    .ena(1'b1),
    .regcea(1'b1),
    .rsta(sys_rst),
    .douta(), //never read from this side
    .addrb(img_addr),//transformed lookup pixel
    .dinb(16'b0),
    .clkb(clk_pixel),
    .web(1'b0),
    .enb(valid_addr),
    .rstb(sys_rst),
    .regceb(1'b1),
    .doutb(frame_buff_raw)
  );
endmodule // top_level


`default_nettype wire
