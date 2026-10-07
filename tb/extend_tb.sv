`timescale 1ns/1ps

module extend_tb;

logic [31:7] tb_imm_instruction;
logic [2:0]  tb_imm_selector;
logic [31:0] tb_immediate;


extend dut (
    .imm_instruction(tb_imm_instruction),
    .imm_selector(tb_imm_selector),
    .immediate(tb_immediate)
);


initial begin

    $dumpfile("extend.vcd");
    $dumpvars(0, extend_tb);


    // =========================================================
    // I-TYPE POSITIVE: immediate = 10
    // =========================================================

    tb_imm_instruction = '0;
    tb_imm_selector = 3'b000;

    tb_imm_instruction[31:20] = 12'd10;

    #1;

    if (tb_immediate === 32'd10)
        $display("PASS: I-type positive immediate = 10");
    else
        $error(
            "FAIL I-type positive: expected 10, got %0d",
            tb_immediate
        );


    // =========================================================
    // I-TYPE NEGATIVE: immediate = -5
    // =========================================================

    tb_imm_instruction = '0;
    tb_imm_selector = 3'b000;

    tb_imm_instruction[31:20] = -12'sd5;

    #1;

    if (tb_immediate === -32'sd5)
        $display("PASS: I-type negative immediate = -5");
    else
        $error(
            "FAIL I-type negative: expected -5, got %0d",
            $signed(tb_immediate)
        );


    // =========================================================
    // S-TYPE POSITIVE: immediate = 20
    // =========================================================

    tb_imm_instruction = '0;
    tb_imm_selector = 3'b001;

    tb_imm_instruction[31:25] = 7'd0;
    tb_imm_instruction[11:7]  = 5'd20;

    #1;

    if (tb_immediate === 32'd20)
        $display("PASS: S-type positive immediate = 20");
    else
        $error(
            "FAIL S-type positive: expected 20, got %0d",
            tb_immediate
        );


    // =========================================================
    // S-TYPE NEGATIVE: immediate = -8
    // =========================================================

    tb_imm_instruction = '0;
    tb_imm_selector = 3'b001;

    tb_imm_instruction[31:25] = 7'b1111111;
    tb_imm_instruction[11:7]  = 5'b11000;

    #1;

    if (tb_immediate === -32'sd8)
        $display("PASS: S-type negative immediate = -8");
    else
        $error(
            "FAIL S-type negative: expected -8, got %0d",
            $signed(tb_immediate)
        );


    // =========================================================
    // B-TYPE POSITIVE: immediate = 16
    // =========================================================

    tb_imm_instruction = '0;
    tb_imm_selector = 3'b010;

    tb_imm_instruction[31]    = 1'b0;
    tb_imm_instruction[7]     = 1'b0;
    tb_imm_instruction[30:25] = 6'b000000;
    tb_imm_instruction[11:8]  = 4'b1000;

    #1;

    if (tb_immediate === 32'd16)
        $display("PASS: B-type positive immediate = 16");
    else
        $error(
            "FAIL B-type positive: expected 16, got %0d",
            tb_immediate
        );


    // =========================================================
    // B-TYPE NEGATIVE: immediate = -4
    // =========================================================

    tb_imm_instruction = '0;
    tb_imm_selector = 3'b010;

    tb_imm_instruction[31]    = 1'b1;
    tb_imm_instruction[7]     = 1'b1;
    tb_imm_instruction[30:25] = 6'b111111;
    tb_imm_instruction[11:8]  = 4'b1110;

    #1;

    if (tb_immediate === -32'sd4)
        $display("PASS: B-type negative immediate = -4");
    else
        $error(
            "FAIL B-type negative: expected -4, got %0d",
            $signed(tb_immediate)
        );


    // =========================================================
    // J-TYPE POSITIVE: immediate = 256
    // =========================================================

    tb_imm_instruction = '0;
    tb_imm_selector = 3'b011;

    tb_imm_instruction[31]    = 1'b0;
    tb_imm_instruction[19:12] = 8'd0;
    tb_imm_instruction[20]    = 1'b0;
    tb_imm_instruction[30:21] = 10'd128;

    #1;

    if (tb_immediate === 32'd256)
        $display("PASS: J-type positive immediate = 256");
    else
        $error(
            "FAIL J-type positive: expected 256, got %0d",
            tb_immediate
        );


    // =========================================================
    // J-TYPE NEGATIVE: immediate = -8
    // =========================================================

    tb_imm_instruction = '0;
    tb_imm_selector = 3'b011;

    tb_imm_instruction[31]    = 1'b1;
    tb_imm_instruction[19:12] = 8'b11111111;
    tb_imm_instruction[20]    = 1'b1;
    tb_imm_instruction[30:21] = 10'b1111111100;

    #1;

    if (tb_immediate === -32'sd8)
        $display("PASS: J-type negative immediate = -8");
    else
        $error(
            "FAIL J-type negative: expected -8, got %0d",
            $signed(tb_immediate)
        );


    // =========================================================
    // U-TYPE: immediate = 0x12345000
    // =========================================================

    tb_imm_instruction = '0;
    tb_imm_selector = 3'b100;

    tb_imm_instruction[31:12] = 20'h12345;

    #1;

    if (tb_immediate === 32'h12345000)
        $display("PASS: U-type immediate = 0x12345000");
    else
        $error(
            "FAIL U-type: expected 12345000, got %h",
            tb_immediate
        );


    // =========================================================
    // U-TYPE WITH UPPER BITS SET
    // =========================================================

    tb_imm_instruction = '0;
    tb_imm_selector = 3'b100;

    tb_imm_instruction[31:12] = 20'hFFFFF;

    #1;

    if (tb_immediate === 32'hFFFFF000)
        $display("PASS: U-type immediate = 0xFFFFF000");
    else
        $error(
            "FAIL U-type upper bits: expected FFFFF000, got %h",
            tb_immediate
        );


    // =========================================================
    // INVALID SELECTOR
    // =========================================================

    tb_imm_instruction = '0;
    tb_imm_selector = 3'b111;

    #1;

    if (tb_immediate === 32'd0)
        $display("PASS: invalid selector -> immediate = 0");
    else
        $error(
            "FAIL invalid selector: expected 0, got %h",
            tb_immediate
        );


    // =========================================================
    // FINISH
    // =========================================================

    $display("");
    $display("========================================");
    $display("        EXTEND TESTBENCH FINISHED");
    $display("========================================");

    $finish;

end

endmodule