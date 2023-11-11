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
  output logic [7:0] pmoda, //output I/O used for SPI TX (in part 3)
  input wire [7:0] pmodb //input I/O used for SPI RX (in part 3)
  );
 
  //shut up those rgb LEDs (active high):
  assign rgb1= 0;
  assign rgb0 = 0;
 
  /* have btnd control system reset */
  logic sys_rst;
  assign sys_rst = btn[0];
 
  /* how many button presses have we seen so far?
  * wire this up to the LED display
  */
  logic [15:0] btn_count; //use me to keep track of counting
  assign led = btn_count;
 
  //downstream/display variables:
  logic [31:0] val_to_display; //either the spi data or the btn_count data (default)
  logic [15:0] received; //data your spi_rx receives (part 3)
  logic [15:0] transmitted; //data your spi_tx module transmits (part 3)
  logic [6:0] ss_c; //used to grab output cathode signal for 7s leds
 
  logic button_input;
  /* debouncer for the button. we wrote this
  * in lecture together.
  * TODO: make a variable for the debounced
  * button output, and feed it into your edge
  * detector
  */
  debouncer btn1_db(.clk_in(clk_100mhz),
                  .rst_in(sys_rst),
                  .dirty_in(btn[1]),
                  .clean_out(button_input));
 
  /* this should go high for one cycle on the
  * rising edge of the (debounced) button output
  */
  logic btn_pulse;
  logic old_button_input;
  /* TODO: write your edge detector for part 1 of the
   * lab here!
   */
  always_ff@(posedge clk_100mhz)begin
    if (button_input == 1 && old_button_input != button_input)begin
      btn_pulse <= 1;
      old_button_input <= button_input;
    end else begin
      btn_pulse <= 0;
      old_button_input <= button_input;
    end
  end

 
  /* the button-press counter.
   * TODO: finish this during part 1 of the lab
   */
  simple_counter msc( .clk_in(clk_100mhz),
                      .rst_in(sys_rst),
                      .evt_in(btn_pulse),
                      .count_out(btn_count));
 
  //for starters just display button count:
  //assign val_to_display = btn_count;
  //in part 3 replace above line with below so we can see both (and default to spi rx/tx)
  assign val_to_display = btn[2]?btn_count:{received, transmitted};
 
  //uncomment seven segment module for part 2!
  
  seven_segment_controller mssc(.clk_in(clk_100mhz),
                                .rst_in(sys_rst),
                                .val_in(val_to_display),
                                .cat_out(ss_c),
                                .an_out({ss0_an, ss1_an}));

  assign ss0_c = ss_c; //control upper four digit's cathodes!
  assign ss1_c = ss_c; //same as above but for lower four digits!
 
  //uncomment collection below for part 3!
  
  //SPI related variables!
  logic [15:0] spi_rx_data; //data generated by spi_rx module
  logic new_data; //indicator from spi_rx a new "word" has been received!
  logic data_clk; //incoming data clock signal for spi rx (after sync)
  logic data_line; //incoming data line for spi rx (after sync)
  logic select; //incoming select line for spi rx (after sync)
 
  assign transmitted = sw; //place sw values onto transmitted logic
 
  spi_tx #(.DATA_WIDTH(16), .DATA_PERIOD(10))
        ( .clk_in(clk_100mhz),
          .rst_in(sys_rst),
          .data_in(transmitted),
          .trigger_in(btn_pulse), //use our btn pulse to send messages
          .data_out(pmoda[0]),
          .data_clk_out(pmoda[1]),
          .sel_out(pmoda[2])
        );
 
  synchronizer s1
        ( .clk_in(clk_100mhz),
          .rst_in(sys_rst),
          .us_in(pmodb[0]),
          .s_out(data_line));
 
  synchronizer s2
        ( .clk_in(clk_100mhz),
          .rst_in(sys_rst),
          .us_in(pmodb[1]),
          .s_out(data_clk));
 
  synchronizer s3
        ( .clk_in(clk_100mhz),
          .rst_in(sys_rst),
          .us_in(pmodb[2]),
          .s_out(select));
 
  spi_rx#(.DATA_WIDTH(16))
        ( .clk_in(clk_100mhz),
          .rst_in(sys_rst),
          .data_in(data_line),
          .sel_in(select),
          .data_clk_in(data_clk),
          .data_out(spi_rx_data),
          .new_data_out(new_data)
        );
 
  //ALSO TO DO (IMPORTANT):
  //update received to be:
  //* 0 if sys_rst active
  //* spi_rx_data if new_data is high! (and only when high)
  //Do this with sequential logic! Not combinational!
  always_ff@(posedge clk_100mhz)begin
    if (sys_rst == 1) begin 
      received <= 0 ;
    end else if( new_data == 1 ) begin 
      received <= spi_rx_data ;
    end else begin 
      received <= received ;
    end 
  end
 

endmodule // top_level
`default_nettype wire