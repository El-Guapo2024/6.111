
`default_nettype none
`timescale 1ns/1ps

module LiDAR_Protocol(
    input wire clk_in,
    input wire rst_in,
    input wire start_scan,
    input wire [7:0] rx_data,
    input wire rx_valid,
    input wire tx_done,
    output logic [7:0] tx_data,
    output logic tx_start,
    output logic protocol_done_o,
    output logic [31:0] subtype_o ,
    output logic [7:0] type_o,
    output logic [3:0] error_out
    );


// RX Logics 


typedef enum {IDLE = 0, SENDCOMMAND= 1, TOGGLE_START = 2, , WAITFORVALID = 3, SENDCOMMAND2 = 5, TOGGLE_START2 = 5, WAITFORVALID2 = 6 } processing_state ;
processing_state state; //state of system!



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
localparam LIDAR_CMD_RESET = 8'h80 ;
localparam LIDAR_STATUS_OK = 4'h0 ;
localparam LIDAR_STATUS_WARNING = 4'h1 ; 
localparam LIDAR_STATUS_ERROR = 4'h2 ;
localparam LIDAR_CMDFLAG_HAS_PAYLOAD = 8'h80 ;
localparam LIDAR_CMD_SYNC_BYTE = 8'hA5 ;
localparam LIDAR_ANS_TYPE_MEASUREMENT = 8'h81 ;
localparam LIDAR_ANS_SYNC_BYTE1 = 8'hA5 ;
localparam LIDAR_ANS_SYNC_BYTE2 = 8'h5A ;
localparam LIDAR_ANS_TYPE_MEASUREMENT = 8'h81 ;

assign subtype_o = subType_size ;
assign type_o = data_type ;

logic [5:0] time_out = 

logic [7:0] first_byte_received ; 
logic [7:0] second_byte_received; 
logic [3:0] error_out ;
// {31 30 }are sub type , {30, 0} are the size 
logic [3:0] counter_read_bytes ;
logic [31:0] subType_size ; 
logic [7:0] data_type ;

always_ff(@posedge clk_in) begin
  if(rst_in) begin 
    tx_data <= 0 ; 
    tx_start <= 0 ;
    syncByte <= 0 ;
    cmd_flag <= 0 ;
    counter_read_bytes <= 0 ;
    time_out <= 0 ; 
  end else begin 
    case(state) 
      IDLE:
      begin
        protocol_done_o <= 0 ;
        if (start_scan) begin 
          state <= SENDCOMMAND ;
          tx_data <= LIDAR_CMD_SYNC_BYTE ; 
        end else begin 
          tx_start <= 0 ;
        end 
      end 
      SENDCOMMAND:
      begin 
        tx_start <= 1'b1;
        state <= TOGGLE_START ;
      end 
      TOGGLE_START:
      begin 
        tx_start <= 1'b0 ;
      end 
      WAITFORVALID:
      begin
        state <= tx_done ? SENDCOMMAND2 : WAITFORVALID ; 
        tx_data <= tx_done? LIDAR_CMD_SCAN : tx_data ;
      end 
      SENDCOMMAND2:
      begin 
        // send the second byte 
        tx_start <= 1'b1 ; 
      end
      TOGGLE_START2:
      begin 
        // make sure to set to low to prevent sending more bytes
        tx_start <= 1'b0 ;
      end 
      WAITFORVALID2:
      begin
        // once fully sent move to wait response 
        state <= tx_done ? WAITFIRSTBYTE : WAITFORVALID2 ;
      end 
      WAITFIRSTBYTE:
      begin
        // At this point we have sent both bytes we now wait for the response 
        state <= rx_valid? CHECKFIRSTBYTERECEIVED : WAITFIRSTBYTE ; 
        // keep a copy of data 
        first_byte_received_received <= rx_valid ? rx_data : first_byte_received_received ;  
      end 
      CHEKCFIRSTBYTERECEIVED:
      begin 
        state <= first_byte_received_received == LIDAR_ANS_SYNC_BYTE1 ? WAITSECONDBYTE: WAITFIRSTBYTE ;
      end
      WAITSECONDBYTE:
      begin
        state <= rx_valid ? CHECKSECONDBYTERECEIVED : WAITSECONDBYTE ; 
        second_byte_received <= rx_valid ? rx_data : second_byte_received ;
      end  
      CHECKSECONDBYTERECEIVED:
      begin 
        time_out <= time_out + 1 ;
        if(time_out == 64 )begin 
          state <= ERRORSTATE ; 
          error_out <= 4'b0001 ; 
        end 
        state <= second_byte_received == LIDAR_ANS_SYNC_BYTE2 ? READBYTES : WAITFIRSTBYTE;
      end 
      READBYTES:
      begin 
        if(rx_valid) begin
          if(counter_read_bytes == 0 ) begin 
            subType_size [7:0] <= rx_data ;
          end else if(counter_read_bytes == 1 ) begin
            subType_size [15:7] <= rx_data ;
          end else if(counter_read_bytes == 2) begin
            subType_size [23:16] <= rx_data ;
          end else if(counter_read_bytes == 3 ) begin
            subType_size [31:24] <= rx_data ; 
          end  else if (counter_read_bytes == 4 ) begin
            data_type <= rx_data ; 
            counter_read_bytes <= 0 ;
            state <= FINISH ; 
          end 
          counter_read_bytes <= counter_read_bytes + 1 ;
        end 
      end 
    FINISH:
    begin 
      protocol_done_o <= 1 ;
      error_out <= 0 ;
      state <= IDLE; 
    end 
    ERRORSTATE:
      protocol_done_o <= 0 ; 
      state <= IDLE ;
    endcase
  end 
end 

endmodule
`default_nettype wire