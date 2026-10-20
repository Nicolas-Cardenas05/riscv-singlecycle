`timescale 1ns/1ps

module soc_top (
    input logic clk,
    input logic reset
);

logic [31:0] data_read;
logic [31:0] data_address;
logic [31:0] data_write;
logic data_write_enable;
logic [2:0] data_funct3;
logic [31:0] debug_pc;

single_cycle_cpu single_cycle_cpu_inst (
    .clk(clk),
    .reset(reset),
    .data_read(data_read),
    .data_address(data_address),
    .data_write(data_write),
    .data_write_enable(data_write_enable),
    .data_funct3(data_funct3),
    .debug_pc(debug_pc)
);

data_memory data_memory_inst (
    .clk(clk),
    .write_enable(data_write_enable),
    .write_data(data_write),
    .address(data_address),
    .funct3(data_funct3),
    .read_data(data_read)
);

endmodule