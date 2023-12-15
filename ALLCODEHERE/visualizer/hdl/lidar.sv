module lidar (
  input wire clk_in ,
  input wire rx_in,
  input wire rst_in,
  output logic valid_pixel_out,
  output logic pixel_out,
  output logic[10:0] hcount_out,
  output logic[9:0] vcount_out,
  output logic [2:0] state_out 
  );

  logic old_valid_pixel_in;
  logic [10:0] hcount;
  logic [9:0] vcount;
  logic [4:0] counter ;
  //logic [10:0] x_counter ;
  //logic [10:0] y_counter ; 
  localparam width = 359 ;
  localparam height = 359 ;
  localparam  max_size = 129599 ;
  assign hcount_out = hcount;
  assign vcount_out = vcount;

  // Rx Protocol 
  logic [7:0] data_out ;
  logic valid_byte;
  uart_rx #(
    .CLOCKS_PER_BAUD(644)                      // Specify name/location of RAM initialization file if using one (leave blank if not)
  )myUart (
    .clk(clk_in),
    .rx(rx_in),
    .data_o(data_out),
    .valid_o(valid_byte));

  typedef enum {IDLE,BYTE1,NEWFRAME, NEWDATA} lidar_state ;
  lidar_state state ; 
  always_ff @(posedge clk_in) begin
    if (rst_in)begin
      hcount <= 0;
      vcount <= 0;
      valid_pixel_out <= 0;
    end else begin
      case(state)
      IDLE:
      begin
        state_out <= 3'b000;
        //valid_pixel_out <= 0 ;
        if(valid_byte) begin 
          if(data_out == 8'hAA) begin
            state <= BYTE1 ;
          end else begin
            state <= IDLE ;
          end
        end
      end
      BYTE1:
      begin 
        state_out <= 3'b001;
        if(valid_byte)begin
          if (data_out == 8'hBB) begin
            state <= NEWDATA ; 
            counter <= 0 ; 
          end else if (data_out == 8'hEE) begin 
            state <= NEWFRAME ;
            hcount <= 0 ;
            vcount <= 0 ;
          end else begin 
            state <= IDLE;
          end 
        end 
      end
      NEWDATA:
      begin 
      state_out <= 3'b010;
      pixel_out <= 1 ; 
      if(counter == 4) begin 
        state <= IDLE ;
        valid_pixel_out <= 1;
      end else if(valid_byte) begin 
        if(counter == 0) begin 
          hcount <= {data_out[2:0],8'h00};
        end else if(counter == 1) begin 
          hcount <= {hcount[10:8],data_out};
        end else if(counter == 2) begin
          vcount[9:8] <= {data_out[1:0],8'h00};
        end else if(counter == 3) begin 
          vcount[7:0] <= {vcount[9:8],data_out};
        end 
        counter <= counter + 1 ;
      end 
      end
      NEWFRAME:
      begin 
      state_out <= 3'b100; 
      valid_pixel_out <= 1 ; 
      pixel_out <= 0 ;
      if(hcount == width && vcount == height) begin 
        state <= IDLE ;
      end else if (hcount == width ) begin 
        vcount <= vcount +1 ; 
        hcount <= 0 ; 
      end else begin 
        hcount <= hcount + 1 ; 
      end 
      end 
      endcase
    end
  end
endmodule
