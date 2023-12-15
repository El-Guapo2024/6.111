`timescale 1ns/1ps
`default_nettype none


module LiDAR_Protocol(
    input wire clk_in,
    input wire rst_in,
    input wire read_bytesison_i,
    input wire [7:0] rx_data,
    input wire rx_valid,
    output logic new_data_out, 
    output logic [15:0] angle_out,
    output logic [15:0] distance_out
    );

// Local Params for byte processing 
localparam PH = 16'h55AA ;
localparam PH1 = 8'hAA ; 
localparam PH2 = 8'h55 ; 
localparam PackagePaidBytes = 10 ;

// Logic for byte processing 
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
logic [15:0] IntervalSampleAngle ; 
logic [15:0] IntervalSampleAnglePrev ;
logic [7:0] currentByte ;
logic [4:0] counter_read_bytes ;
logic CheckSumResult ;
logic [15:0] CurrentDistance ;
logic Find_CorrectAngle ;

// Making a queue of 20  in theory should never be larger than 10 
logic pop ;
logic push ;
logic [7:0] queue_input_data ;
logic [7:0] queue [31:0] ;
logic [4:0] queue_pointer ;
logic [4:0] rear ;
logic [4:0] next_rear ; 

logic Find_IntervalAngle ;
logic Found_IntervalAngle ;
logic busy_out ; 
logic error_out ;
// Find_Interval Angle Module 
Find_IntervalSampleAngle myIntervalAngle (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .FirstSampleAngle(FirstSampleAngle),
    .LastSampleAngle(LastSampleAngle),
    .package_Sample_Num(package_Sample_Num),
    .data_valid_in(Find_IntervalAngle),
    .IntervalSampleAngle(IntervalSampleAngle),
    .data_valid_out(Found_IntervalAngle),
    .busy_out(busy_out),
    .error_out(error_out)
    );



Find_CorrectedAngles  myAngleCorrector(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .FirstSampleAngle(FirstSampleAngle),
    .IntervalSampleAngle(IntervalSampleAngle), 
    .package_Sample_Index(package_Sample_Index),
    .distance(CurrentDistance),
    .data_valid_in(Find_CorrectAngle),
    .angle_out(angle_out),
    .distance_out(distance_out), 
    .data_valid_out(new_data_out)
    );

always_comb begin
  next_rear = (rear + 1) % 32;
  queue_input_data = rx_data ;
  push = rx_valid ;
  currentByte = queue[queue_pointer] ;
end

