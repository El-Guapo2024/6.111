`timescale 1ns / 1ps
`default_nettype none

module motor_controller (
    input wire clk,         // System clock (100 MHz)
    input wire rst,         // Reset signal
    input wire encoderL,    // Encoder left signal
    input wire encoderR,    // Encoder right signal
    input wire imu_heading,
    input wire distance,
    input wire enable,
    output reg pwmL1,        // PWM signal Left
    output reg pwmL2,
    output reg pwmR1,        // PWM signal Right
    output reg pwmR2,
    output reg[2:0] debug_data  // Debug data
);

    localparam integer COUNTS_PER_REV = 300;
    localparam integer ONE_SECOND_COUNT = 100_000_000; // 100 MHz clock
    localparam integer DUTY = 60;

    reg[7:0] dutyL;  // Duty cycle for left motor
    reg[7:0] dutyR;  // Duty cycle for right motor
    reg dirL, dirR;
    reg[15:0] revCountL = 0;  // Revolution count for left motor
    reg[15:0] revCountR = 0;  // Revolution count for right motor
    reg[31:0] timer = 0;      // Timer for delays
    reg prevEncoderL = 0;     // Previous state of encoderL
    reg prevEncoderR = 0;     // Previous state of encoderR

    typedef enum reg [2:0] {
        WAIT,
        FORWARD_IDLE,
        RIGHT,
        FORWARD_AVOID,
        LEFT
    } state_t;

    state_t current_state = WAIT;

    // PWM module instances
    pwm pwm_left (
        .clk(clk),
        .rst(rst),
        .duty(dutyL),
        .dir(dirL),
        .pwm1(pwmL1),
        .pwm2(pwmL2)
    );

    pwm pwm_right (
        .clk(clk),
        .rst(rst),
        .duty(dutyL),
        .dir(dirR),
        .pwm1(pwmR1),
        .pwm2(pwmR2)
    );

    // // Encoder signal handling
    // always_ff @(posedge clk) begin
    //     if (rst) begin
    //         revCountL <= 0;
    //         revCountR <= 0;
    //         prevEncoderL <= 0;
    //         prevEncoderR <= 0;
    //     end else begin
    //         debug_data <= current_state;
    //         // Update the previous state
    //         prevEncoderL <= encoderL;
    //         prevEncoderR <= encoderR;

    //         // Increment on rising edge
    //         if (!prevEncoderL && encoderL) revCountL <= revCountL + 1;
    //         if (!prevEncoderR && encoderR) revCountR <= revCountR + 1;
    //     end
    // end

    // Main state machine logic
    always_ff @(posedge clk) begin
        if (rst) begin
            // Reset all variables
            current_state <= WAIT;
            timer <= 0;
            dutyL <= 0;
            dutyR <= 0;
            dirL <= 0;
            dirR <= 0;

            revCountL <= 0;
            revCountR <= 0;
            prevEncoderL <= 0;
            prevEncoderR <= 0;
        end
        else begin
            debug_data <= current_state;
            // Update the previous state
            prevEncoderL <= encoderL;
            prevEncoderR <= encoderR;

            // Increment on rising edge
            if (!prevEncoderL && encoderL) revCountL <= revCountL + 1;
            if (!prevEncoderR && encoderR) revCountR <= revCountR + 1;

            if(enable == 0) begin
                current_state <= WAIT;
            end

            case (current_state)
                WAIT: begin
                    dutyL <= 0;
                    dutyR <= 0;
                    if (enable) begin
                        current_state <= FORWARD_IDLE;
                    end
                end

                FORWARD_IDLE: begin
                    dutyL <= DUTY; // ~40% of 255
                    dutyR <= DUTY;
                    dirL <= 0;
                    dirR <= 0;
                    if (distance) begin
                        current_state <= RIGHT;
                    end
                end

                RIGHT: begin
                    dutyL <= DUTY; 
                    dutyR <= DUTY;
                    dirL <= 0;
                    dirR <= 1;
                    if (imu_heading) begin
                        current_state <= FORWARD_AVOID;
                        revCountL <= 0;
                        revCountR <= 0;
                    end
                end

                FORWARD_AVOID: begin
                    dutyL <= DUTY;
                    dutyR <= DUTY;
                    dirL <= 0;
                    dirR <= 0;
                    if(revCountL >= COUNTS_PER_REV && revCountR >= COUNTS_PER_REV) begin
                        current_state <= LEFT;
                        revCountL <= 0;
                        revCountR <= 0;
                    end
                end

                LEFT: begin
                    dutyL <= DUTY; 
                    dutyR <= DUTY;
                    dirL <= 1;
                    dirR <= 0;
                    if (imu_heading) begin
                        current_state <= FORWARD_IDLE;
                    end
                end

            endcase
        end
    end

endmodule

module pwm(
    input wire clk,       // System clock (100 MHz)
    input wire rst,       // Reset signal
    input wire[7:0] duty, // Duty cycle (0-255),
    input wire dir,
    output reg pwm1,        // PWM output signal
    output reg pwm2
);

    // Clock division factor for 20 kHz PWM frequency
    localparam integer MAX_COUNT = 5000;

    // Internal counter
    reg[12:0] counter = 0;

    always_ff @(posedge clk) begin
        if (rst) begin
            // Reset counter and pwm signal
            counter <= 0;
            pwm1 <= 0;
            pwm2 <= 0;
        end
        else begin
            // Increment counter
            if (counter < MAX_COUNT - 1) begin
                counter <= counter + 1;
            end
            else begin
                counter <= 0;
            end

            // Generate PWM signal
            if (dir == 1) begin
                pwm1 <= (counter < (duty * (MAX_COUNT / 256))) ? 1'b1 : 1'b0;
                pwm2 <= 0;
            end else begin
                pwm2 <= (counter < (duty * (MAX_COUNT / 256))) ? 1'b1 : 1'b0;
                pwm1 <= 0;
            end
            
        end
    end

endmodule

`default_nettype wire