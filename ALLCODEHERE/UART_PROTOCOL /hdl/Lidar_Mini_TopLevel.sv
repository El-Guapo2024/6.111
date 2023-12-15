`timescale 1ns / 1ps
`default_nettype none

module Lidar_Mini_TopLevel(
    input wire clk_in,
    input wire rst_in,
    input wire rx_in,
    input wire run_protocol_in ,
    output logic tx_out,
    output logic new_data_out,
    output logic [2:0] state_out,
    output logic [2:0] LiDAR_Start_out, 
    output logic [31:0] angle_distance_out
    );

// Use LED to Test out the output how far it gets on the state
// This is the UART for the LiDAR
// pmoda[0] will be TX pmodb[0] will be RX
logic [7:0] data_going_to_lidar;
logic send_data_to_lidar;
logic data_has_been_sent_to_lidar;

uart_tx #(.CLOCKS_PER_BAUD(781)) myTXLiDAR (
    .clk(clk_in),
    .data_i(data_going_to_lidar),
    .start_i(send_data_to_lidar),
    .done_o(data_has_been_sent_to_lidar),
    .tx(tx_out));
 
logic [7:0] data_from_lidar_received;
logic data_has_been_received_from_lidar;

uart_rx #(.CLOCKS_PER_BAUD(781)) myRXLiDAR (
    .clk(clk_in),
    .rx(rx_in),
    .data_o(data_from_lidar_received),
    .valid_o(data_has_been_received_from_lidar));

// Protocol to turn on the lidar 

logic start_Lidar ;
logic successfully_started ;
logic [31:0] subtype_o ;
logic [7:0] type_o ;


Start_LiDAR myStartLiDAR(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .start_scan_in(start_Lidar),
    .rx_data_in(data_from_lidar_received),
    .rx_valid_in(data_has_been_received_from_lidar),
    .tx_done_in(data_has_been_sent_to_lidar),
    .tx_data_out(data_going_to_lidar),
    .tx_start_out(send_data_to_lidar),
    .protocol_done_out(successfully_started),
    .subtype_out(subtype_o) ,
    .error_out(LiDAR_Start_out),
    .type_out(type_o)
    );



//Make a 1khz signal 
 // need to scale signal by 100000 to reach to 1 khz  
  localparam NUM_SAMPLES = 100000;
  logic valid_in ;
  logic [16:0] counter ; 
  always_ff @(posedge clk_in)begin   
    counter <= (counter ==NUM_SAMPLES)?0:counter+1;             
    valid_in  <= (counter==NUM_SAMPLES)?1:0;
  end

// Protocol to make the Lidar work 
logic EnableProtocol ; 
logic New_Scan_Dot_Received ;
logic [15:0] New_Angle_Out ; 
logic [15:0] New_Distance_Out ; 
LiDAR_Protocol myLiDAR_Protocol(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .read_bytesison_i(valid_in&&EnableProtocol),
    .rx_data(data_from_lidar_received),
    .rx_valid(data_has_been_received_from_lidar),
    .new_data_out(New_Scan_Dot_Received), 
    .angle_out(New_Angle_Out),
    .distance_out(New_Distance_Out)
    );

typedef enum {IDLE2,START_PROTOCOL, SCAN_DOTS} processing_state ;
processing_state bigstate; //state of system!

  always_ff @(posedge clk_in)begin
    if (rst_in)begin
      new_data_out <=  0 ;
      angle_distance_out <= 0 ;
      bigstate <= IDLE2 ;
    end else begin
    case(bigstate)
      IDLE2:
      begin 
        new_data_out <= 0 ;
        angle_distance_out <= 0 ;
        EnableProtocol <= 1'b0 ; 
        state_out <= 3'b001 ;
        if(run_protocol_in == 1'b1) begin
          bigstate <= START_PROTOCOL ;
          start_Lidar <= 1'b1 ;
          EnableProtocol <= 1'b1 ;
        end
      end 
      START_PROTOCOL:
      begin
        state_out <= 3'b010 ;
        if(run_protocol_in == 1'b0) begin
          bigstate <= IDLE2 ;
        end else if (successfully_started == 1'b1) begin
          bigstate <= SCAN_DOTS ;
          EnableProtocol <= 0 ;
        end
      end
      SCAN_DOTS:
      begin 
        bigstate <= (run_protocol_in == 1'b0)? IDLE2: SCAN_DOTS ;
        state_out <= 3'b100 ;
      end 
    endcase
    end
  end
  
endmodule

`default_nettype wire