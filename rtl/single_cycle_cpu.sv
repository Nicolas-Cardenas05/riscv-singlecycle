`timescale 1ns/1ps
module single_cycle_cpu (
    input logic clk,
    input logic reset
);

logic [31:0] read_data_b;
logic [31:0] immediate;
logic alu_b_selector;
logic [31:0] src_b;

logic [31:0] read_data_a;
logic [31:0] pc;
logic alu_a_selector;
logic [31:0] src_a;

logic [2:0] alu_control;
logic [31:0] alu_result;
logic [31:0] alu_address;

logic [31:0] pc_plus_4;
logic alu_result_selector;
logic [31:0] ieu_result;

logic result_selector;
logic [31:0] result;

logic memory_write_enable;
logic [31:0] memory_read_data;

logic pc_selector;
logic [31:0] pc_next;

logic [1:0] imm_selector;

logic equal;

logic register_write_enable;

logic [31:0] instruction;

srcb_mux srcb_mux_inst (
    .data_b(read_data_b),
    .immediate(immediate),
    .alu_b_selector(alu_b_selector),
    .src_b(src_b)
);

srca_mux srca_mux_inst (
    .data_a(read_data_a),
    .pc(pc),
    .alu_a_selector(alu_a_selector),
    .src_a(src_a)
);

alu alu_inst (
    .operand_a(src_a),
    .operand_b(src_b),
    .alu_control(alu_control),
    .alu_result(alu_result),
    .alu_address(alu_address)
);

ieu_result_mux ieu_result_mux_inst (
    .alu_result(alu_result),
    .pc_plus_4(pc_plus_4),
    .alu_result_selector(alu_result_selector),
    .ieu_result(ieu_result)
);

result_mux result_mux_inst (
    .ieu_result(ieu_result),
    .read_data(memory_read_data),
    .result_selector(result_selector),
    .result(result)
);

data_memory data_memory_inst (
    .clk(clk),
    .write_enable(memory_write_enable),
    .write_data(read_data_b),
    .address(alu_address),
    .read_data(memory_read_data)
);

pc_mux pc_mux_inst (
    .pc_plus_4(pc_plus_4),
    .alu_address(alu_address),
    .pc_selector(pc_selector),
    .pc_next(pc_next)
);

pc_register pc_register_inst (
    .clk(clk),
    .reset(reset),
    .pc_next(pc_next),
    .pc(pc)
);

pc_adder pc_adder_inst (
    .pc(pc),
    .pc_plus_4(pc_plus_4)
);

extend extend_inst (
    .imm_instruction(instruction[31:7]),
    .imm_selector(imm_selector),
    .immediate(immediate)
);

comp comp_inst (
    .data_a(read_data_a),
    .data_b(read_data_b),
    .equal(equal)
);

register_file register_file_inst (
    .clk(clk),
    .write_enable(register_write_enable),
    .address_a(instruction[19:15]),
    .address_b(instruction[24:20]),
    .write_address(instruction[11:7]),
    .write_data(result),
    .read_data_a(read_data_a),
    .read_data_b(read_data_b)
);

instruction_memory instruction_memory_inst (
    .pc(pc),
    .instruction(instruction)
);

controller controller_inst(
    .opcode(instruction[6:0]),
    .funct3(instruction[14:12]),
    .funct7_b5(instruction[30]),
    .equal(equal),
    .alu_control(alu_control),
    .memory_write_enable(memory_write_enable),
    .imm_selector(imm_selector),
    .pc_selector(pc_selector),
    .register_write_enable(register_write_enable),
    .alu_a_selector(alu_a_selector),
    .alu_b_selector(alu_b_selector),
    .alu_result_selector(alu_result_selector),
    .result_selector(result_selector)
);

endmodule