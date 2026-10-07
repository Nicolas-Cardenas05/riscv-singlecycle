`timescale 1ns/1ps

module controller_tb;

logic [6:0] opcode;
logic [2:0] funct3;
logic funct7_b5;

logic equal;
logic less_than_signed;
logic less_than_unsigned;

logic [3:0] alu_control;
logic memory_write_enable;
logic [2:0] imm_selector;
logic pc_selector;
logic register_write_enable;
logic alu_a_selector;
logic alu_b_selector;
logic alu_result_selector;
logic result_selector;
logic jalr_selector;

integer pass_count;
integer fail_count;
integer test_count;


controller dut (
    .opcode(opcode),
    .funct3(funct3),
    .funct7_b5(funct7_b5),

    .equal(equal),
    .less_than_signed(less_than_signed),
    .less_than_unsigned(less_than_unsigned),

    .alu_control(alu_control),
    .memory_write_enable(memory_write_enable),
    .imm_selector(imm_selector),
    .pc_selector(pc_selector),
    .register_write_enable(register_write_enable),
    .alu_a_selector(alu_a_selector),
    .alu_b_selector(alu_b_selector),
    .alu_result_selector(alu_result_selector),
    .result_selector(result_selector),
    .jalr_selector(jalr_selector)
);


task automatic check_instruction (
    input string test_name,

    input logic [6:0] test_opcode,
    input logic [2:0] test_funct3,
    input logic test_funct7_b5,

    input logic test_equal,
    input logic test_less_signed,
    input logic test_less_unsigned,

    input logic [3:0] expected_alu_control,
    input logic expected_memory_write_enable,
    input logic [2:0] expected_imm_selector,
    input logic expected_pc_selector,
    input logic expected_register_write_enable,
    input logic expected_alu_a_selector,
    input logic expected_alu_b_selector,
    input logic expected_alu_result_selector,
    input logic expected_result_selector,
    input logic expected_jalr_selector
);

begin

    opcode = test_opcode;
    funct3 = test_funct3;
    funct7_b5 = test_funct7_b5;

    equal = test_equal;
    less_than_signed = test_less_signed;
    less_than_unsigned = test_less_unsigned;

    #1;

    test_count = test_count + 1;

    if (
        (alu_control === expected_alu_control) &&
        (memory_write_enable === expected_memory_write_enable) &&
        (imm_selector === expected_imm_selector) &&
        (pc_selector === expected_pc_selector) &&
        (register_write_enable === expected_register_write_enable) &&
        (alu_a_selector === expected_alu_a_selector) &&
        (alu_b_selector === expected_alu_b_selector) &&
        (alu_result_selector === expected_alu_result_selector) &&
        (result_selector === expected_result_selector) &&
        (jalr_selector === expected_jalr_selector)
    ) begin

        pass_count = pass_count + 1;

        $display(
            "PASS: %-20s",
            test_name
        );

    end
    else begin

        fail_count = fail_count + 1;

        $display(
            "FAIL: %-20s",
            test_name
        );

        $display(
            "  alu_control           Expected=%b Actual=%b",
            expected_alu_control,
            alu_control
        );

        $display(
            "  memory_write_enable   Expected=%b Actual=%b",
            expected_memory_write_enable,
            memory_write_enable
        );

        $display(
            "  imm_selector          Expected=%b Actual=%b",
            expected_imm_selector,
            imm_selector
        );

        $display(
            "  pc_selector           Expected=%b Actual=%b",
            expected_pc_selector,
            pc_selector
        );

        $display(
            "  register_write_enable Expected=%b Actual=%b",
            expected_register_write_enable,
            register_write_enable
        );

        $display(
            "  alu_a_selector        Expected=%b Actual=%b",
            expected_alu_a_selector,
            alu_a_selector
        );

        $display(
            "  alu_b_selector        Expected=%b Actual=%b",
            expected_alu_b_selector,
            alu_b_selector
        );

        $display(
            "  alu_result_selector   Expected=%b Actual=%b",
            expected_alu_result_selector,
            alu_result_selector
        );

        $display(
            "  result_selector       Expected=%b Actual=%b",
            expected_result_selector,
            result_selector
        );

        $display(
            "  jalr_selector         Expected=%b Actual=%b",
            expected_jalr_selector,
            jalr_selector
        );

    end

end

endtask


initial begin

    $dumpfile("controller.vcd");
    $dumpvars(0, controller_tb);

    opcode = 7'd0;
    funct3 = 3'd0;
    funct7_b5 = 1'b0;

    equal = 1'b0;
    less_than_signed = 1'b0;
    less_than_unsigned = 1'b0;

    pass_count = 0;
    fail_count = 0;
    test_count = 0;

    #1;


    // =========================================================
    // R-TYPE
    // =========================================================

    check_instruction(
        "ADD",
        7'b0110011, 3'b000, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0000, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "SUB",
        7'b0110011, 3'b000, 1'b1,
        1'b0, 1'b0, 1'b0,
        4'b0001, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "SLL",
        7'b0110011, 3'b001, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0110, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "SLT",
        7'b0110011, 3'b010, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0100, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "SLTU",
        7'b0110011, 3'b011, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0111, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "XOR",
        7'b0110011, 3'b100, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0101, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "SRL",
        7'b0110011, 3'b101, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b1000, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "SRA",
        7'b0110011, 3'b101, 1'b1,
        1'b0, 1'b0, 1'b0,
        4'b1001, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "OR",
        7'b0110011, 3'b110, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0011, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "AND",
        7'b0110011, 3'b111, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0010, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0
    );


    // =========================================================
    // I-TYPE ALU
    // =========================================================

    check_instruction(
        "ADDI",
        7'b0010011, 3'b000, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0000, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b1, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "SLLI",
        7'b0010011, 3'b001, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0110, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b1, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "SLTI",
        7'b0010011, 3'b010, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0100, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b1, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "SLTIU",
        7'b0010011, 3'b011, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0111, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b1, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "XORI",
        7'b0010011, 3'b100, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0101, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b1, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "SRLI",
        7'b0010011, 3'b101, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b1000, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b1, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "SRAI",
        7'b0010011, 3'b101, 1'b1,
        1'b0, 1'b0, 1'b0,
        4'b1001, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b1, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "ORI",
        7'b0010011, 3'b110, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0011, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b1, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "ANDI",
        7'b0010011, 3'b111, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0010, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b1, 1'b0, 1'b0, 1'b0
    );


    // =========================================================
    // LOADS
    // =========================================================

    check_instruction(
        "LB",
        7'b0000011, 3'b000, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0000, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b1, 1'b0, 1'b1, 1'b0
    );

    check_instruction(
        "LH",
        7'b0000011, 3'b001, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0000, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b1, 1'b0, 1'b1, 1'b0
    );

    check_instruction(
        "LW",
        7'b0000011, 3'b010, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0000, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b1, 1'b0, 1'b1, 1'b0
    );

    check_instruction(
        "LBU",
        7'b0000011, 3'b100, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0000, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b1, 1'b0, 1'b1, 1'b0
    );

    check_instruction(
        "LHU",
        7'b0000011, 3'b101, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0000, 1'b0, 3'b000, 1'b0, 1'b1,
        1'b0, 1'b1, 1'b0, 1'b1, 1'b0
    );


    // =========================================================
    // STORES
    // =========================================================

    check_instruction(
        "SB",
        7'b0100011, 3'b000, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0000, 1'b1, 3'b001, 1'b0, 1'b0,
        1'b0, 1'b1, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "SH",
        7'b0100011, 3'b001, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0000, 1'b1, 3'b001, 1'b0, 1'b0,
        1'b0, 1'b1, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "SW",
        7'b0100011, 3'b010, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0000, 1'b1, 3'b001, 1'b0, 1'b0,
        1'b0, 1'b1, 1'b0, 1'b0, 1'b0
    );


    // =========================================================
    // BEQ
    // =========================================================

    check_instruction(
        "BEQ NOT TAKEN",
        7'b1100011, 3'b000, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0000, 1'b0, 3'b010, 1'b0, 1'b0,
        1'b1, 1'b1, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "BEQ TAKEN",
        7'b1100011, 3'b000, 1'b0,
        1'b1, 1'b0, 1'b0,
        4'b0000, 1'b0, 3'b010, 1'b1, 1'b0,
        1'b1, 1'b1, 1'b0, 1'b0, 1'b0
    );


    // =========================================================
    // BNE
    // =========================================================

    check_instruction(
        "BNE NOT TAKEN",
        7'b1100011, 3'b001, 1'b0,
        1'b1, 1'b0, 1'b0,
        4'b0000, 1'b0, 3'b010, 1'b0, 1'b0,
        1'b1, 1'b1, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "BNE TAKEN",
        7'b1100011, 3'b001, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0000, 1'b0, 3'b010, 1'b1, 1'b0,
        1'b1, 1'b1, 1'b0, 1'b0, 1'b0
    );


    // =========================================================
    // BLT
    // =========================================================

    check_instruction(
        "BLT NOT TAKEN",
        7'b1100011, 3'b100, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0000, 1'b0, 3'b010, 1'b0, 1'b0,
        1'b1, 1'b1, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "BLT TAKEN",
        7'b1100011, 3'b100, 1'b0,
        1'b0, 1'b1, 1'b0,
        4'b0000, 1'b0, 3'b010, 1'b1, 1'b0,
        1'b1, 1'b1, 1'b0, 1'b0, 1'b0
    );


    // =========================================================
    // BGE
    // =========================================================

    check_instruction(
        "BGE NOT TAKEN",
        7'b1100011, 3'b101, 1'b0,
        1'b0, 1'b1, 1'b0,
        4'b0000, 1'b0, 3'b010, 1'b0, 1'b0,
        1'b1, 1'b1, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "BGE TAKEN",
        7'b1100011, 3'b101, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0000, 1'b0, 3'b010, 1'b1, 1'b0,
        1'b1, 1'b1, 1'b0, 1'b0, 1'b0
    );


    // =========================================================
    // BLTU
    // =========================================================

    check_instruction(
        "BLTU NOT TAKEN",
        7'b1100011, 3'b110, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0000, 1'b0, 3'b010, 1'b0, 1'b0,
        1'b1, 1'b1, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "BLTU TAKEN",
        7'b1100011, 3'b110, 1'b0,
        1'b0, 1'b0, 1'b1,
        4'b0000, 1'b0, 3'b010, 1'b1, 1'b0,
        1'b1, 1'b1, 1'b0, 1'b0, 1'b0
    );


    // =========================================================
    // BGEU
    // =========================================================

    check_instruction(
        "BGEU NOT TAKEN",
        7'b1100011, 3'b111, 1'b0,
        1'b0, 1'b0, 1'b1,
        4'b0000, 1'b0, 3'b010, 1'b0, 1'b0,
        1'b1, 1'b1, 1'b0, 1'b0, 1'b0
    );

    check_instruction(
        "BGEU TAKEN",
        7'b1100011, 3'b111, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0000, 1'b0, 3'b010, 1'b1, 1'b0,
        1'b1, 1'b1, 1'b0, 1'b0, 1'b0
    );


    // =========================================================
    // JAL
    // =========================================================

    check_instruction(
        "JAL",
        7'b1101111, 3'b000, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0000, 1'b0, 3'b011, 1'b1, 1'b1,
        1'b1, 1'b1, 1'b1, 1'b0, 1'b0
    );


    // =========================================================
    // JALR
    // =========================================================

    check_instruction(
        "JALR",
        7'b1100111, 3'b000, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0000, 1'b0, 3'b000, 1'b1, 1'b1,
        1'b0, 1'b1, 1'b1, 1'b0, 1'b1
    );


    // =========================================================
    // LUI
    // =========================================================

    check_instruction(
        "LUI",
        7'b0110111, 3'b000, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b1010, 1'b0, 3'b100, 1'b0, 1'b1,
        1'b0, 1'b1, 1'b0, 1'b0, 1'b0
    );


    // =========================================================
    // AUIPC
    // =========================================================

    check_instruction(
        "AUIPC",
        7'b0010111, 3'b000, 1'b0,
        1'b0, 1'b0, 1'b0,
        4'b0000, 1'b0, 3'b100, 1'b0, 1'b1,
        1'b1, 1'b1, 1'b0, 1'b0, 1'b0
    );


    // =========================================================
    // RESULTS
    // =========================================================

    $display("");
    $display("========================================");
    $display("       CONTROLLER TESTBENCH RESULTS");
    $display("========================================");
    $display("Tests : %0d", test_count);
    $display("Pass  : %0d", pass_count);
    $display("Fail  : %0d", fail_count);
    $display("========================================");

    if (fail_count == 0)
        $display("ALL CONTROLLER TESTS PASSED");
    else
        $fatal(1, "CONTROLLER TESTS FAILED");

    $finish;

end

endmodule