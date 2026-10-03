`timescale 1ns/1ps
module register_file (
    input logic clk,
    input logic write_enable,
    input logic [4:0] address_a,
    input logic [4:0] address_b,
    input logic [4:0] address_result,
    input logic [31:0] write_data,
    output logic [31:0] read_data_a,
    output logic [31:0] read_data_b
);

logic [31:0] registers [31:1];

always_ff @( posedge clk)
    if (write_enable && (address_result != 5'd0)) registers[address_result] <= write_data;

assign read_data_a = (address_a != 5'd0) ? registers[address_a] : 32'd0;
assign read_data_b = (address_b != 5'd0) ? registers[address_b] : 32'd0;
endmodule