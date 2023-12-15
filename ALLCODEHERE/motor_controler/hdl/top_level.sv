`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module top_level(
  input wire clk_100mhz,
  input wire [15:0] sw, //all 16 input slide switches
  input wire [3:0] btn, //all four momentary button switches
  input wire GPIO0,
  input wire GPIO4,
  output logic [15:0] led, //16 green output LEDs (located right above switches)
  //output logic [2:0] rgb0, //rgb led
  //output logic [2:0] rgb1, //rgb led
  //output logic spkl, spkr, //speaker outputs
 // output logic mic_clk, //microphone clock
  //input wire  mic_data //microphone data
  output logic [7:0] pmoda,
  output logic [3:0] s
  
  
  );
    localparam integer THREE_REVS = 900;
    logic rst_sys;
    assign rst_sys = btn[1];
    logic [7:0] level_1;
    logic [7:0] level_2;
    logic [12:0] counter;
    logic prev_GPIO0;
    logic prev_GPIO4;

    

    speed_control my_sc (
        .clk_in(clk_100mhz),
        .rst_in(rst_sys),
        .level_in_1(level_1),
        .level_in_2(level_2),
        .direction_1(btn[2]),
        .direction_2(btn[3]),
        .pwm_out(s[3:0])
    );

    always_ff @(posedge clk_100mhz) begin
      if (rst_sys) begin
      
        counter <= 0;
      end else begin
       

        prev_GPIO0 <= GPIO0;
        

        if ((GPIO0 != prev_GPIO0) && GPIO0 ) begin
          counter <= counter + 1'b1;
        end
      end
    end

    always_comb begin 
        if (counter > THREE_REVS) begin
          level_1 = 0;
          level_2 = 0;
        end else begin
          level_1 = sw[7:0];
          level_2 = sw[15:8];
        end
    end

    

endmodule // top_level
`default_nettype wire