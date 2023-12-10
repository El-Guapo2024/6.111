//logic [7:0] urx_brx_data;
//logic urx_brx_valid;

//logic [7:0] btx_utx_data;
//logic btx_utx_start;
//logic utx_btx_done;

`default_nettype none
`timescale 1ns/1ps

module LiDAR_Protocol(
    input wire clk_in,
    input wire rst_in,
    input wire read_bytesison_i,
    input wire [7:0] rx_data,
    input wire rx_valid,
    input wire tx_done,
    output logic new_data, 
    output logic [15:0] angle,
    output logic [15:0] distance,
    output logic [7:0] tx_data,
    output logic tx_start 
    );

// Constants 
/*
// Reference C code 
#define PackagePaidBytes 10
#define PH 0x55AA
#define PH1 0xAA
#define PH2 0x55
typedef enum {
  CT_Normal = 0,
  CT_RingStart  = 1,
  CT_Tail,
} CT;
#define LIDAR_RESP_MEASUREMENT_CHECKBIT       (0x1<<0)
#define LIDAR_RESP_MEASUREMENT_ANGLE_SHIFT    1
#define LIDAR_RESP_MEASUREMENT_ANGLE_SAMPLE_SHIFT    8
#define PackagePaidBytes 10
*/
/*
      "ports": {
        "aclk": [ { "direction": "in", "driver_value": "0x1" } ],
        "s_axis_cartesian_tvalid": [ { "direction": "in", "driver_value": "0x0" } ],
        "s_axis_cartesian_tready": [ { "direction": "out", "driver_value": "0x0" } ],
        "s_axis_cartesian_tdata": [ { "direction": "in", "size_left": "31", "size_right": "0", "driver_value": "0" } ],
        "m_axis_dout_tvalid": [ { "direction": "out", "driver_value": "0x0" } ],
        "m_axis_dout_tdata": [ { "direction": "out", "size_left": "15", "size_right": "0", "driver_value": "0" } ]
      }
*/

logic cartesian_tready;
logic [31:0] arctan_input; 
logic  arctan_valid_input ;
logic arctan_valid_output ;
logic [15:0] arctan_output ; 

arctan myarctan(
  .aclk(clk_in),
  .s_axis_cartesian_tvalid(arctan_valid_input),
  .s_axis_cartesian_tready(cartesian_tready),
  .s_axis_cartesian_tdata(arctan_input),
  .m_axis_dout_tvalid(arctan_valid_output),
  .m_axis_dout_tdata(arctan_output)
);


logic [31:0] dividend ;
logic [31:0] divisor ;
logic valid_division ; 
logic [31:0] quotient ;
logic [31:0] remainder ; 
logic data_valid_out ;
logic error_out ;
logic busy_out ;

divider #(parameter WIDTH = 32 ) mydividerx (
  .clk_in(clk_in),
  .rst_in(rst_in),
  .dividend_in(dividend),
  .divisor_in(divisor),
  .data_valid_in(valid_division),
  .quotient_out(quotient),
  .remainder_out(remainder),
  .data_valid_out(data_valid_out),
  .error_out(error_out),
  .busy_out(busy_out));

localparam PH = 16'h55AA ;
localparam PH1 = 8'hAA ; 
localparam PH2 = 8'h55 ; 
localparam PackagePaidBytes = 10 ;



typedef enum {IDLE,} processing_state ;
processing_state state; //state of system!

logic [15:0] FirstSampleAngle ; 
logic [15:0] LastSampleAngle ;
logic [15:0] CheckSum ;
logic [15:0] CheckSumCal ;
logic [15:0] SampleNumlAndCTCal ;
logic [15:0] LastSampleAngleCal ;
logic [15:0] package_Sample_Num ;
logic [15:0] package_Sample_Sum ; 
logic [15:0] package_Sample_Index ; 
logic [15:0] package_CT ;
logic [31:0] AngleCorrectForDistance ;
logic [15:0] IntervalSampleAngle ; 
logic [15:0] IntervalSampleAnglePrev ;
logic [7:0] currentByte ;
logic [4:0] counter_read_bytes ;
logic CheckSumResult ;
logic [31:0] sample_angle ;
logic [15:0] bytes_read [30:0] ; 

logic [31:0] temporary_variable:

