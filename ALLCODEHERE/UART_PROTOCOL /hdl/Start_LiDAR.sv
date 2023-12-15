`timescale 1ns / 1ps
`default_nettype none


module Start_LiDAR(
    input wire clk_in,
    input wire rst_in,
    input wire start_scan_in,
    input wire [7:0] rx_data_in,
    input wire rx_valid_in,
    input wire tx_done_in,
    output logic [7:0] tx_data_out,
    output logic tx_start_out,
    output logic protocol_done_out,
    output logic [2:0] error_out,
    output logic [31:0] subtype_out,
    output logic [7:0] type_out
    );


/*
#define LIDAR_CMD_STOP                      0x65
#define LIDAR_CMD_SCAN                      0x60
#define LIDAR_STATUS_OK                    0x0
#define LIDAR_STATUS_WARNING               0x1
#define LIDAR_STATUS_ERROR                 0x2
#define LIDAR_CMDFLAG_HAS_PAYLOAD           0x8000
#define LIDAR_CMD_SYNC_BYTE                 0xA5
#define LIDAR_ANS_TYPE_MEASUREMENT          0x81
#define LIDAR_ANS_SYNC_BYTE1                0xA5
#define LIDAR_ANS_SYNC_BYTE2                0x5A
#define LIDAR_ANS_TYPE_MEASUREMENT          0x81
*/
localparam LIDAR_CMD_STOP = 8'h65 ;
localparam LIDAR_CMD_SCAN = 8'h60 ;
localparam LIDAR_CMD_FORCE_SCAN = 8'h61 ; 
localparam LIDAR_CMD_RESET = 8'h80 ;
localparam LIDAR_STATUS_OK = 4'h0 ;
localparam LIDAR_STATUS_WARNING = 4'h1 ; 
localparam LIDAR_STATUS_ERROR = 4'h2 ;
localparam LIDAR_CMDFLAG_HAS_PAYLOAD = 8'h80 ;
localparam LIDAR_CMD_SYNC_BYTE = 8'hA5 ;
localparam LIDAR_ANS_TYPE_MEASUREMENT = 8'h81 ;
localparam LIDAR_ANS_SYNC_BYTE1 = 8'hA5 ;
localparam LIDAR_ANS_SYNC_BYTE2 = 8'h5A ;


assign subtype_out = subType_size ;
assign type_out = data_type ;

logic [7:0] first_byte_received ; 
logic [7:0] second_byte_received; 
// {31 30 }are sub type , {30, 0} are the size 
logic [3:0] counter_read_bytes ;
logic [31:0] subType_size ; 
logic [7:0] data_type ;


typedef enum {IDLE1, SENDCOMMAND, TOGGLE_START , WAITFORVALID , SENDCOMMAND2 , TOGGLE_START2 , WAITFORVALID2 , WAITFIRSTBYTE , CHECKFIRSTBYTERECEIVED , WAITSECONDBYTE , CHECKSECONDBYTERECEIVED , READBYTES , FINISH } starting_state ;
starting_state start_state; //state of system!

always_ff @(posedge clk_in) begin
  if(rst_in) begin 
    tx_data_out <= 0 ; 
    tx_start_out <= 0 ;
    counter_read_bytes <= 0 ;
    start_state <= IDLE1 ;
  end else begin 
    case(start_state) 
      IDLE1:
      begin
        error_out <= 1'b000 ; 
        protocol_done_out <= 0 ;
        if (start_scan_in) begin 
          start_state <= SENDCOMMAND ;
          tx_data_out <= LIDAR_CMD_SYNC_BYTE ; 
        end else begin 
          tx_start_out <= 0 ;
        end 
      end 
      SENDCOMMAND:
      begin 
        error_out <= 3'b001 ; 
        tx_start_out <= 1'b1;
        start_state <= WAITFORVALID ;
      end 
      WAITFORVALID:
      begin
        if(tx_done_in) begin 
          tx_start_out <= 1'b0 ;
          start_state <= SENDCOMMAND2 ; 
          tx_data_out <= LIDAR_CMD_FORCE_SCAN ;
        end 
      end 
      SENDCOMMAND2:
      begin 
        error_out <= 3'b010 ; 
        // send the second byte 
        tx_start_out <= 1'b1 ; 
        start_state <= TOGGLE_START2 ;
      end
      TOGGLE_START2:
      begin 
        // make sure to set to low to prevent sending more bytes
        tx_start_out <= 1'b0 ;
        start_state <= WAITFORVALID2 ;
      end 
      WAITFORVALID2:
      begin
        // once fully sent move to wait response 
        if(tx_done_in) begin 
          error_out <= 3'b011 ;
          tx_start_out <= 0 ; 
          start_state <= WAITFIRSTBYTE ; 
        end 
      end 
      WAITFIRSTBYTE:
      begin
        // At this point we have sent both bytes we now wait for the response 
        start_state <= rx_valid_in ? CHECKFIRSTBYTERECEIVED : WAITFIRSTBYTE ; 
        // keep a copy of data 
        first_byte_received <= rx_valid_in ? rx_data_in : 8'hFF ;  
      end 
      CHECKFIRSTBYTERECEIVED:
      begin 
        error_out <= 3'b011 ;   
        start_state <= ( first_byte_received == LIDAR_ANS_SYNC_BYTE1 )? WAITSECONDBYTE: WAITFIRSTBYTE ;
      end
      WAITSECONDBYTE:
      begin
        start_state <= rx_valid_in ? CHECKSECONDBYTERECEIVED : WAITSECONDBYTE ; 
        second_byte_received <= rx_valid_in ? rx_data_in : 8'hFF ;
      end  
      CHECKSECONDBYTERECEIVED:
      begin 
        error_out <= 3'b101 ; 
        start_state <= (second_byte_received == LIDAR_ANS_SYNC_BYTE2) ? READBYTES : WAITFIRSTBYTE;
      end 
      READBYTES:
      begin 
        error_out <= 3'b110 ; 
        if(rx_valid_in) begin
          if(counter_read_bytes == 0 ) begin 
            subType_size [7:0] <= rx_data_in ;
          end else if(counter_read_bytes == 1 ) begin
            subType_size [15:7] <= rx_data_in ;
          end else if(counter_read_bytes == 2) begin
            subType_size [23:16] <= rx_data_in ;
          end else if(counter_read_bytes == 3 ) begin
            subType_size [31:24] <= rx_data_in ; 
          end  else if (counter_read_bytes == 4 ) begin
            data_type <= rx_data_in ; 
            counter_read_bytes <= 0 ;
            start_state <= FINISH ; 
          end 
          counter_read_bytes <= counter_read_bytes + 1 ;
        end 
      end 
    FINISH:
    begin 
      protocol_done_out <= 1 ;
      start_state <= IDLE1 ; 
    end 
    endcase
  end 
end 

endmodule
`default_nettype wire