`timescale 1ns / 1ps
`default_nettype none

`ifdef SYNTHESIS
`define FPATH(X) `"X`"
`else /* ! SYNTHESIS */
`define FPATH(X) `"data/X`"
`endif  /* ! SYNTHESIS */

module image_sprite_2 #(
  parameter WIDTH=256, HEIGHT=512) (
  input wire pixel_clk_in,
  input wire rst_in,
  input wire [10:0] x_in, hcount_in,
  input wire [9:0]  y_in, vcount_in,
  input wire open_or_close,
  output logic [7:0] red_out,
  output logic [7:0] green_out,
  output logic [7:0] blue_out
  );

  localparam RAM1_WIDTH = 8;
  localparam RAM1_DEPTH = WIDTH*HEIGHT ;
  localparam RAM2_WIDTH = 24 ;
  localparam RAM2_DEPTH = 256 ;
 xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(RAM1_WIDTH),                       // Specify RAM data width
    .RAM_DEPTH(RAM1_DEPTH),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(../data/image2.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
 ) memory1 (
    .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
    .dina(0),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(0),         // Write enable
    .ena(1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1),   // Output register enable
    .douta(palette_addr)      // RAM output data, width determined from RAM_WIDTH
  );

  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(RAM2_WIDTH),                       // Specify RAM data width
    .RAM_DEPTH(RAM2_DEPTH),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(../data/palette2.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) memory2 (
    .addra(palette_addr),     // Address bus, width determined from RAM_DEPTH
    .dina(0),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(0),         // Write enable
    .ena(1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1),   // Output register enable
    .douta(color)      // RAM output data, width determined from RAM_WIDTH
  );

  // calculate rom address
  logic [RAM2_WIDTH-1 : 0] color ; 
  logic [RAM1_WIDTH-1 : 0] palette_addr; 
  logic [$clog2(WIDTH*HEIGHT)-1:0] image_addr;
  assign image_addr = (hcount_in - x_in) + ((vcount_in - y_in) * WIDTH);

  logic in_sprite;

  always_comb begin
    if(open_or_close)begin 
        in_sprite = ((hcount_in >= x_in && hcount_in < (x_in + WIDTH)) &&
                      (vcount_in >= y_in && vcount_in < (y_in + HEIGHT/2)));
    end else begin 
        in_sprite = ((hcount_in >= x_in && hcount_in < (x_in + WIDTH)) &&
                      (vcount_in >= (y_in+(HEIGHT/2)) && vcount_in < (y_in + HEIGHT)));
    end
  end 
  // Modify the module below to use your BRAMs!
  assign red_out =    in_sprite ? color[23:16] : 0;
  assign green_out =  in_sprite ? color[15:8] : 0;
  assign blue_out =   in_sprite ? color[7:0] : 0;
endmodule






`default_nettype none
