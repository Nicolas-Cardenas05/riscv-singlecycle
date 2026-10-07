`timescale 1ns/1ps

module alu_tb;

logic [31:0] tb_operand_a;
logic [31:0] tb_operand_b;
logic [3:0]  tb_alu_control;
logic [31:0] tb_alu_result;
logic [31:0] tb_alu_address;


alu dut (
    .operand_a(tb_operand_a),
    .operand_b(tb_operand_b),
    .alu_control(tb_alu_control),
    .alu_result(tb_alu_result),
    .alu_address(tb_alu_address)
);


// Test an ALU operation
task automatic check_alu (
    input string test_name,
    input logic [3:0] control,
    input logic [31:0] operand_a,
    input logic [31:0] operand_b,
    input logic [31:0] expected_result
);

begin
    tb_alu_control = control;
    tb_operand_a = operand_a;
    tb_operand_b = operand_b;

    #1;

    if (tb_alu_result === expected_result) begin
        $display(
            "PASS: %-25s Expected = %h, Actual = %h",
            test_name,
            expected_result,
            tb_alu_result
        );
    end
    else begin
        $error(
            "FAIL: %-25s Expected = %h, Actual = %h",
            test_name,
            expected_result,
            tb_alu_result
        );
    end
end

endtask


initial begin

    $dumpfile("alu.vcd");
    $dumpvars(0, alu_tb);


    // --------------------------------------------------
    // ADD
    // --------------------------------------------------

    check_alu(
        "ADD 15 + 5",
        4'b0000,
        32'd15,
        32'd5,
        32'd20
    );


    // --------------------------------------------------
    // SUB
    // --------------------------------------------------

    check_alu(
        "SUB 15 - 5",
        4'b0001,
        32'd15,
        32'd5,
        32'd10
    );


    // --------------------------------------------------
    // AND
    // --------------------------------------------------

    check_alu(
        "AND",
        4'b0010,
        32'd255,
        32'd1023,
        32'd255
    );


    // --------------------------------------------------
    // OR
    // --------------------------------------------------

    check_alu(
        "OR",
        4'b0011,
        32'd255,
        32'd1023,
        32'd1023
    );


    // --------------------------------------------------
    // SLT SIGNED
    // --------------------------------------------------

    check_alu(
        "SLT -5 < 3",
        4'b0100,
        32'hFFFFFFFB,
        32'd3,
        32'd1
    );

    check_alu(
        "SLT 10 < 3",
        4'b0100,
        32'd10,
        32'd3,
        32'd0
    );


    // --------------------------------------------------
    // XOR
    // --------------------------------------------------

    check_alu(
        "XOR 0x0F ^ 0x05",
        4'b0101,
        32'h0000000F,
        32'h00000005,
        32'h0000000A
    );


    // --------------------------------------------------
    // SLL
    // --------------------------------------------------

    check_alu(
        "SLL 1 << 4",
        4'b0110,
        32'd1,
        32'd4,
        32'd16
    );

    // Only operand_b[4:0] must be used as shift amount
    check_alu(
        "SLL lower 5 bits",
        4'b0110,
        32'd1,
        32'd36,
        32'd16
    );


    // --------------------------------------------------
    // SLTU
    // --------------------------------------------------

    check_alu(
        "SLTU FFFFFFFF < 1",
        4'b0111,
        32'hFFFFFFFF,
        32'd1,
        32'd0
    );

    check_alu(
        "SLTU 1 < FFFFFFFF",
        4'b0111,
        32'd1,
        32'hFFFFFFFF,
        32'd1
    );


    // --------------------------------------------------
    // SRL
    // --------------------------------------------------

    check_alu(
        "SRL 80000000 >> 4",
        4'b1000,
        32'h80000000,
        32'd4,
        32'h08000000
    );


    // --------------------------------------------------
    // SRA
    // --------------------------------------------------

    check_alu(
        "SRA 80000000 >>> 4",
        4'b1001,
        32'h80000000,
        32'd4,
        32'hF8000000
    );

    check_alu(
        "SRA 70000000 >>> 4",
        4'b1001,
        32'h70000000,
        32'd4,
        32'h07000000
    );


    // --------------------------------------------------
    // PASS_B
    // --------------------------------------------------

    check_alu(
        "PASS_B",
        4'b1010,
        32'hAAAAAAAA,
        32'h12345000,
        32'h12345000
    );


    // --------------------------------------------------
    // INVALID CONTROL
    // --------------------------------------------------

    check_alu(
        "DEFAULT",
        4'b1111,
        32'd20,
        32'd30,
        32'd0
    );


    // --------------------------------------------------
    // ALU ADDRESS
    // --------------------------------------------------

    tb_operand_a = 32'd100;
    tb_operand_b = 32'd20;
    tb_alu_control = 4'b1001;

    #1;

    if (tb_alu_address === 32'd120) begin
        $display(
            "PASS: ALU address             Expected = %h, Actual = %h",
            32'd120,
            tb_alu_address
        );
    end
    else begin
        $error(
            "FAIL: ALU address             Expected = %h, Actual = %h",
            32'd120,
            tb_alu_address
        );
    end


    // --------------------------------------------------
    // FINISH
    // --------------------------------------------------

    $display("");
    $display("========================================");
    $display("          ALU TESTBENCH FINISHED");
    $display("========================================");

    $finish;

end

endmodule