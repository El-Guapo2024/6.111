`timescale 1ns / 1ps
`default_nettype none
module  speed_control(
            input wire clk_in,
            input wire rst_in,
            input wire [7:0] level_in_1,
            input wire [7:0] level_in_2,
            input wire direction_1,
            input wire direction_2,
            
            output logic [3:0] pwm_out
  );
    logic [1:0] counter;
    logic tick_in;
    
    pwm my_pwm_1 (
        .clk_in(clk_in),
        .rst_in(rst_in),
        .level_in(level_in_1 ),
        .tick_in(tick_in ),
        .pwm_out(pwm_out[0]),
        .enable(~direction_1)

    );

    pwm my_pwm_2 (
        .clk_in(clk_in),
        .rst_in(rst_in),
        .level_in(level_in_1),
        .tick_in(tick_in ),
        .pwm_out(pwm_out[1]),
        .enable(direction_1)

    );

        pwm my_pwm_3 (
        .clk_in(clk_in),
        .rst_in(rst_in),
        .level_in(level_in_2),
        .tick_in(tick_in ),
        .pwm_out(pwm_out[2]),
        .enable(~direction_2)

    );

        pwm my_pwm_4 (
        .clk_in(clk_in),
        .rst_in(rst_in),
        .level_in(level_in_2 ),
        .tick_in(tick_in ),
        .pwm_out(pwm_out[3]),
        .enable(direction_2)

    );

    always_ff @(posedge clk_in) begin
        if (rst_in)begin
            tick_in <= 0;
            counter <= 0;
        end else begin
            if (counter == 2'b11 ) begin
                tick_in <= 1;
            end else begin
                tick_in <= 0;
            end
            counter <= counter + 1;
        end

    end 
    
endmodule
`default_nettype wire