`timescale 1ns / 1ps
`default_nettype none

module uart_imu (
    input wire clk,       // System clock (100 MHz)
    input wire rst,   // Reset signal
    input wire rx,        // UART Receive pin
    output reg tx,         // UART Transmit pin
    output reg[15:0] heading, // heading output
    output reg[7:0] debug_data [4:0]
);

    // Parameters and type definitions
    parameter CLOCK_FREQ = 100_000_000;  // 100 MHz
    parameter BAUD_RATE = 115200;        // 115200 bps
    parameter DATA_BITS = 8;             // 8-bit data
    parameter STOP_BITS = 1;             // 1 stop bit
    parameter PARITY_BIT = 0;            // No parity
    parameter BOOT_TIME = 100_000; // changed 8_000_000 too long 1 ms;     // 80 ms in clock cycles
    parameter BAUD_RATE_DIVISOR = CLOCK_FREQ / BAUD_RATE; // Baud rate divisor

    // main state machine
    typedef enum reg [4:0] {
        BOOT,
        SET_OPR_MODE,
        OPR_MODE_RESPONSE,
        READ_CALI,
        CALI_STATE_RESPONSE,
        READ_DIRECTION_MSB,
        DIRECTION_RESPONSE_MSB,
        READ_DIRECTION_LSB,
        DIRECTION_RESPONSE_LSB
    } state_t;

    // write/read state machine
    typedef enum reg [2:0] {
        IDLE,
        START_BIT,
        BYTE,
        STOP_BIT,
        DONE
    } writeread_state_t;

    state_t current_state;
    writeread_state_t write_state;
    writeread_state_t read_state;

    // General-purpose wait counter and other variables
    reg [22:0] wait_counter;
    reg [7:0] data_to_send[4:0];  // Array to hold the bytes to send
    reg [7:0] received_data[4:0];  // Array to hold the received bytes
    reg [3:0] byte_index;         // Index for the byte to send/recieve
    reg [3:0] bit_index;          // Index for the bit to send/recieve within a byte
    reg [12:0] baud_rate_counter; // Counter for baud rate timing
    reg [15:0] heading_current;
    reg [7:0] debug_data0, debug_data1, debug_data2, debug_data3, debug_data4;

    // Main state machine logic
    always_ff @(posedge clk) begin
        debug_data0 <= debug_data[0];
        debug_data1 <= debug_data[1];
        debug_data2 <= debug_data[2];
        debug_data3 <= debug_data[3];
        debug_data4 <= debug_data[4];
        if (rst) begin
            current_state <= BOOT;
            write_state <= IDLE;
            read_state <= IDLE;
            wait_counter <= 0;
            heading_current = 0;
            heading <= 0;
            debug_data[0][7:0] <= 8'h00;
            debug_data[1][7:0] <= 8'h00;
            debug_data[2][7:0] <= 8'h00;
            debug_data[3][7:0] <= 8'h00;
            debug_data[4][7:0] <= 8'h00;
            tx <= 1;
            // Reset other components if necessary
            data_to_send[0] <= 8'hAA; // start byte
            data_to_send[1] <= 8'h00; // write
            data_to_send[2] <= 8'h3D; // reg_addr for OPR_MODE
            data_to_send[3] <= 8'h01; // length
            data_to_send[4] <= 8'h0C; // Data to be sent which changes OPR_MODE from CONFIG_MODE to NDOF

            received_data[0] <= 8'h00; // start byte
            received_data[1] <= 8'h00; // write
            received_data[2] <= 8'h00; // reg_addr for OPR_MODE
            received_data[3] <= 8'h00; // length
            received_data[4] <= 8'h00; // Data to be sent which changes OPR_MODE from CONFIG_MODE to NDOF
        end
        else begin
            case (current_state)
                BOOT: begin
                    if (wait_counter < BOOT_TIME) begin
                        wait_counter <= wait_counter + 1;
                    end
                    else begin
                        wait_counter <= 0;  // Reset wait_counter for next usage
                        current_state <= SET_OPR_MODE;
                        // Set write command for next state
                        data_to_send[0] <= 8'hAA; // start byte
                        data_to_send[1] <= 8'h00; // write
                        data_to_send[2] <= 8'h3D; // reg_addr for OPR_MODE
                        data_to_send[3] <= 8'h01; // length
                        data_to_send[4] <= 8'h0C; // Data to be sent which changes OPR_MODE from CONFIG_MODE to NDOF
                        
                    end
                end
                SET_OPR_MODE: begin
                    // writing waiting for write state to be DONE
                    debug_data[0] <= data_to_send[0];
                    debug_data[1] <= data_to_send[1];
                    debug_data[2] <= data_to_send[2];
                    debug_data[3] <= data_to_send[3];
                    debug_data[4] <= data_to_send[4];
                    if (write_state == DONE) begin
                        current_state <= OPR_MODE_RESPONSE;
                    end
                end
                OPR_MODE_RESPONSE: begin
                    // reading waiting for read state to be DONE
                    debug_data[0] <= received_data[0];
                    debug_data[1] <= received_data[1];
                    debug_data[2] <= received_data[2];
                    debug_data[3] <= received_data[3];
                    debug_data[4] <= received_data[4];
                    if (read_state == DONE) begin
                        if(received_data[0] == 8'hEE && received_data[1] == 8'h01) begin
                            current_state <= READ_CALI;
                            // Set write command for next state
                            byte_index <= 1;
                            data_to_send[1] <= 8'hAA; // start byte
                            data_to_send[2] <= 8'h01; // read
                            data_to_send[3] <= 8'h35; // reg_addr for CALIB_STAT
                            data_to_send[4] <= 8'h08; // length of data to read = 1 byte
                        end
                        else begin
                            current_state <= SET_OPR_MODE;
                            // Set write command for next state
                            data_to_send[0] <= 8'hAA; // start byte
                            data_to_send[1] <= 8'h00; // write
                            data_to_send[2] <= 8'h3D; // reg_addr for OPR_MODE
                            data_to_send[3] <= 8'h01; // length
                            data_to_send[4] <= 8'h0C; // Data to be sent which changes OPR_MODE from CONFIG_MODE to NDOF
                        end
                    end
                end
                READ_CALI: begin
                    debug_data[0] <= data_to_send[0];
                    debug_data[1] <= data_to_send[1];
                    debug_data[2] <= data_to_send[2];
                    debug_data[3] <= data_to_send[3];
                    debug_data[4] <= data_to_send[4];
                    if (write_state == DONE) begin
                        current_state <= CALI_STATE_RESPONSE;
                    end
                end
                CALI_STATE_RESPONSE: begin
                    debug_data[0] <= received_data[0];
                    debug_data[1] <= received_data[1];
                    debug_data[2] <= received_data[2];
                    debug_data[3] <= received_data[3];
                    debug_data[4] <= received_data[4];
                    if (read_state == DONE) begin
                        if(received_data[0] == 8'hBB && received_data[2][7:6] == 2'b11) begin
                            current_state <= READ_DIRECTION_MSB;
                            // Set write command for next state
                            byte_index <= 1;
                            data_to_send[1] <= 8'hAA; // start byte
                            data_to_send[2] <= 8'h01; // read
                            data_to_send[3] <= 8'h1B; // reg_addr for MSB heading
                            data_to_send[4] <= 8'h08; // length of data to read = 1 byte
                        end
                        else begin
                            current_state <= READ_CALI;
                            // Set write command for next state
                            byte_index <= 1;
                            data_to_send[1] <= 8'hAA; // start byte
                            data_to_send[2] <= 8'h01; // read
                            data_to_send[3] <= 8'h35; // reg_addr for CALIB_STAT
                            data_to_send[4] <= 8'h08; // length of data to read = 1 byte
                        end
                    end
                end
                READ_DIRECTION_MSB: begin
                    debug_data[0] <= data_to_send[0];
                    debug_data[1] <= data_to_send[1];
                    debug_data[2] <= data_to_send[2];
                    debug_data[3] <= data_to_send[3];
                    debug_data[4] <= data_to_send[4];
                    if (write_state == DONE) begin
                        current_state <= DIRECTION_RESPONSE_MSB;
                    end
                end
                DIRECTION_RESPONSE_MSB: begin
                    debug_data[0] <= received_data[0];
                    debug_data[1] <= received_data[1];
                    debug_data[2] <= received_data[2];
                    debug_data[3] <= received_data[3];
                    debug_data[4] <= received_data[4];
                    if (read_state == DONE) begin
                        if(received_data[0] == 8'hBB) begin
                            current_state <= READ_DIRECTION_LSB;
                            // Set write command for next state
                            byte_index <= 1;
                            data_to_send[1] <= 8'hAA; // start byte
                            data_to_send[2] <= 8'h01; // read
                            data_to_send[3] <= 8'h1A; // reg_addr for LSB heading
                            data_to_send[4] <= 8'h08; // length of data to read = 1 byte
                            heading_current[15:8] = received_data[2];
                        end
                        else begin
                            current_state <= READ_DIRECTION_MSB;
                            // Set write command for next state
                            byte_index <= 1;
                            data_to_send[1] <= 8'hAA; // start byte
                            data_to_send[2] <= 8'h01; // read
                            data_to_send[3] <= 8'h1B; // reg_addr for MSB heading
                            data_to_send[4] <= 8'h08; // length of data to read = 1 byte
                        end
                    end
                end
                READ_DIRECTION_LSB: begin
                    debug_data[0] <= data_to_send[0];
                    debug_data[1] <= data_to_send[1];
                    debug_data[2] <= data_to_send[2];
                    debug_data[3] <= data_to_send[3];
                    debug_data[4] <= data_to_send[4];
                    if (write_state == DONE) begin
                        current_state <= DIRECTION_RESPONSE_LSB;
                    end
                end
                DIRECTION_RESPONSE_LSB: begin
                    debug_data[0] <= received_data[0];
                    debug_data[1] <= received_data[1];
                    debug_data[2] <= received_data[2];
                    debug_data[3] <= received_data[3];
                    debug_data[4] <= received_data[4];
                    if (read_state == DONE) begin
                        if(received_data[0] == 8'hBB) begin
                            current_state <= READ_DIRECTION_MSB;
                            // Set write command for next state
                            byte_index <= 1;
                            data_to_send[1] <= 8'hAA; // start byte
                            data_to_send[2] <= 8'h01; // read
                            data_to_send[3] <= 8'h1B; // reg_addr for LSB heading
                            data_to_send[4] <= 8'h08; // length of data to read = 1 byte
                            heading_current[7:0] <= received_data[2];
                            heading <= heading_current;
                        end
                        else begin
                            current_state <= READ_DIRECTION_LSB;
                            // Set write command for next state
                            byte_index <= 1;
                            data_to_send[1] <= 8'hAA; // start byte
                            data_to_send[2] <= 8'h01; // read
                            data_to_send[3] <= 8'h1A; // reg_addr for LSB heading
                            data_to_send[4] <= 8'h08; // length of data to read = 1 byte
                        end
                    end
                end
                // ... other states and transitions
            endcase
        end
    end

    // Sub-state machine logic for writing
    always_ff @(posedge clk) begin
        if (rst) begin
            write_state <= IDLE;
            byte_index <= 0;
            bit_index <= 0;
            baud_rate_counter <= 0;
        end
        else begin
            case (write_state)
                IDLE: begin
                    if (current_state == SET_OPR_MODE || current_state == READ_CALI || current_state == READ_DIRECTION_MSB || current_state == READ_DIRECTION_LSB) begin
                        write_state <= START_BIT;
                    end
                end
                START_BIT: begin
                    tx <= 0;  // Start bit (low)
                    baud_rate_counter <= baud_rate_counter + 1;
                    if (baud_rate_counter == BAUD_RATE_DIVISOR) begin
                        baud_rate_counter <= 0;
                        write_state <= BYTE;
                        bit_index <= 0;
                    end
                end
                BYTE: begin
                    tx <= data_to_send[byte_index][bit_index];
                    baud_rate_counter <= baud_rate_counter + 1;
                    if (baud_rate_counter == BAUD_RATE_DIVISOR) begin
                        baud_rate_counter <= 0;
                        bit_index <= bit_index + 1;
                        if (bit_index == 7) begin
                            write_state <= STOP_BIT;
                        end
                    end
                end
                STOP_BIT: begin
                    tx <= 1;  // Stop bit (high)
                    baud_rate_counter <= baud_rate_counter + 1;
                    if (baud_rate_counter == BAUD_RATE_DIVISOR) begin
                        baud_rate_counter <= 0;
                        byte_index <= byte_index + 1;
                        if (byte_index == 4) begin
                            // All bytes sent, transition to next main state
                            write_state <= DONE; // Replace with actual next state
                        end
                        else begin
                            write_state <= START_BIT;  // Send next byte
                        end
                    end
                end
                DONE: begin
                    // Reset write variables
                    write_state <= IDLE;
                    byte_index <= 0;
                    bit_index <= 0;
                    baud_rate_counter <= 0;
                end
            endcase
        end
    end

    // Read state machine logic
    always_ff @(posedge clk) begin
        if (rst) begin
            read_state <= IDLE;
            byte_index <= 0;
            bit_index <= 0;
            baud_rate_counter <= 0;
            // Reset other components if necessary
        end
        else begin
            case (read_state)
                IDLE: begin
                    if (current_state == OPR_MODE_RESPONSE || current_state == CALI_STATE_RESPONSE || current_state == DIRECTION_RESPONSE_MSB || current_state == DIRECTION_RESPONSE_LSB) begin
                        read_state <= START_BIT;
                        baud_rate_counter <= 0;
                    end
                end
                START_BIT: begin
                    if (rx == 0) begin  // Start bit detected
                        baud_rate_counter <= baud_rate_counter + 1;
                        if (baud_rate_counter == BAUD_RATE_DIVISOR) begin
                            read_state <= BYTE;
                            baud_rate_counter <= 0;
                        end
                    end
                end
                BYTE: begin
                    baud_rate_counter <= baud_rate_counter + 1;
                    if (baud_rate_counter == BAUD_RATE_DIVISOR / 2) begin
                        received_data[byte_index][bit_index] <= rx;
                        bit_index <= bit_index + 1;
                    end else begin
                        if (baud_rate_counter == BAUD_RATE_DIVISOR) begin
                            baud_rate_counter <= 0;
                            if (bit_index == 7) begin
                                read_state <= STOP_BIT; 
                            end
                        end
                    end
                end
                STOP_BIT: begin
                    baud_rate_counter <= baud_rate_counter + 1;
                    if (baud_rate_counter == BAUD_RATE_DIVISOR) begin
                        baud_rate_counter <= 0;
                        byte_index <= byte_index + 1;
                        if (byte_index == 1 && current_state == OPR_MODE_RESPONSE) begin
                            read_state <= DONE;
                        end else if (byte_index == 2) begin
                            read_state <= DONE;
                        end
                        else begin
                            read_state <= START_BIT;
                        end
                    end
                end
                DONE: begin
                    // reset read variables
                    read_state <= IDLE;
                    byte_index <= 0;
                    bit_index <= 0;
                    baud_rate_counter <= 0;
                end
            endcase
        end
    end

endmodule

`default_nettype wire