`timescale 1ns / 1ps
`default_nettype none

`ifdef SYNTHESIS
`define FPATH(X) `"X`"
`else /* ! SYNTHESIS */
`define FPATH(X) `"data/X`"
`endif  /* ! SYNTHESIS */


module Find_CorrectedAngles  (
    input wire clk_in,
    input wire rst_in,
    input wire[15:0] FirstSampleAngle,
    input wire [15:0] IntervalSampleAngle, 
    input wire [15:0] package_Sample_Index ,
    input wire [15:0] distance,
    input wire data_valid_in,
    output logic[15:0] angle_out,
    output logic [15:0] distance_out, 
    output logic data_valid_out
    );

  localparam RAM1_WIDTH = 10 ;
  localparam RAM1_DEPTH = 16384 ;
 xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(RAM1_WIDTH),                       // Specify RAM data width
    .RAM_DEPTH(RAM1_DEPTH),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(../data/map_hex.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
 ) map_mem (
    .addra(input_arctan_map),     // Address bus, width determined from RAM_DEPTH
    .dina(10'b0),       // RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),       // Clock
    .wea(1'b0),         // Write enable
    .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1'b1),   // Output register enable
    .douta(palette_address)      // RAM output data, width determined from RAM_WIDTH
  );

  logic [13:0] input_arctan_map ;
  logic [9:0] palette_address ; 
  logic signed [15:0] output_arctan_map ;
  //assign palette_address_shift = palette_address +1;
  localparam RAM2_WIDTH = 16;
  localparam RAM2_DEPTH = 559;

 xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(RAM2_WIDTH),                       // Specify RAM data width
    .RAM_DEPTH(RAM2_DEPTH),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(../data/arctan_palette_hex.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
 ) arctan_palette_mem (
    .addra(palette_address),     // Address bus, width determined from RAM_DEPTH
    .dina(16'b0),       // RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),       // Clock
    .wea(1'b0),         // Write enable
    .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1'b1),   // Output register enable
    .douta(output_arctan_map)      // RAM output data, width determined from RAM_WIDTH
  );

logic [31:0] sample_angle ;
logic signed [31:0] summation ;
logic signed  [15:0] AngleCorrectForDistance ;
logic signed [31:0] AngleCorrectForDistance32;
logic signed [31:0] FirstSampleAngle32;
logic [2:0] small_counter ;
logic [31:0] temporary_angle ; 


always_comb begin 

  sample_angle = IntervalSampleAngle*package_Sample_Index ; 
  AngleCorrectForDistance = (distance == 0) ?0 : output_arctan_map ;
  // casting for correct sum 
  AngleCorrectForDistance32 = AngleCorrectForDistance ;
  AngleCorrectForDistance32 = $signed(AngleCorrectForDistance) ;
  summation = $signed(FirstSampleAngle) + $signed(sample_angle) + $signed(AngleCorrectForDistance) ;
  distance_out =(distance>>2);

  if(summation < 0) begin 
    temporary_angle = (summation+23040) ;
  end else if (summation > 23040) begin 
    temporary_angle  = (summation-23040);
  end else begin 
    temporary_angle  = summation ;
  end 
  angle_out = $unsigned(temporary_angle);
end 

typedef enum {IDLE, IS_DISTANCE_VALID, WAIT4_CLOCK_CYCLES, FIND_CORRECT_ANGLE } processing_state ;
processing_state state; //state of system!

  always_ff @(posedge clk_in)begin
    if (rst_in)begin
      distance_out <= 0 ;
      data_valid_out <= 0 ;
    end else begin
    case(state)
    IDLE :
    begin 
    data_valid_out <= 0 ; 
    state <= data_valid_in? IS_DISTANCE_VALID: IDLE  ; 
    end 
    IS_DISTANCE_VALID:
    begin 
      if(distance == 0) begin
        state <=  FIND_CORRECT_ANGLE;
      end else begin 
        input_arctan_map <= distance_out[13:0] ;
        state <= WAIT4_CLOCK_CYCLES ; 
        small_counter <= 0 ;
      end 
    end 
    WAIT4_CLOCK_CYCLES:
    begin
      if(small_counter == 4) begin
        small_counter <= 0 ;
        state <= FIND_CORRECT_ANGLE ;
      end else begin 
        small_counter <= small_counter + 1 ; 
      end 
    end 
    FIND_CORRECT_ANGLE: 
    begin 
      state <= IDLE ;
      data_valid_out <= 1 ; 
    end 
    endcase
    end
  end
endmodule

`default_nettype wire
