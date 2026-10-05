`timescale 1ns/1ps

module alu_tb;

    logic [31:0] tb_operand_a;
    logic [31:0] tb_operand_b;
    logic [2:0]  tb_alu_control;
    logic [31:0] tb_alu_result;
    logic [31:0] tb_alu_address;

    alu dut (
        .operand_a(tb_operand_a),
        .operand_b(tb_operand_b),
        .alu_control(tb_alu_control),
        .alu_result(tb_alu_result),
        .alu_address(tb_alu_address)
    );

    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, alu_tb);

        // ADD: 15 + 5 = 20
        tb_alu_control = 3'b000;
        tb_operand_a = 32'd15;
        tb_operand_b = 32'd5;
        #1;

        if (tb_alu_result === 32'd20)
            $display("PASS: ADD 15 + 5 = 20");
        else
            $error("FAIL ADD: expected 20, got %0d", tb_alu_result);

        if (tb_alu_address === 32'd20)
            $display("PASS: ALU address 15 + 5 = 20");
        else
            $error("FAIL ALU ADDRESS: expected 20, got %0d", tb_alu_address);

        // SUB: 15 - 5 = 10
        tb_alu_control = 3'b001;
        tb_operand_a = 32'd15;
        tb_operand_b = 32'd5;
        #1;

        if (tb_alu_result === 32'd10)
            $display("PASS: SUB 15 - 5 = 10");
        else
            $error("FAIL SUB: expected 10, got %0d", tb_alu_result);


        // AND: 255 & 1023 = 255
        tb_alu_control = 3'b010;
        tb_operand_a = 32'd255;
        tb_operand_b = 32'd1023;
        #1;

        if (tb_alu_result === 32'd255)
            $display("PASS: AND result = 255");
        else
            $error("FAIL AND: expected 255, got %0d", tb_alu_result);


        // OR: 255 | 1023 = 1023
        tb_alu_control = 3'b011;
        tb_operand_a = 32'd255;
        tb_operand_b = 32'd1023;
        #1;

        if (tb_alu_result === 32'd1023)
            $display("PASS: OR result = 1023");
        else
            $error("FAIL OR: expected 1023, got %0d", tb_alu_result);


        // SLT signed: -5 < 3 -> 1
        tb_alu_control = 3'b100;
        tb_operand_a = -32'd5;
        tb_operand_b = 32'd3;
        #1;

        if (tb_alu_result === 32'd1)
            $display("PASS: SLT -5 < 3 -> 1");
        else
            $error("FAIL SLT: expected 1, got %0d", tb_alu_result);


        // SLT signed: 10 < 3 -> 0
        tb_alu_control = 3'b100;
        tb_operand_a = 32'd10;
        tb_operand_b = 32'd3;
        #1;

        if (tb_alu_result === 32'd0)
            $display("PASS: SLT 10 < 3 -> 0");
        else
            $error("FAIL SLT: expected 0, got %0d", tb_alu_result);


        // Invalid / unused ALU control -> default = 0
        tb_alu_control = 3'b111;
        tb_operand_a = 32'd20;
        tb_operand_b = 32'd30;
        #1;

        if (tb_alu_result === 32'd0)
            $display("PASS: default ALU control -> 0");
        else
            $error("FAIL DEFAULT: expected 0, got %0d", tb_alu_result);


        $display("ALU testbench finished.");
        $finish;
    end

endmodule