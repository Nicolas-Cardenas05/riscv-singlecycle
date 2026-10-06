`timescale 1ns/1ps

module single_cycle_cpu_tb;

logic clk;
logic reset;

single_cycle_cpu dut (
    .clk(clk),
    .reset(reset)
);

// Clock generation
always #5 clk = ~clk;


// Check a 32-bit value
task automatic check_value (
    input string test_name,
    input logic [31:0] actual_value,
    input logic [31:0] expected_value
);

begin
    if (actual_value === expected_value) begin
        $display(
            "PASS: %-20s Expected = %0d, Actual = %0d",
            test_name,
            expected_value,
            actual_value
        );
    end else begin
        $error(
            "FAIL: %-20s Expected = %0d, Actual = %0d",
            test_name,
            expected_value,
            actual_value
        );
    end
end

endtask


initial begin

    $dumpfile("single_cycle_cpu.vcd");
    $dumpvars(0, single_cycle_cpu_tb);

    clk = 1'b0;
    reset = 1'b1;

    // Hold reset until a clock edge
    @(posedge clk);
    #1;

    reset = 1'b0;

    // Execute enough cycles to reach the final infinite loop
    repeat (20) begin
        @(posedge clk);
    end

    #1;

    $display("");
    $display("========================================");
    $display("      SINGLE-CYCLE CPU TEST RESULTS");
    $display("========================================");


    // Register tests
    check_value(
        "x1",
        dut.register_file_inst.registers[1],
        32'd5
    );

    check_value(
        "x2",
        dut.register_file_inst.registers[2],
        32'd10
    );

    check_value(
        "x3 ADD",
        dut.register_file_inst.registers[3],
        32'd15
    );

    check_value(
        "x4 SUB",
        dut.register_file_inst.registers[4],
        32'd5
    );

    check_value(
        "x5 AND",
        dut.register_file_inst.registers[5],
        32'd0
    );

    check_value(
        "x6 OR",
        dut.register_file_inst.registers[6],
        32'd15
    );

    check_value(
        "x7 SLT",
        dut.register_file_inst.registers[7],
        32'd1
    );

    check_value(
        "x8 ANDI",
        dut.register_file_inst.registers[8],
        32'd7
    );

    check_value(
        "x9 ORI",
        dut.register_file_inst.registers[9],
        32'd3
    );

    check_value(
        "x10 SLTI",
        dut.register_file_inst.registers[10],
        32'd1
    );

    check_value(
        "x11 LW",
        dut.register_file_inst.registers[11],
        32'd15
    );

    check_value(
        "x12 BEQ taken",
        dut.register_file_inst.registers[12],
        32'd42
    );

    check_value(
        "x13 BEQ not taken",
        dut.register_file_inst.registers[13],
        32'd7
    );

    check_value(
        "x14 JAL return address",
        dut.register_file_inst.registers[14],
        32'd72
    );

    check_value(
        "x15 JAL target",
        dut.register_file_inst.registers[15],
        32'd11
    );


    // Data memory test
    check_value(
        "Memory[0] SW",
        dut.data_memory_inst.memory[0],
        32'd15
    );


    // Final PC test
    check_value(
        "Final PC",
        dut.pc,
        32'd80
    );


    $display("");
    $display("========================================");
    $display("             TEST FINISHED");
    $display("========================================");

    $finish;

end

endmodule