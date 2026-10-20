`timescale 1ns / 1ps

module fpga_top(
    input logic CLK100MHZ,
    input logic BTNC,
    input logic [15:0] SW,
    output logic [15:0] LED,
    output logic [6:0] SEG,
    output logic [7:0] AN,
    output logic DP
);

soc_top soc_top_inst (
    .clk(CLK100MHZ),
    .reset(BTNC),
    .gpio_in(SW),
    .gpio_out(LED),
    .segments(SEG),
    .anodes(AN),
    .dp(DP)
);

endmodule