`timescale 1ns/1ps

module alu_tb;
    logic [31:0] tb_operand_a;
    logic [31:0] tb_operand_b;
    logic [2:0]  tb_alu_control;
    logic [31:0] tb_alu_result;

alu dut (
    .operand_a(tb_operand_a),
    .operand_b(tb_operand_b),
    .alu_control(tb_alu_control),
    .alu_result(tb_alu_result)
);

initial begin
    $dumpfile("alu.vcd");
    $dumpvars(0, alu_tb);

    tb_alu_control = 3'b000;
    tb_operand_a = 32'd15;
    tb_operand_b = 32'd5;

    #10;
    tb_alu_control = 3'b001;
    tb_operand_a = 32'd15;
    tb_operand_b = 32'd5;

    #10;
    tb_alu_control = 3'b010;
    tb_operand_a = 32'd255;
    tb_operand_b = 32'd1023;

    #10;
    tb_alu_control = 3'b011;
    tb_operand_a = 32'd255;
    tb_operand_b = 32'd1023;

    #10;
    tb_alu_control = 3'b100;
    tb_operand_a = -32'd5;
    tb_operand_b = 32'd3;

    #10;
    $finish;
end
endmodule