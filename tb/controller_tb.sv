`timescale 1ns/1ps

module controller_tb;

logic [6:0] opcode;
logic [2:0] funct3;
logic funct7_b5;
logic equal;

logic [2:0] alu_control;
logic memory_write_enable;
logic [1:0] imm_selector;
logic pc_selector;
logic register_write_enable;
logic alu_a_selector;
logic alu_b_selector;
logic alu_result_selector;
logic result_selector;

controller dut (
    .opcode(opcode),
    .funct3(funct3),
    .funct7_b5(funct7_b5),
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

task automatic check_instruction (
    input string test_name,

    input logic [6:0] test_opcode,
    input logic [2:0] test_funct3,
    input logic test_funct7_b5,
    input logic test_equal,

    input logic [2:0] expected_alu_control,
    input logic expected_memory_write_enable,
    input logic [1:0] expected_imm_selector,
    input logic expected_pc_selector,
    input logic expected_register_write_enable,
    input logic expected_alu_a_selector,
    input logic expected_alu_b_selector,
    input logic expected_alu_result_selector,
    input logic expected_result_selector
);

begin

    opcode = test_opcode;
    funct3 = test_funct3;
    funct7_b5 = test_funct7_b5;
    equal = test_equal;

    #1;

    if (
        (alu_control === expected_alu_control) &&
        (memory_write_enable === expected_memory_write_enable) &&
        (imm_selector === expected_imm_selector) &&
        (pc_selector === expected_pc_selector) &&
        (register_write_enable === expected_register_write_enable) &&
        (alu_a_selector === expected_alu_a_selector) &&
        (alu_b_selector === expected_alu_b_selector) &&
        (alu_result_selector === expected_alu_result_selector) &&
        (result_selector === expected_result_selector)
    ) begin

        $display("PASS: %s", test_name);

    end else begin

        $error("FAIL: %s", test_name);

        $display("  Signal                  Expected   Actual");
        $display("  alu_control             %b         %b",
                 expected_alu_control, alu_control);

        $display("  memory_write_enable     %b           %b",
                 expected_memory_write_enable, memory_write_enable);

        $display("  imm_selector            %b          %b",
                 expected_imm_selector, imm_selector);

        $display("  pc_selector             %b           %b",
                 expected_pc_selector, pc_selector);

        $display("  register_write_enable   %b           %b",
                 expected_register_write_enable, register_write_enable);

        $display("  alu_a_selector          %b           %b",
                 expected_alu_a_selector, alu_a_selector);

        $display("  alu_b_selector          %b           %b",
                 expected_alu_b_selector, alu_b_selector);

        $display("  alu_result_selector     %b           %b",
                 expected_alu_result_selector, alu_result_selector);

        $display("  result_selector         %b           %b",
                 expected_result_selector, result_selector);

    end

end
endtask


initial begin

    $dumpfile("controller.vcd");
    $dumpvars(0, controller_tb);

    opcode = 7'b0;
    funct3 = 3'b0;
    funct7_b5 = 1'b0;
    equal = 1'b0;

    #1;


    // --------------------------------------------------
    // R-TYPE INSTRUCTIONS
    // --------------------------------------------------

    check_instruction(
        "ADD",
        7'b0110011,
        3'b000,
        1'b0,
        1'b0,

        3'b000,
        1'b0,
        2'b00,
        1'b0,
        1'b1,
        1'b0,
        1'b0,
        1'b0,
        1'b0
    );


    check_instruction(
        "SUB",
        7'b0110011,
        3'b000,
        1'b1,
        1'b0,

        3'b001,
        1'b0,
        2'b00,
        1'b0,
        1'b1,
        1'b0,
        1'b0,
        1'b0,
        1'b0
    );


    check_instruction(
        "AND",
        7'b0110011,
        3'b111,
        1'b0,
        1'b0,

        3'b010,
        1'b0,
        2'b00,
        1'b0,
        1'b1,
        1'b0,
        1'b0,
        1'b0,
        1'b0
    );


    check_instruction(
        "OR",
        7'b0110011,
        3'b110,
        1'b0,
        1'b0,

        3'b011,
        1'b0,
        2'b00,
        1'b0,
        1'b1,
        1'b0,
        1'b0,
        1'b0,
        1'b0
    );


    check_instruction(
        "SLT",
        7'b0110011,
        3'b010,
        1'b0,
        1'b0,

        3'b100,
        1'b0,
        2'b00,
        1'b0,
        1'b1,
        1'b0,
        1'b0,
        1'b0,
        1'b0
    );


    // --------------------------------------------------
    // I-TYPE ALU INSTRUCTIONS
    // --------------------------------------------------

    check_instruction(
        "ADDI",
        7'b0010011,
        3'b000,
        1'b0,
        1'b0,

        3'b000,
        1'b0,
        2'b00,
        1'b0,
        1'b1,
        1'b0,
        1'b1,
        1'b0,
        1'b0
    );


    check_instruction(
        "ANDI",
        7'b0010011,
        3'b111,
        1'b0,
        1'b0,

        3'b010,
        1'b0,
        2'b00,
        1'b0,
        1'b1,
        1'b0,
        1'b1,
        1'b0,
        1'b0
    );


    check_instruction(
        "ORI",
        7'b0010011,
        3'b110,
        1'b0,
        1'b0,

        3'b011,
        1'b0,
        2'b00,
        1'b0,
        1'b1,
        1'b0,
        1'b1,
        1'b0,
        1'b0
    );


    check_instruction(
        "SLTI",
        7'b0010011,
        3'b010,
        1'b0,
        1'b0,

        3'b100,
        1'b0,
        2'b00,
        1'b0,
        1'b1,
        1'b0,
        1'b1,
        1'b0,
        1'b0
    );


    // --------------------------------------------------
    // LOAD
    // --------------------------------------------------

    check_instruction(
        "LW",
        7'b0000011,
        3'b010,
        1'b0,
        1'b0,

        3'b000,
        1'b0,
        2'b00,
        1'b0,
        1'b1,
        1'b0,
        1'b1,
        1'b0,
        1'b1
    );


    // --------------------------------------------------
    // STORE
    // --------------------------------------------------

    check_instruction(
        "SW",
        7'b0100011,
        3'b010,
        1'b0,
        1'b0,

        3'b000,
        1'b1,
        2'b01,
        1'b0,
        1'b0,
        1'b0,
        1'b1,
        1'b0,
        1'b0
    );


    // --------------------------------------------------
    // BRANCH
    // --------------------------------------------------

    check_instruction(
        "BEQ NOT TAKEN",
        7'b1100011,
        3'b000,
        1'b0,
        1'b0,

        3'b000,
        1'b0,
        2'b10,
        1'b0,
        1'b0,
        1'b1,
        1'b1,
        1'b0,
        1'b0
    );


    check_instruction(
        "BEQ TAKEN",
        7'b1100011,
        3'b000,
        1'b0,
        1'b1,

        3'b000,
        1'b0,
        2'b10,
        1'b1,
        1'b0,
        1'b1,
        1'b1,
        1'b0,
        1'b0
    );


    // --------------------------------------------------
    // JUMP
    // --------------------------------------------------

    check_instruction(
        "JAL",
        7'b1101111,
        3'b000,
        1'b0,
        1'b0,

        3'b000,
        1'b0,
        2'b11,
        1'b1,
        1'b1,
        1'b1,
        1'b1,
        1'b1,
        1'b0
    );


    $display("");
    $display("========================================");
    $display("Controller testbench finished");
    $display("========================================");

    $finish;

end

endmodule