always_ff@(posedge clk_in) begin
  if(rst_in) begin 
    queue_pointer <= 0 ;
  end else begin 
    if((push== 1'b1 ) && ( rear != next_rear)) begin 
      queue_pointer[rear] <= queue_input_data ;
      rear <= next_rear ; 
    end else if((pop == 1'b1) && (queue_pointer != rear)) begin 
      pop <= 0 ;
      queue_pointer <= queue_pointer + 1 ;
    end 
  end 
end 

always_ff @(posedge clk_in) begin
  if(Found_IntervalAngle) begin 
    Find_IntervalAngle <= 1'b0;
  end 
end 

always_ff@(posedge clk_in) begin
  if(new_data_out) begin 
    Find_CorrectAngle <= 1'b0;
  end 
end 

typedef enum {IDLE, READ_FIRST_BYTE, READ_SECOND_BYTE, READ_THIRD_BYTE, READ_FOURTH_BYTE, READ_FIFTH_BYTE, READ_SIXTH_BYTE, PROCESS_SIXTH_BYTE, READ_SEVENTH_BYTE, READ_EIGHT_BYTE, PROCESS_EIGHT_BYTE, READ_NINTH_BYTE, READ_TENTH_BYTE, READ_DISTANCES, READ_ONE_DISTANCE_BYTE,FINISHED_LOOP, FINISHED_LOOP_PART_2, FINISHED_LOOP_PART_3, PROCESS_ALL_DATA, ERROR_STATE} processing_state ;
processing_state state; //state of system!

always_ff@(posedge clk_in) begin
  if(rst_in) begin 
    currentByte <= 0 ; 
    state <= IDLE ;
  end else begin 
    case(state)
    IDLE:
    begin 
      if (read_bytesison_i)begin
        if(package_Sample_Index == 0 ) begin 
          state <= READ_FIRST_BYTE;
          pop <= 1 ; // this will update currentByte with a new byte
        end else begin 
          if (package_Sample_Index >= package_Sample_Num) begin
            package_Sample_Index <= 0 ; 
          end else begin 
            state <=  PROCESS_ALL_DATA ;
          end 
        end 
      end
    end 
    READ_FIRST_BYTE:
    begin
      if (pop == 1'b0) begin 
        if(currentByte == PH1 )begin
          state <= READ_SECOND_BYTE ;
        end else begin 
          state <= READ_FIRST_BYTE ;
        end
        pop <= 1 ; 
      end 
    end 

    READ_SECOND_BYTE :
    begin 
      if (pop == 1'b0) begin 
      CheckSumCal <= PH ;
      pop <= 1 ;
      if(currentByte == PH2) begin
        state <= READ_THIRD_BYTE ;
      end else begin
        // could add more logic to check time stamp
         state <= READ_FIRST_BYTE ;
      end 
      end 
    end
    READ_THIRD_BYTE:
    begin 
      if (pop == 1'b0) begin 
        pop <= 1'b1 ; 
        SampleNumlAndCTCal[7:0] = currentByte;
        state <= READ_FOURTH_BYTE ;
        package_CT <= currentByte ;
      end 
    end
    READ_FOURTH_BYTE :
    begin 
      if (pop == 1'b0 ) begin 
      SampleNumlAndCTCal[15:8] <= SampleNumlAndCTCal[15:8]+currentByte ;  
      package_Sample_Num <= currentByte ;
      pop <= 1'b1 ;
      state <= READ_FIFTH_BYTE ;
      end 
    end
    READ_FIFTH_BYTE:
    begin
    if (pop == 1'b0 ) begin 
      if(currentByte[0] == 1) begin 
        FirstSampleAngle[7:0] = currentByte ;
        state <= READ_SIXTH_BYTE ;
        pop <= 1'b1 ; // get new byte 
      end else begin
        state <= IDLE ;
      end
    end 
    end 
    READ_SIXTH_BYTE:
    begin 
      if (pop == 1'b0) begin 
      FirstSampleAngle[15:8] <= FirstSampleAngle[15:8]+currentByte;
      state <= PROCESS_SIXTH_BYTE ;
      end 
    end 
    PROCESS_SIXTH_BYTE:
    begin
      CheckSumCal <= CheckSumCal^ FirstSampleAngle ;
      FirstSampleAngle <= FirstSampleAngle >> 1 ;
      pop <= 1'b1 ;
      state <= READ_SEVENTH_BYTE ;
    end 
    READ_SEVENTH_BYTE:
    begin
      if (pop == 1'b0) begin 
        if(currentByte[0]==1) begin
          pop <= 1'b1 ;
          LastSampleAngle[7:0] <= currentByte;
          state <= READ_EIGHT_BYTE;
        end else begin
          pop <= 1'b1 ; 
          state <= READ_FIRST_BYTE ;
        end
      end 
    end
    READ_EIGHT_BYTE:
    begin
      if (pop == 1'b0) begin 
        LastSampleAngle[15:8] <= LastSampleAngle[15:8]+currentByte;
        state <= PROCESS_EIGHT_BYTE;
      end 
    end
    PROCESS_EIGHT_BYTE:
    begin 
      LastSampleAngleCal <= LastSampleAngle ;
      LastSampleAngle <= LastSampleAngle >>1 ; 
      Find_IntervalAngle <= 1'b1;
      state <= READ_NINTH_BYTE ; 
    end
    READ_NINTH_BYTE:
    begin
      if (pop == 1'b0) begin 
        CheckSum [7:0] <= currentByte ;
        pop <= 1'b1 ; 
        state <= READ_TENTH_BYTE ; 
      end 
    end
    READ_TENTH_BYTE:
    begin
      if (pop == 1'b0) begin 
        CheckSum[15:8] <= currentByte ;
        state <= READ_DISTANCES ; 
      end 
    end
    READ_DISTANCES:
    begin 
      if (counter_read_bytes == (package_Sample_Num)) begin
        counter_read_bytes <= 0 ; 
        state <= FINISHED_LOOP ;
      end else begin 
        state <= READ_ONE_DISTANCE_BYTE ;
        pop <= 1'b1 ;
      end 
    end 
    READ_ONE_DISTANCE_BYTE:
    begin
      if (pop == 1'b0 ) begin 
        if( counter_read_bytes[0] == 0 )begin 
          CurrentDistance<= {8'b00000000, rx_data}; // fix this 
          CheckSumCal[7:0] <= CheckSumCal[7:0] ^ rx_data ;
          state <= READ_DISTANCES;
        end else begin 
          CurrentDistance <= {rx_data, CurrentDistance[7:0]}; // double check this line 
          counter_read_bytes <= counter_read_bytes + 1 ;
          CheckSumCal[15:8] <= CheckSumCal[15:8] ^ rx_data ;
          // Find New Angles using corrected angles 
          Find_CorrectAngle <= 1'b1 ;
          state <= READ_DISTANCES ; 
        end 
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
      if ( CheckSumResult == 1 ) begin 
        state <= IDLE ; 
      end else begin 
        state <= ERROR_STATE ; 
      end 
    end
    ERROR_STATE:
    begin
      // RN we don't worry about error checking 
      state <= IDLE ;
    end 
    endcase 
  end 
end 

endmodule
`default_nettype wire