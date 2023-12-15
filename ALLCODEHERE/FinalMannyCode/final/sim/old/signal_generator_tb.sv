`timescale 1ns / 1ps
`default_nettype none

module signal_generator_tb();

    logic clk_pixel_in;
    logic rst_in;
    logic [10:0] hcount_out;
    logic [9:0] vcount_out;
    logic vs_out;
    logic hs_out;
    logic ad_out;
    logic nf_out;
    logic [5:0] fc_out;

    parameter ACTIVE_H_PIXELS = 30;
    parameter H_FRONT_PORCH = 11;
    parameter H_SYNC_WIDTH = 4;
    parameter H_BACK_PORCH = 22;
    parameter ACTIVE_LINES = 10;
    parameter V_FRONT_PORCH = 5;
    parameter V_SYNC_WIDTH = 5;
    parameter V_BACK_PORCH = 2;

    video_sig_gen 
        #(.ACTIVE_H_PIXELS(ACTIVE_H_PIXELS),
            .H_FRONT_PORCH(H_FRONT_PORCH),
            .H_SYNC_WIDTH(H_SYNC_WIDTH),
            .H_BACK_PORCH(H_BACK_PORCH),
            .ACTIVE_LINES(ACTIVE_LINES),
            .V_FRONT_PORCH(V_FRONT_PORCH),
            .V_SYNC_WIDTH(V_SYNC_WIDTH),
            .V_BACK_PORCH(V_BACK_PORCH)
        )uut(
            .clk_pixel_in(clk_pixel_in),
            .rst_in(rst_in),
            .hcount_out(hcount_out),
            .vcount_out(vcount_out),
            .vs_out(vs_out),
            .hs_out(hs_out),
            .ad_out(ad_out),
            .nf_out(nf_out),
            .fc_out(fc_out));

    always begin
        #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk_pixel_in = !clk_pixel_in;
    end
    //initial block...this is our test simulation
    initial begin
        $dumpfile("vsgt.vcd"); //file to store value change dump (vcd)
        $dumpvars(0,signal_generator_tb);
        $display("Starting Sim"); //print nice message at start
        clk_pixel_in = 0;
        rst_in = 0;
        #10;
        rst_in = 1;
        #10;
        rst_in = 0;
        #100000;
        $display("Simulation finished");
        $finish;
    end
endmodule
`default_nettype wire