`timescale 1ns/1ps

module extend_tb;

    logic [31:7] tb_imm_instruction;
    logic [1:0]  tb_imm_selector;
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
    tb_imm_selector = 2'b00;

    tb_imm_instruction[31:20] = 12'd10;

    #1;

    if (tb_immediate === 32'd10)
        $display("PASS: I-type positive immediate = 10");
    else
        $error("FAIL I-type positive: expected 10, got %0d", tb_immediate);


    // =========================================================
    // I-TYPE NEGATIVE: immediate = -5
    // =========================================================
    tb_imm_instruction = '0;
    tb_imm_selector = 2'b00;

    tb_imm_instruction[31:20] = -12'sd5;

    #1;

    if (tb_immediate === -32'sd5)
        $display("PASS: I-type negative immediate = -5");
    else
        $error("FAIL I-type negative: expected -5, got %0d",
               $signed(tb_immediate));


    // =========================================================
    // S-TYPE POSITIVE: immediate = 20
    //
    // imm[11:5] = 0000000
    // imm[4:0]  = 10100
    // =========================================================
    tb_imm_instruction = '0;
    tb_imm_selector = 2'b01;

    tb_imm_instruction[31:25] = 7'd0;
    tb_imm_instruction[11:7]  = 5'd20;

    #1;

    if (tb_immediate === 32'd20)
        $display("PASS: S-type positive immediate = 20");
    else
        $error("FAIL S-type positive: expected 20, got %0d", tb_immediate);


    // =========================================================
    // S-TYPE NEGATIVE: immediate = -8
    //
    // 12-bit -8 = 111111111000
    // imm[11:5] = 1111111
    // imm[4:0]  = 11000
    // =========================================================
    tb_imm_instruction = '0;
    tb_imm_selector = 2'b01;

    tb_imm_instruction[31:25] = 7'b1111111;
    tb_imm_instruction[11:7]  = 5'b11000;

    #1;

    if (tb_immediate === -32'sd8)
        $display("PASS: S-type negative immediate = -8");
    else
        $error("FAIL S-type negative: expected -8, got %0d",
               $signed(tb_immediate));


    // =========================================================
    // B-TYPE POSITIVE: immediate = 16
    //
    // imm[12]   = 0
    // imm[11]   = 0
    // imm[10:5] = 000000
    // imm[4:1]  = 1000
    // imm[0]    = 0
    // =========================================================
    tb_imm_instruction = '0;
    tb_imm_selector = 2'b10;

    tb_imm_instruction[31]    = 1'b0;
    tb_imm_instruction[7]     = 1'b0;
    tb_imm_instruction[30:25] = 6'b000000;
    tb_imm_instruction[11:8]  = 4'b1000;

    #1;

    if (tb_immediate === 32'd16)
        $display("PASS: B-type positive immediate = 16");
    else
        $error("FAIL B-type positive: expected 16, got %0d", tb_immediate);


    // =========================================================
    // B-TYPE NEGATIVE: immediate = -4
    //
    // imm[12]   = 1
    // imm[11]   = 1
    // imm[10:5] = 111111
    // imm[4:1]  = 1110
    // imm[0]    = 0
    // =========================================================
    tb_imm_instruction = '0;
    tb_imm_selector = 2'b10;

    tb_imm_instruction[31]    = 1'b1;
    tb_imm_instruction[7]     = 1'b1;
    tb_imm_instruction[30:25] = 6'b111111;
    tb_imm_instruction[11:8]  = 4'b1110;

    #1;

    if (tb_immediate === -32'sd4)
        $display("PASS: B-type negative immediate = -4");
    else
        $error("FAIL B-type negative: expected -4, got %0d",
               $signed(tb_immediate));


    // =========================================================
    // J-TYPE POSITIVE: immediate = 256
    //
    // imm[20]    = 0
    // imm[19:12] = 00000000
    // imm[11]    = 0
    // imm[10:1]  = 0010000000
    // imm[0]     = 0
    // =========================================================
    tb_imm_instruction = '0;
    tb_imm_selector = 2'b11;

    tb_imm_instruction[31]    = 1'b0;
    tb_imm_instruction[19:12] = 8'd0;
    tb_imm_instruction[20]    = 1'b0;
    tb_imm_instruction[30:21] = 10'd128;

    #1;

    if (tb_immediate === 32'd256)
        $display("PASS: J-type positive immediate = 256");
    else
        $error("FAIL J-type positive: expected 256, got %0d", tb_immediate);


    // =========================================================
    // J-TYPE NEGATIVE: immediate = -8
    //
    // imm[20]    = 1
    // imm[19:12] = 11111111
    // imm[11]    = 1
    // imm[10:1]  = 1111111100
    // imm[0]     = 0
    // =========================================================
    tb_imm_instruction = '0;
    tb_imm_selector = 2'b11;

    tb_imm_instruction[31]    = 1'b1;
    tb_imm_instruction[19:12] = 8'b11111111;
    tb_imm_instruction[20]    = 1'b1;
    tb_imm_instruction[30:21] = 10'b1111111100;

    #1;

    if (tb_immediate === -32'sd8)
        $display("PASS: J-type negative immediate = -8");
    else
        $error("FAIL J-type negative: expected -8, got %0d",
               $signed(tb_immediate));


    $display("Extend testbench finished.");
    $finish;
end

endmodule