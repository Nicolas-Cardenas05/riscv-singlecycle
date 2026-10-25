`timescale 1ns/1ps

module fpga_top (
    input logic CLK100MHZ,
    input logic CPU_RESETN,
    input logic BTNU,
    input logic BTND,
    input logic BTNL,
    input logic BTNR,
    input logic BTNC,
    input logic [15:0] SW,
    output logic [15:0] LED,
    output logic [6:0] seg,
    output logic [7:0] an,
    output logic dp,
    output logic [3:0] VGA_R,
    output logic [3:0] VGA_G,
    output logic [3:0] VGA_B,
    output logic VGA_HS,
    output logic VGA_VS
);

logic reset;

assign reset = ~CPU_RESETN;

soc_top soc_top_inst (
    .clk(CLK100MHZ),
    .reset(reset),
    .btn_up(BTNU),
    .btn_down(BTND),
    .btn_left(BTNL),
    .btn_right(BTNR),
    .btn_center(BTNC),
    .gpio_in(SW),
    .gpio_out(LED),
    .segments(seg),
    .anodes(an),
    .dp(dp),
    .vga_red(VGA_R),
    .vga_green(VGA_G),
    .vga_blue(VGA_B),
    .vga_hsync(VGA_HS),
    .vga_vsync(VGA_VS)
);

endmodule