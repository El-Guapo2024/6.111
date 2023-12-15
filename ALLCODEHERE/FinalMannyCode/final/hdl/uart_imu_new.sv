`timescale 1ns / 1ps
`default_nettype none

// STILL NOT SURE IF LENGTH IF THE RIGHT SIZE COMMAND 3
module uart_imu_new(
    input wire clk,
    input wire rst,
    input wire rx,
    output reg tx,
    output reg[15:0] heading,
    output reg[15:0] debug,
    output reg [3:0] state_debug
);

    // Instantiate the UART RX and TX modules
    reg [7:0] rx_data;
    logic rx_valid;
    uart_rx #(.CLOCKS_PER_BAUD(868)) uart_receiver(
        .clk(clk),
        .rx(rx),
        .data_o(rx_data),
        .valid_o(rx_valid)
    );

    reg [7:0] tx_data;
    logic tx_start, tx_done;
    uart_tx #(.CLOCKS_PER_BAUD(868)) uart_transmitter(
        .clk(clk),
        .data_i(tx_data),
        .start_i(tx_start),
        .done_o(tx_done),
        .tx(tx)
    );

    // main state machine
    typedef enum reg [3:0] {
        BOOT,
        SET_OPR_MODE,
        OPR_MODE_RESPONSE,
        UNIT_SEL,
        UNIT_SEL_RESPONSE,
        READ_CALI,
        CALI_STATE_RESPONSE,
        READ_DIRECTION_MSB,
        DIRECTION_RESPONSE_MSB,
        READ_DIRECTION_LSB,
        DIRECTION_RESPONSE_LSB,
        POST_HEADING,
        WAIT_COUNTER
    } state_t;

    // State machine for controlling the UART communication
    state_t state = BOOT;
    reg [7:0] command [4:0]; // Command sequence
    reg [3:0] command_index = 0;
    reg [7:0] response [4:0];
    reg [0:0] response_index = 0;

    reg [22:0] boot_counter = 0;  // 23-bit counter for 80 ms delay at 100 MHz clock

    reg [15:0] heading_current = 0;

    always_ff @(posedge clk) begin
        if (rst) begin
            // Reset logic
            state <= BOOT;
            command_index <= 0;
            response_index <= 0;
            tx_data <= 0;
            tx_start <= 0;
            boot_counter <= 0;
            heading_current <= 0;
            heading <= 0;
            debug <= 0;
            // Reset other control signals and buffers as needed
            command[0] <= 8'hAA;
            command[1] <= 8'h00;
            command[2] <= 8'h3D;
            command[3] <= 8'h01;
            command[4] <= 8'h0C;

            response[0] <= 8'h00;
            response[1] <= 8'h00;
            response[2] <= 8'h00;
            response[3] <= 8'h00;
            response[4] <= 8'h00;
            state_debug <= 0;
        end else begin
            state_debug <= state;
            // State machine logic
            case (state)
                //0
                BOOT: begin
                    if (boot_counter < 1_000_00) begin
                        // Increment the counter until 80 ms have passed
                        boot_counter <= boot_counter + 1;
                    end else begin
                        // 80 ms have passed, move to the next state
                        state <= SET_OPR_MODE;
                        boot_counter <= 0; // Reset the counter for future use
                        command[0] <= 8'hAA;
                        command[1] <= 8'h00;
                        command[2] <= 8'h3D;
                        command[3] <= 8'h01;
                        command[4] <= 8'h0C;
                    end
                end
                //1
                SET_OPR_MODE: begin
                    if (!tx_start && command_index < 5) begin
                        tx_data <= command[command_index];
                        tx_start <= 1;
                    end else if (tx_done == 1) begin
                        tx_start <= 0;
                        command_index <= command_index + 1;
                        if (command_index == 5) begin
                            state <= OPR_MODE_RESPONSE;
                            response_index <= 0;
                            response[0] <= 8'h00;
                            response[1] <= 8'h00;
                            response[2] <= 8'h00;
                            response[3] <= 8'h00;
                            response[4] <= 8'h00;
                        end
                    end
                end
                //2
                OPR_MODE_RESPONSE: begin
                    if (rx_valid) begin
                        response[response_index] <= rx_data;
                        response_index <= response_index + 1;
                        if (response_index == 1) begin // Check after receiving 2 bytes
                            if (response[0] == 8'hEE && rx_data == 8'h01) begin
                                // Correct response received, move to UNIT_SEL
                                command_index <= 0;
                                state <= READ_CALI;
                                command[0] <= 8'hAA;
                                command[1] <= 8'h00;
                                command[2] <= 8'h3B;
                                command[3] <= 8'h01;
                                command[4] <= 8'h10;
                            end else begin
                                // Incorrect response, reset to send command again
                                command_index <= 0;
                                state <= SET_OPR_MODE;
                                command[0] <= 8'hAA;
                                command[1] <= 8'h00;
                                command[2] <= 8'h3D;
                                command[3] <= 8'h01;
                                command[4] <= 8'h0C;
                            end
                            response_index <= 0; // Reset for next use
                            debug <= rx_data;
                        end
                    end
                end

                // ------ UNIT SEL NEW
                //3
                UNIT_SEL: begin
                    if (!tx_start && command_index < 5) begin
                        tx_data <= command[command_index];
                        tx_start <= 1;
                    end else if (tx_done == 1) begin
                        tx_start <= 0;
                        command_index <= command_index + 1;
                        if (command_index == 5) begin
                            state <= CALI_STATE_RESPONSE;
                            response[0] <= 8'h00;
                            response[1] <= 8'h00;
                            response[2] <= 8'h00;
                            response[3] <= 8'h00;
                            response[4] <= 8'h00;
                        end
                    end
                end
                //4
                UNIT_SEL_RESPONSE: begin
                    if (rx_valid) begin
                        response[response_index] <= rx_data;
                        response_index <= response_index + 1;

                        if (response_index == 1) begin // Check after receiving 2 bytes
                            heading[15:0] <= {response[0], rx_data};
                            if (response[0] == 8'hBB) begin
                                // Correct response received, move to READ_CALI
                                command_index <= 0;
                                state <= WAIT_COUNTER;
                                command[0] <= 8'hAA;
                                command[1] <= 8'h01;
                                command[2] <= 8'h35;
                                command[3] <= 8'h08;
                                command[4] <= 8'hFF;
                            end else begin
                                // Incorrect response, reset to send command again
                                command_index <= 0;
                                state <= READ_CALI;
                                command[0] <= 8'hAA;
                                command[1] <= 8'h00;
                                command[2] <= 8'h3D;
                                command[3] <= 8'h01;
                                command[4] <= 8'h10;
                            end
                            response_index <= 0; // Reset for next use
                            debug <= rx_data;
                        end
                    end
                end
                // -----------

                //5
                READ_CALI: begin
                    if (!tx_start && command_index < 4) begin
                        tx_data <= command[command_index];
                        tx_start <= 1;
                    end else if (tx_done == 1) begin
                        tx_start <= 0;
                        command_index <= command_index + 1;
                        if (command_index == 4) begin
                            state <= CALI_STATE_RESPONSE;
                            response[0] <= 8'h00;
                            response[1] <= 8'h00;
                            response[2] <= 8'h00;
                            response[3] <= 8'h00;
                            response[4] <= 8'h00;
                        end
                    end
                end
                //6
                CALI_STATE_RESPONSE: begin
                    if (rx_valid) begin
                        response[response_index] <= rx_data;
                        response_index <= response_index + 1;

                        if (response_index == 1) begin // Check after receiving 2 bytes
                            
                            if (response[0] == 8'hBB && rx_data[7:6] == 2'b11) begin
                                // Correct response received, move to READ_MSB
                                heading[15:0] <= {response[0], rx_data};
                                command_index <= 0;
                                state <= WAIT_COUNTER;
                                command[0] <= 8'hAA;
                                command[1] <= 8'h01;
                                command[2] <= 8'h1D;
                                command[3] <= 8'h08; 
                                command[4] <= 8'hFF;
                            end else begin
                                // Incorrect response, reset to send command again
                                command_index <= 0;
                                state <= READ_CALI;
                                command[0] <= 8'hAA;
                                command[1] <= 8'h01;
                                command[2] <= 8'h1D;
                                command[3] <= 8'h08;
                                command[4] <= 8'hFF;
                            end
                            response_index <= 0; // Reset for next use
                            debug <= rx_data;
                        end
                    end
                end
                
                //7
                READ_DIRECTION_MSB: begin
                    if (!tx_start && command_index < 4) begin
                        tx_data <= command[command_index];
                        tx_start <= 1;
                    end else if (tx_done == 1) begin
                        tx_start <= 0;
                        command_index <= command_index + 1;
                        if (command_index == 4) begin
                            state <= DIRECTION_RESPONSE_MSB;
                            response[0] <= 8'h00;
                            response[1] <= 8'h00;
                            response[2] <= 8'h00;
                            response[3] <= 8'h00;
                            response[4] <= 8'h00;
                        end
                    end
                end
                //8
                DIRECTION_RESPONSE_MSB: begin
                    if (rx_valid) begin
                        response[response_index] <= rx_data;
                        response_index <= response_index + 1;

                        if (response_index == 1) begin // Check after receiving 2 bytes
                            if (response[0] == 8'hBB) begin
                                // Correct response received,store and move to READ_DIRECTION_LSB
                                //heading[15:0] <= {response[0], rx_data};
                                heading_current[15:0] <= {rx_data, 8'h00};
                                command_index <= 0;
                                state <= READ_DIRECTION_LSB;
                                command[0] <= 8'hAA;
                                command[1] <= 8'h01;
                                command[2] <= 8'h1C;
                                command[3] <= 8'h08; 
                                command[4] <= 8'hFF;
                            end else begin
                                // Incorrect response, reset to send command again
                                command_index <= 0;
                                state <= READ_DIRECTION_MSB;
                                command[0] <= 8'hAA;
                                command[1] <= 8'h01;
                                command[2] <= 8'h1D;
                                command[3] <= 8'h08;
                                command[4] <= 8'hFF;
                            end
                            response_index <= 0; // Reset for next use
                            debug <= rx_data;
                        end
                    end
                end
                //9
                READ_DIRECTION_LSB: begin
                    if (!tx_start && command_index < 4) begin
                        tx_data <= command[command_index];
                        tx_start <= 1;
                    end else if (tx_done == 1) begin
                        tx_start <= 0;
                        command_index <= command_index + 1;
                        if (command_index == 4) begin
                            state <= DIRECTION_RESPONSE_LSB;
                            response_index <= 0;
                            response[0] <= 8'h00;
                            response[1] <= 8'h00;
                            response[2] <= 8'h00;
                            response[3] <= 8'h00;
                            response[4] <= 8'h00;
                        end
                    end
                end
                //10
                DIRECTION_RESPONSE_LSB: begin
                    if (rx_valid) begin
                        response[response_index] <= rx_data;
                        response_index <= response_index + 1;

                        if (response_index == 1) begin // Check after receiving 2 bytes
                            if (response[0] == 8'hBB) begin
                                //heading[15:0] <= {response[0], rx_data};
                                // Correct response received store, post, and move to POST_HEADING
                                heading_current[15:0] <= {heading_current[15:8], rx_data};
                                state <= POST_HEADING;
                            end else begin
                                // Incorrect response, reset to send command again
                                command_index <= 0;
                                state <= READ_DIRECTION_LSB;
                                command[0] <= 8'hAA;
                                command[1] <= 8'h01;
                                command[2] <= 8'h1C;
                                command[3] <= 8'h08; 
                                command[4] <= 8'hFF;
                            end
                            response_index <= 0; // Reset for next use
                            debug <= rx_data;
                        end
                    end
                end
                //11
                POST_HEADING: begin
                    heading <= heading_current;
                    command_index <= 0;
                    state <= WAIT_COUNTER;
                    // command[0] <= 8'hAA;
                    // command[1] <= 8'h01;
                    // command[2] <= 8'h1D;
                    // command[3] <= 8'h08;
                    // command[4] <= 8'hFF;
                    boot_counter <= 0;
                end
                // 12
                WAIT_COUNTER: begin
                    if (boot_counter < 8_000_000) begin
                        // Increment the counter until 80 ms have passed
                        boot_counter <= boot_counter + 1;
                    end else begin
                        state <= READ_DIRECTION_MSB;
                        command[0] <= 8'hAA;
                        command[1] <= 8'h01;
                        command[2] <= 8'h1D;
                        command[3] <= 8'h08;
                        command[4] <= 8'hFF;
                    end
                end
            endcase
        end
        
    end

endmodule

`default_nettype wire