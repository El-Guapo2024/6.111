module bram_manager(
        input wire  write_in,
        input wire read_in,
        input wire clk_in,
        input wire rst_in,
        input wire [31:0] angle_distance_input,
        output logic [31:0] angle_distance_output
        );
    
// The following is an instantiation template for xilinx_true_dual_port_read_first_2_clock_ram
/*
  //  Xilinx True Dual Port RAM, Read First, Dual Clock
  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(18),                       // Specify RAM data width
    .RAM_DEPTH(1024),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    .INIT_FILE("")                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) your_instance_name (
    .addra(addra),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(addrb),   // Port B address bus, width determined from RAM_DEPTH
    .dina(dina),     // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(dinb),     // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clka),     // Port A clock
    .clkb(clkb),     // Port B clock
    .wea(wea),       // Port A write enable
    .web(web),       // Port B write enable
    .ena(ena),       // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(enb),       // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(rsta),     // Port A output reset (does not affect memory contents)
    .rstb(rstb),     // Port B output reset (does not affect memory contents)
    .regcea(regcea), // Port A output register enable
    .regceb(regceb), // Port B output register enable
    .douta(douta),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb(doutb)    // Port B RAM output data, width determined from RAM_WIDTH
  );
*/


 logic [10:0] bram1_max_address ;
 logic [9:0] bram1_addressa ;
 logic [9:0] bram1_addressb ;
 logic [31:0] bram1_input_data ;
 logic bram1_write_enable ;
 logic [31:0] bram1_addressa_output;
 logic [31:0] bram1_addressb_output ;
  
  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(32),                       // Specify RAM data width
    .RAM_DEPTH(1024),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE") // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
  ) myBram1 (
    .addra(bram1_addressa),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(bram1_addressb),   // Port B address bus, width determined from RAM_DEPTH
    .dina(bram1_input_data),     // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(32'b0),     // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),     // Port A clock
    .clkb(clk_in),     // Port B clock
    .wea(bram1_write_enable),       // Port A write enable
    .web(1'b0),       // Port B write enable
    .ena(1'b1),       // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(1'b1),       // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),     // Port A output reset (does not affect memory contents)
    .rstb(rst_in),     // Port B output reset (does not affect memory contents)
    .regcea(1'b1), // Port A output register enable
    .regceb(1'b1), // Port B output register enable
    .douta(bram1_addressa_output),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb(bram1_addressb_output)    // Port B RAM output data, width determined from RAM_WIDTH
  );


 logic [10:0] bram2_max_address ;
 logic [9:0] bram2_addressa ;
 logic [9:0] bram2_addressb ;
 logic [31:0] bram2_input_data ;
 logic bram2_write_enable ;
 logic [31:0] bram2_addressa_output;
 logic [31:0] bram2_addressb_output ;
  
  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(32),                       // Specify RAM data width
    .RAM_DEPTH(1024),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE") // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
  ) myBram2 (
    .addra(bram2_addressa),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(bram2_addressb),   // Port B address bus, width determined from RAM_DEPTH
    .dina(bram2_input_data),     // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(32'b0),     // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),     // Port A clock
    .clkb(clk_in),     // Port B clock
    .wea(bram2_write_enable),       // Port A write enable
    .web(1'b0),       // Port B write enable
    .ena(1'b1),       // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(1'b1),       // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),     // Port A output reset (does not affect memory contents)
    .rstb(rst_in),     // Port B output reset (does not affect memory contents)
    .regcea(1'b1), // Port A output register enable
    .regceb(1'b1), // Port B output register enable
    .douta(bram2_addressa_output),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb(bram2_addressb_output)    // Port B RAM output data, width determined from RAM_WIDTH
  );



 logic [10:0] bram3_max_address ;
 logic [9:0] bram3_addressa ;
 logic [9:0] bram3_addressb ;
 logic [31:0] bram3_input_data ;
 logic bram3_write_enable ;
 logic [31:0] bram3_addressa_output;
 logic [31:0] bram3_addressb_output ;
  
  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(32),                       // Specify RAM data width
    .RAM_DEPTH(1024),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE") // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
  ) myBram3 (
    .addra(bram3_addressa),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(bram3_addressb),   // Port B address bus, width determined from RAM_DEPTH
    .dina(bram3_input_data),     // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(32'b0),     // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),     // Port A clock
    .clkb(clk_in),     // Port B clock
    .wea(bram3_write_enable),       // Port A write enable
    .web(1'b0),       // Port B write enable
    .ena(1'b1),       // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(1'b1),       // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),     // Port A output reset (does not affect memory contents)
    .rstb(rst_in),     // Port B output reset (does not affect memory contents)
    .regcea(1'b1), // Port A output register enable
    .regceb(1'b1), // Port B output register enable
    .douta(bram3_addressa_output),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb(bram3_addressb_output)    // Port B RAM output data, width determined from RAM_WIDTH
  );

 


 logic [10:0] bram4_max_address ;
 logic [9:0] bram4_addressa ;
 logic [9:0] bram4_addressb ;
 logic [31:0] bram4_input_data ;
 logic bram4_write_enable ;
 logic [31:0] bram4_addressa_output;
 logic [31:0] bram4_addressb_output ;
  
  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(32),                       // Specify RAM data width
    .RAM_DEPTH(1024),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE") // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
  ) myBram4 (
    .addra(bram4_addressa),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(bram4_addressb),   // Port B address bus, width determined from RAM_DEPTH
    .dina(bram4_input_data),     // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(32'b0),     // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),     // Port A clock
    .clkb(clk_in),     // Port B clock
    .wea(bram4_write_enable),       // Port A write enable
    .web(1'b0),       // Port B write enable
    .ena(1'b1),       // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(1'b1),       // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),     // Port A output reset (does not affect memory contents)
    .rstb(rst_in),     // Port B output reset (does not affect memory contents)
    .regcea(1'b1), // Port A output register enable
    .regceb(1'b1), // Port B output register enable
    .douta(bram4_addressa_output),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb(bram4_addressb_output)    // Port B RAM output data, width determined from RAM_WIDTH
  );


 

 logic [10:0] bram5_max_address ;
 logic [9:0] bram5_addressa ;
 logic [9:0] bram5_addressb ;
 logic [31:0] bram5_input_data ;
 logic bram5_write_enable ;
 logic [31:0] bram5_addressa_output;
 logic [31:0] bram5_addressb_output ;
  
  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(32),                       // Specify RAM data width
    .RAM_DEPTH(1024),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE") // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
  ) myBram5 (
    .addra(bram5_addressa),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(bram5_addressb),   // Port B address bus, width determined from RAM_DEPTH
    .dina(bram5_input_data),     // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(32'b0),     // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),     // Port A clock
    .clkb(clk_in),     // Port B clock
    .wea(bram5_write_enable),       // Port A write enable
    .web(1'b0),       // Port B write enable
    .ena(1'b1),       // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(1'b1),       // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),     // Port A output reset (does not affect memory contents)
    .rstb(rst_in),     // Port B output reset (does not affect memory contents)
    .regcea(1'b1), // Port A output register enable
    .regceb(1'b1), // Port B output register enable
    .douta(bram5_addressa_output),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb(bram5_addressb_output)    // Port B RAM output data, width determined from RAM_WIDTH
  );




 logic [10:0] bram6_max_address ;
 logic [9:0] bram6_addressa ;
 logic [9:0] bram6_addressb ;
 logic [31:0] bram6_input_data ;
 logic bram6_write_enable ;
 logic [31:0] bram6_addressa_output;
 logic [31:0] bram6_addressb_output ;
  
  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(32),                       // Specify RAM data width
    .RAM_DEPTH(1024),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE") // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
  ) myBram6 (
    .addra(bram6_addressa),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(bram6_addressb),   // Port B address bus, width determined from RAM_DEPTH
    .dina(bram6_input_data),     // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(32'b0),     // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),     // Port A clock
    .clkb(clk_in),     // Port B clock
    .wea(bram6_write_enable),       // Port A write enable
    .web(1'b0),       // Port B write enable
    .ena(1'b1),       // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(1'b1),       // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),     // Port A output reset (does not affect memory contents)
    .rstb(rst_in),     // Port B output reset (does not affect memory contents)
    .regcea(1'b1), // Port A output register enable
    .regceb(1'b1), // Port B output register enable
    .douta(bram6_addressa_output),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb(bram6_addressb_output)    // Port B RAM output data, width determined from RAM_WIDTH
  );
logic [5:0] BRAMSTATE; 
typedef enum {WRITEBRAM1, WRITEBRAM2,WRITEBRAM3,WRITEBRAM4,WRITEBRAM5,WRITEBRAM6} processing_state ;
processing_state state; //state of system!

always_comb begin 
  if(write_in) begin
  case(state)
    WRITEBRAM1: bram1_input_data = write_in ;
    WRITEBRAM2: bram2_input_data= write_in ;
    WRITEBRAM3: bram3_input_data = write_in ;
    WRITEBRAM4: bram4_input_data = write_in ;
    WRITEBRAM5: bram5_input_data = write_in ;
    WRITEBRAM6: bram6_input_data = write_in ;
  endcase
  end
end

always_ff@(posedge clk_in) begin
  if(read_in) begin
    angle_distance_output <= 0 ;
    BRAMSTATE <= 0 ; 
  end else if(write_in) begin 
    case(state)
    WRITEBRAM1:
    begin 
      if(bram1_addressa == 10'b1111111111 ) begin
        bram1_addressa <= 0 ;
        state <= WRITEBRAM2 ;
        BRAMSTATE[0] <= 1 ;
      end else begin 
        bram1_addressa <= bram1_addressa + 1 ;
      end 
    end 
    WRITEBRAM2:
    begin 
      if(bram2_addressa == 10'b1111111111 ) begin
        bram2_addressa <= 0 ;
        state <= WRITEBRAM3 ;
        BRAMSTATE[1] <= 1 ;
      end else begin 
        bram2_addressa <= bram2_addressa + 1 ;
      end 
    end 
    WRITEBRAM3:
    begin 
      if(bram3_addressa == 10'b1111111111 ) begin
        bram3_addressa <= 0 ;
        state <= WRITEBRAM4 ;
        BRAMSTATE[2] <= 1 ;
      end else begin 
        bram3_addressa <= bram3_addressa + 1 ;
      end 
    end 
     WRITEBRAM4:
    begin 
      if(bram4_addressa == 10'b1111111111 ) begin
        bram4_addressa <= 0 ;
        state <= WRITEBRAM5 ;
        BRAMSTATE[3] <= 1 ;
      end else begin 
        bram4_addressa <= bram4_addressa + 1 ;
      end 
    end 
        WRITEBRAM5:
    begin 
      if(bram5_addressa == 10'b1111111111 ) begin
        bram5_addressa <= 0 ;
        state <= WRITEBRAM6 ;
        BRAMSTATE[4] <= 1 ;
      end else begin 
        bram5_addressa <= bram5_addressa  + 1 ;
      end 
    end 
    WRITEBRAM6:
    begin 
      if(bram6_addressa == 10'b1111111111 ) begin
        bram6_addressa <= 0 ;
        state <= WRITEBRAM1 ;
        BRAMSTATE[5] <= 1 ;
      end else begin 
        bram6_addressa <= bram6_addressa + 1 ;
      end 
    end 

    endcase
  end

end


endmodule