always_ff(@posedge clk_in) begin
  if(rst_in) begin 
    tx_data <= 0 ; 
    tx_start <= 0 ;
    timeout <= 0 ; 
    currentByte <= 0 ; 
  end else begin 
    case(state):
    IDLE:
    begin 
      new_data <= 0 ;
      if (read_bytesison_i)begin
        if(package_Sample_Index == 0 ) begin 
          state <= READ_FIRST_BYTE;
        end else begin 
          if (package_Sample_Index >= package_Sample_Num) begin
            package_Sample_Index <= 0 ; 
          end else begin 
            state <=  PROCESS_ALL_DATA ;
          end 
        end 
      end
    end 
    READ_FIRST_BYTE
    begin
      if (rx_valid) begin 
        currentByte <= rx_data ;
        state <= PROCESS_FIRST_BYTE;
      end 
    end 
    PROCESS_FIRST_BYTE:
    begin
      if(currentByte == PH1 )begin
        state <= READ_SECOND_BYTE ;
      end else begin 
        state <= READ_FIRST_BYTE
      end
    end
    READ_SECOND_BYTE :
    begin 
      if (rx_valid) begin 
        currentByte <= rx_data ;
        state <= PROCESS_SECOND_BYTE;
      end 
    end
    PROCESS_SECOND_BYTE :
    begin
      CheckSumCal <= PH ;
      if(currentByte == PH2) begin
        state <= READ_THIRD_BYTE
      end else begin
        // could add more logic to check time stamp
         state <= READ_FIRST_BYTE ;
      end 
    end
    READ_THIRD_BYTE:
    begin 
      if (rx_valid) begin 
        currentByte <= rx_data ;
        state <= PROCESS_THIRD_BYTE;
      end 
    end
    PROCESS_THIRD_BYTE :
    begin
      SampleNumlAndCTCal[7:0] = currentByte;
      state <= READ_FOURTH_BYTE ;
      package_CT <= currentByte ;
    end
    READ_FOURTH_BYTE :
    begin 
      if (rx_valid) begin 
        currentByte <= rx_data ;
        state <= PROCESS_FOURTH_BYTE ;
      end 
    end
    PROCESS_FOURTH_BYTE:
    begin 
      SampleNumlAndCTCal[15:8] <= SampleNumlAndCTCal[15:8]+currentByte ;  
      package_Sample_Num <= currentByte ;
    end
    READ_FIFTH_BYTE:
    begin
      if (rx_valid) begin 
        currentByte <= rx_data ;
        state <= PROCESS_FIFTH_BYTE ;
      end 
    end 
    PROCESS_FIFTH_BYTE:
    begin
      if(currentByte[0] == 1) begin 
        FirstSampleAngle[7:0] = currentByte ;
        state <= READ_SIXTH_BYTE ;
      end else begin
        state <= IDLE
      end
    end
    READ_SIXTH_BYTE:
    begin 
      if (rx_valid) begin 
        currentByte <= rx_data ;
        state <= PROCESS_SIXTH_BYTE_1;
      end 
    end 
    PROCESS_SIXTH_BYTE_1:
    begin 
      FirstSampleAngle[15:8] <= FirstSampleAngle[15:8]+currentByte;
      state <= PROCESS_SIXTH_BYTE_2 ;
    end
    PROCESS_SIXTH_BYTE_2:
    begin
      CheckSumCal <= CheckSumCal^ FirstSampleAngle ;
      FirstSampleAngle <= FirstSampleAngle >> 1 ;
      state <= READ_SEVENTH_BYTE ;
    end 
    READ_SEVENTH_BYTE:
    begin
      if (rx_valid) begin 
        currentByte <= rx_data ;
        state <= PROCESS_SEVENTH_BYTE;
      end 
    end
    PROCESS_SEVENTH_BYTE:
    begin
      if(currentByte[0]==1) begin
        LastSampleAngle[7:0] <= currentByte;
        state <= READ_EIGHT_BYTE;
      end else begin
        state <= READ_FIRST_BYTE ;
      end
    end
    READ_EIGHT_BYTE:
    begin
      if (rx_valid) begin 
        currentByte <= rx_data ;
        state <= PROCESS_EIGHT_BYTE_STEP_1;
      end 
    end
    PROCESS_EIGHT_BYTE_STEP_1:
    begin
      LastSampleAngle[15:8] <= LastSampleAngle[15:8]+currentByte;
      state <= PROCESS_EIGHT_BYTE_STEP_2;
    end
    PROCESS_EIGHT_BYTE_STEP_2:
    begin 
      LastSampleAngleCal <= LastSampleAngle ;
      LastSampleAngle <= LastSampleAngle >>1 ; 
      state <= PROCESS_EIGHT_BYTE_STEP_3 ;
    end
    PROCESS_EIGHT_BYTE_STEP_3:
    begin
      if(package_Sample_Num == 1) begin
        IntervalSampleAngle <= 0 ;
        state <= READ_NINTH_BYTE:
      end else begin
        if(LastSampleAngle < FirstSampleAngle)begin
          if((FirstSampleAngle >17280) && (LastSampleAngle < 5706)) begin
            // Redo using division module 
            dividend <= (23040 + LastSampleAngle - FirstSampleAngle);
            divisor <= (package_Sample_Num-1);
            valid_division <= 1 ;
            //IntervalSampleAnglePrev <= (23040 + LastSampleAngle - FirstSampleAngle)/(package_Sample_Num-1);
            state <= PROCESS_EIGHT_BYTE_STEP_4 ;
          end else begin
            IntervalSampleAngle <= IntervalSampleAnglePrev ;
            state <= READ_NINTH_BYTE ;
          end
        end else begin
            divisor <= ( LastSampleAngle - FirstSampleAngle) ;
            dividend <= (package_Sample_Num-1) ;
            valid_division <= 1 ; 
            state <= PROCESS_EIGHT_BYTE_STEP_4:
        end
      end

    end
    PROCESS_EIGHT_BYTE_STEP_4:
    begin
      if(data_valid_out) begin 
        data_valid_in <= 0 ; 
        IntervalSampleAngle <= quotient[15:0] ;
        IntervalSampleAnglePrev <= quotient[15:0] ;
        state <= READ_NINTH_BYTE ;
        temporary_variable <= 0 ; 
      end 
    end 
    READ_NINTH_BYTE:
    begin
      if (rx_valid) begin 
        currentByte <= rx_data ;
        state <= PROCESS_NINTH_BYTE;
      end 
    end
    PROCESS_NINTH_BYTE:
    begin
      CheckSum [7:0] <= currentByte ;
      state <= READ_TENTH_BYTE ; 
    end
    READ_TENTH_BYTE:
    begin
      if (rx_valid) begin 
        currentByte <= rx_data ;
        state <= PROCESS_TENTH_BYTE;
      end 
    end
    PROCESS_TENTH_BYTE:
    begin
      CheckSum[15:8] <= currentByte ;
      state <= BEGIN_NEXT_PHASE ; 
    end
    BEGIN_NEXT_PHASE:
    begin
      package_Sample_Sum <= package_Sample_Num << 1 ;
      state <= READ_LOOP_BYTES ;
    end 
    READ_LOOP_BYTES:
    begin 
      if (counter_read_bytes == package_Sample_Sum) begin
        counter_read_bytes <= 0 ; 
        state <= FINISHED_LOOP ;
      end else begin 
        state <= READ_LOOP_BYTES ;
      end 
    end 
    READ_LOOP_BYTE:
    begin
      if (rx_valid) begin 
        if( counter_read_bytes[0] == 0 )begin 
          bytes_read[counter_read_bytes][7:0] <= rx_data; // fix this 
        end else begin 
          bytes_read[counter_read_bytes][15:8] <=  rx_data; // double check this line 
        end 
 
        state <= READ_LOOP_BYTES ;
        counter_read_bytes <= counter_read_bytes + 1 ;
      end 
    end
    FINISHED_LOOP:
    begin 
      CheckSumCal <= CheckSumCal ^ SampleNumlAndCTCal ;
      state <= FINISHED_LOOP_PART_2 ;
    end 
    FINISHED_LOOP_PART_2:
    begin
      CheckSumCal <= CheckSumCal ^ LastSampleAngleCal ;
      state <= FINISHED_LOOP_PART_3 ;
    end
    FINISHED_LOOP_PART_3:
    begin
      CheckSumResult <= (CheckSumCal == CheckSum )? 1 : 0 ;
      state <= PROCESS_ALL_DATA ;
    end
    PROCESS_ALL_DATA:
    begin 
      if (CheckSumResult == 1 ) begin 
        distance <= bytes_read[package_Sample_Index][14:0] ;
        state <= PROCESS_ALL_DATA_PART_2 ;
        //    AngleCorrectForDistance = (int32_t)((atan(((21.8 * (155.3 - (node.distance))) /
        // 155.3) / (node.distance))) * 3666.93);
      end else begin 
        state <= ERROR_STATE ; 
      end 
    end
    PROCESS_ALL_DATA_PART_2:
    begin 
      if(distance == 0) begin
        AngleCorrectForDistance <= 0 ;
        state <= PROCESS_ALL_DATA_PART_7 ;
      end else begin 
        dividend <= 21.8*(155-distance) ;
        divisor <= 155 ;
        valid_division <= 1 ;
        state <= PROCESS_ALL_DATA_PART_3 ;
      end 
    end
    PROCESS_ALL_DATA_PART_3:
    begin 
      if (data_valid_out) begin 
        valid_division <= 0 ;
        arctan_input <= quotient ;
        arctan_valid_input <= 1 ;
        state <= PROCESS_ALL_DATA_PART_4 ;
      end 
    end
    PROCESS_ALL_DATA_PART_5:
    begin
      if (arctan_valid_output) begin
        arctan_valid_input <= 0 ;
        dividend <= arctan_output ;
        divisor <= distance ;
        valid_division <= 1 ;
      end 
    end 
    PROCESS_ALL_DATA_PART_6:
    begin 
      if(data_valid_out) begin
        AngleCorrectForDistance <= quotient * 3666 ; 
        data_valid_in <= 0 ;
        state <= PROCESS_ALL_DATA_PART_7 ;
      end 
    end 
    PROCESS_ALL_DATA_PART_7:
    begin 
      sample_angle <= IntervalSampleAngle*package_Sample_Index ; 
      stata <= PROCESS_ALL_DATA_PART_8;
    end 
    PROCESS_ALL_DATA_PART_8:
    begin
      temporary_variable <= FirstSampleAngle + sample_angle + AngleCorrectForDistance ; 
      state <= PROCESS_ALL_DATA_PART_9;
    end 
    PROCESS_ALL_DATA_PART_9: 
    begin 
      if(temporary_variable < )
    end 
    ERROR_STATE:
    begin
      temporary_variable <=0 
      angle <= 0 ;
      distance <= 0 ;
      new_data <= 1 ; 
      state <= IDLE ;
    end 
    endcase 
  end 
end 

endmodule
`default_nettype wire