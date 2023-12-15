`timescale 1ns / 1ps
`default_nettype none

`ifdef SYNTHESIS
`define FPATH(X) `"X`"
`else /* ! SYNTHESIS */
`define FPATH(X) `"data/X`"
`endif  /* ! SYNTHESIS */

module draw_letter #(
  parameter WIDTH=119, HEIGHT=82) (
  input wire pixel_clk_in,
  input wire rst_in,
  input wire [10:0] x_in, hcount_in,
  input wire [9:0]  y_in, vcount_in,
  input wire [5:0] select_letter,
  output logic [7:0] red_out,
  output logic [7:0] green_out,
  output logic [7:0] blue_out,
  output logic [3:0] error_out
  );

  localparam RAM1_WIDTH = 1;
  localparam RAM1_DEPTH = 9758;
 xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(RAM1_WIDTH),                       // Specify RAM data width
    .RAM_DEPTH(RAM1_DEPTH),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(../data/png_scaled_down.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
 ) memory1 (
    .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
    .dina(1'b0),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(1'b0),         // Write enable
    .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1'b1),   // Output register enable
    .douta(color)      // RAM output data, width determined from RAM_WIDTH
  );
  logic color ;
  // calculate rom address
  logic [$clog2(WIDTH*HEIGHT)-1:0] image_addr;
  logic[$clog2(WIDTH):0] x_shift ;
  logic [$clog2(HEIGHT):0] y_shift ;
  assign image_addr = (hcount_in - x_in+x_shift) + ((vcount_in - y_in+y_shift) * WIDTH); // change this 

  logic in_sprite ;
  assign in_sprite = ((hcount_in >= x_in && hcount_in < (x_in + 15))) &&(((vcount_in) >= y_in && vcount_in < (y_in + 16))) ;
 
  // typedef enum {ROW1, ROW2, ROW3, ROW4, ROW5} rows ;
  // rows row_state; 
  // typedef enum {COLUMN1, COLUMN2, COLUMN3, COLUMN4, COLUMN5, COLUMN6, COLUMN7, COLUMN8} columns ;
  // columns column_state; 

  always_comb begin
    if(select_letter<=7) begin 
      //row_state = ROW1 ; 
      y_shift = 0 ;
    end else if ((select_letter>7) && (select_letter<=15)) begin 
      //row_state = ROW2 ; 
      y_shift = 17 ;
    end else if ((select_letter>15) && (select_letter<=23)) begin 
      //row_state = ROW3 ; 
      y_shift = 32;
    end else if ((select_letter>23) && (select_letter<=31)) begin 
      //row_state = ROW4 ; 
      y_shift = 49 ;
    end else begin 
      y_shift = 65 ; 
    end 

    if((select_letter%8)== 0) begin 
      //column_state = COLUMN1 ; 
      x_shift = 0 ;
    end else if ((select_letter%8)== 1) begin 
      //column_state = COLUMN2 ; 
      x_shift = 14 ;
    end else if ((select_letter%8)== 2) begin 
      //column_state = COLUMN3 ; 
      x_shift = 28;
    end else if ((select_letter%8)== 3) begin 
      //column_state = COLUMN4 ; 
      x_shift = 40 ;
    end else if ((select_letter%8)== 4) begin 
      //column_state = COLUMN5 ; 
      x_shift = 56 ;
    end else if ((select_letter%8)== 5) begin 
      //column_state = COLUMN6 ; 
      x_shift = 72 ;
    end else if ((select_letter%8)== 6) begin 
      //column_state = COLUMN7 ; 
      x_shift = 84 ;
    end else if ((select_letter%8)== 7) begin 
      //column_state = COLUMN8 ; 
      x_shift = 98 ;
    end 
    // if (in_sprite ) begin 
    // case(row_state)
    // ROW1: in_sprite_x = (hcount_in >= x_in && hcount_in < (x_in + 17)) ;
    // ROW2: in_sprite_x = (hcount_in >= (x_in+17) && hcount_in < (x_in + 33)) ;
    // ROW3: in_sprite_x = (hcount_in >= (x_in+17) && hcount_in < (x_in + 49)) ;
    // ROW4: in_sprite_x = (hcount_in >= (x_in+49) && hcount_in < (x_in + 65)) ;
    // ROW5: in_sprite_x = (hcount_in >= (x_in+66) && hcount_in < (x_in + 82)) ;
    // endcase
    // case(column_state)
    // COLUMN1: in_sprite_y = ((vcount_in) >= y_in && vcount_in < (y_in + 15)) ;
    // COLUMN2: in_sprite_y = ((vcount_in) >= (y_in+14) && vcount_in < (y_in + 29)) ;
    // COLUMN3: in_sprite_y = ((vcount_in) >= (y_in+28) && vcount_in < (y_in + 43)) ;
    // COLUMN4: in_sprite_y = ((vcount_in) >= (y_in+42) && vcount_in < (y_in + 57)) ;
    // COLUMN5: in_sprite_y = ((vcount_in) >= (y_in+56) && vcount_in < (y_in + 71)) ;
    // COLUMN6: in_sprite_y = ((vcount_in) >= (y_in+70) && vcount_in < (y_in + 85)) ;
    // COLUMN7: in_sprite_y = ((vcount_in) >= (y_in+84) && vcount_in < (y_in + 99)) ;
    // COLUMN8: in_sprite_y = ((vcount_in) >= (y_in+98) && vcount_in < (y_in + 119)) ;
    // endcase
    //end 
  end 
  // Modify the module below to use your BRAMs!
  assign red_out =  (in_sprite) ?  (color==1?8'hff :0) :0;
  assign green_out =  (in_sprite ) ? (color==1?8'hff :0):0;
  assign blue_out =   (in_sprite) ? (color==1?8'hff :0):0;
endmodule






`default_nettype none
