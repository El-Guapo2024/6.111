`timescale 1ns / 1ps
`default_nettype none

module uart_arduino(
    input wire clk,
    input wire rst,
    input wire rx,
    output reg tx,
    output reg[15:0] heading,
    output reg[15:0] distance,
    output reg [1:0] state_debug,
    output reg [47:0] rx_debug,
    output reg rx_valid_o
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
    typedef enum reg [1:0] {
        BOOT,
        DATA_HANDLING
    } state_t;

    // State machine for controlling the UART communication
    state_t state = BOOT;
    reg [7:0] command [1:0]; // Command sequence
    reg [3:0] command_index = 0;
    reg [7:0] response [5:0];
    reg [3:0] response_index = 0;

    always_ff @(posedge clk) begin
        if (rst) begin
            // Reset logic
            state <= BOOT;
            command_index <= 0;
            response_index <= 0;
            tx_data <= 0;
            tx_start <= 0;
            heading <= 0;
            distance <= 30;
            state_debug <= 0;
            command[0] <= 8'hAA;
            command[1] <= 8'h00;
            response[0] <= 8'h00;
            response[1] <= 8'h00;
            response[2] <= 8'h00;
            response[3] <= 8'h00;
            response[4] <= 8'h00;
            response[5] <= 8'h00;
            rx_debug <= 0;
            rx_valid_o <= 0;
        end else begin
            state_debug <= state;
            if (rx_valid) rx_valid_o <= rx_valid;
            // State machine logic
            case (state)
                //0
                BOOT: begin
                    if (rx_valid) begin
                        response[response_index] <= rx_data;
                        if (response_index == 5) begin // Check after receiving 6 bytes
                            if (response[0] == 8'hAA && response[1] == 8'hBB) begin
                                // Correct response received, ready to read data, move to handling data in future transmitions
                                state <= DATA_HANDLING;
                            end else begin
                                // Incorrect response, continue waiting for sensors set
                                state <= BOOT;
                            end
                            response_index <= 0;
                            response[0] <= 8'h00;
                            response[1] <= 8'h00;
                            response[2] <= 8'h00;
                            response[3] <= 8'h00;
                            response[4] <= 8'h00;
                            response[5] <= 8'h00;
                            rx_debug <= {response[0], response[1], response[2], response[3], response[4], rx_data};
                        end else begin
                            response_index <= response_index + 1;
                        end
                    end
                end
                //1
                DATA_HANDLING: begin
                    if (rx_valid) begin
                        response[response_index] <= rx_data;
                        response_index <= response_index + 1;
                        if (response_index == 5) begin // Check after receiving 6 bytes
                            if (response[0] == 8'hAA && response[1] == 8'hBB) begin
                                // Handle all data
                                state <= DATA_HANDLING;
                                heading <= {response[2], response[3]};
                                distance <= {response[4], rx_data};
                            end else begin
                                // Incorrect response, skip transmition
                                state <= DATA_HANDLING;
                            end
                            response_index <= 0;
                            response[0] <= 8'h00;
                            response[1] <= 8'h00;
                            response[2] <= 8'h00;
                            response[3] <= 8'h00;
                            response[4] <= 8'h00;
                            response[5] <= 8'h00;
                            rx_debug <= {response[0], response[1], response[2], response[3], response[4], rx_data};
                        end
                    end
                end
            endcase
        end
    end

endmodule

`default_nettype wire