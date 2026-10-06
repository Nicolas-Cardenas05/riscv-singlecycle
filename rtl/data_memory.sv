`timescale 1ns/1ps
module data_memory (
    input logic clk,
    input logic write_enable,
    input logic [31:0] write_data,
    input logic [31:0] address,
    output logic [31:0] read_data
);

logic [31:0] memory [63:0];

assign read_data = memory[address[7:2]];

always_ff @(posedge clk)
    if (write_enable) memory[address[7:2]] <= write_data;

endmodule