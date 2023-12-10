`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module top_level(
  input wire clk_100mhz, //
  input wire [15:0] sw, //all 16 input slide switches
  input wire [3:0] btn, //all four momentary button switches
  output logic [15:0] led, //16 green output LEDs (located right above switches)
  output logic [2:0] rgb0, //rgb led
  output logic [2:0] rgb1, //rgb led
  output logic [6:0] ss0_c,
  output logic [6:0] ss1_c,
  output logic [3:0] ss0_an,
  output logic [3:0] ss1_an,
  input wire pmod_pin
  );

  logic [3:0] old_btn;
  logic old_pmod_pin;

  logic [31:0] dividend;
  logic [31:0] divisor;
  logic [31:0] remainder;
  logic [31:0] quotient;
  logic busy;
  logic error;
  logic valid;
  logic valid_out;

  always_ff @(posedge clk_100mhz)begin
    old_pmod_pin <= pmod_pin;
    for (int i=0; i<4; i=i+1)begin
      old_btn[i] <= btn[i];
    end
  end

  divider4 uut ( .clk_in(clk_100mhz),
                  .rst_in(0),
                  .dividend_in(dividend),
                  .divisor_in(divisor),
                  .data_valid_in(valid),
                  .quotient_out(quotient),
                  .remainder_out(remainder),
                  .data_valid_out(valid_out),
                  .error_out(error),
                  .busy_out(busy));

  always_ff @(posedge clk_100mhz)begin

    //if testing awful division:
    //if (pmod_pin & ~old_pmod_pin) begin
    //  quotient <= dividend/divisor;
    //end

    valid <= (pmod_pin & ~old_pmod_pin);
    if (btn[0] & ~old_btn[0])begin
      dividend[31:16] <= sw; //divide //load dividend (upper 16)
    end
    if (btn[1] & ~old_btn[1])begin
      dividend[15:0] <= sw; //divide //load dividend (lower 16)
    end
    if (btn[2] & ~old_btn[2])begin
      divisor[31:0] <= sw; //divide //load dividend (upper 16)
    end
    if (btn[3] & ~old_btn[3])begin
      divisor[15:0] <= sw; //divide //load dividend (lower 16)
    end
  end

  logic [6:0] ss_cn; //used for inverting output signal
  seven_segment_controller mssc(.clk_in(clk_100mhz),
                                .rst_in(0),
                                .val_in(quotient),
                                //.val_in(btn_count),
                                .cat_out(ss_cn),
                                .an_out({ss0_an, ss1_an}));
  assign ss0_c = ss_cn;
  assign ss1_c = ss_cn; //same as above



endmodule



`default_nettype wire
