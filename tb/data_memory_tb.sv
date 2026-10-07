`timescale 1ns/1ps

module data_memory_tb;

logic clk;
logic write_enable;
logic [31:0] write_data;
logic [31:0] address;
logic [2:0] funct3;
logic [31:0] read_data;


data_memory dut (
    .clk(clk),
    .write_enable(write_enable),
    .write_data(write_data),
    .address(address),
    .funct3(funct3),
    .read_data(read_data)
);


// Clock generation
always #5 clk = ~clk;


// Perform a store operation
task automatic store (
    input logic [31:0] test_address,
    input logic [31:0] test_data,
    input logic [2:0] test_funct3
);

begin
    address = test_address;
    write_data = test_data;
    funct3 = test_funct3;
    write_enable = 1'b1;

    @(posedge clk);
    #1;

    write_enable = 1'b0;
end

endtask


// Check a load operation
task automatic check_load (
    input string test_name,
    input logic [31:0] test_address,
    input logic [2:0] test_funct3,
    input logic [31:0] expected_value
);

begin
    address = test_address;
    funct3 = test_funct3;
    write_enable = 1'b0;

    #1;

    if (read_data === expected_value) begin
        $display(
            "PASS: %-30s Expected = %08h, Actual = %08h",
            test_name,
            expected_value,
            read_data
        );
    end
    else begin
        $error(
            "FAIL: %-30s Expected = %08h, Actual = %08h",
            test_name,
            expected_value,
            read_data
        );
    end
end

endtask


// Check an internal 32-bit memory word
task automatic check_memory_word (
    input string test_name,
    input integer word_index,
    input logic [31:0] expected_value
);

begin
    if (dut.memory[word_index] === expected_value) begin
        $display(
            "PASS: %-30s Expected = %08h, Actual = %08h",
            test_name,
            expected_value,
            dut.memory[word_index]
        );
    end
    else begin
        $error(
            "FAIL: %-30s Expected = %08h, Actual = %08h",
            test_name,
            expected_value,
            dut.memory[word_index]
        );
    end
end

endtask


initial begin

    $dumpfile("data_memory.vcd");
    $dumpvars(0, data_memory_tb);

    clk = 1'b0;
    write_enable = 1'b0;
    write_data = 32'd0;
    address = 32'd0;
    funct3 = 3'b010;

    #1;


    // =========================================================
    // SW
    // Store 0xAABBCCDD at address 0
    // =========================================================

    store(
        32'd0,
        32'hAABBCCDD,
        3'b010
    );

    check_memory_word(
        "SW full word",
        0,
        32'hAABBCCDD
    );


    // =========================================================
    // LW
    // =========================================================

    check_load(
        "LW address 0",
        32'd0,
        3'b010,
        32'hAABBCCDD
    );


    // =========================================================
    // LB
    //
    // Little-endian byte layout:
    //
    // Address 0 -> DD
    // Address 1 -> CC
    // Address 2 -> BB
    // Address 3 -> AA
    // =========================================================

    check_load(
        "LB address 0",
        32'd0,
        3'b000,
        32'hFFFFFFDD
    );

    check_load(
        "LB address 1",
        32'd1,
        3'b000,
        32'hFFFFFFCC
    );

    check_load(
        "LB address 2",
        32'd2,
        3'b000,
        32'hFFFFFFBB
    );

    check_load(
        "LB address 3",
        32'd3,
        3'b000,
        32'hFFFFFFAA
    );


    // =========================================================
    // LBU
    // =========================================================

    check_load(
        "LBU address 0",
        32'd0,
        3'b100,
        32'h000000DD
    );

    check_load(
        "LBU address 1",
        32'd1,
        3'b100,
        32'h000000CC
    );

    check_load(
        "LBU address 2",
        32'd2,
        3'b100,
        32'h000000BB
    );

    check_load(
        "LBU address 3",
        32'd3,
        3'b100,
        32'h000000AA
    );


    // =========================================================
    // LH
    //
    // Address 0 -> 0xCCDD
    // Address 2 -> 0xAABB
    // =========================================================

    check_load(
        "LH address 0",
        32'd0,
        3'b001,
        32'hFFFFCCDD
    );

    check_load(
        "LH address 2",
        32'd2,
        3'b001,
        32'hFFFFAABB
    );


    // =========================================================
    // LHU
    // =========================================================

    check_load(
        "LHU address 0",
        32'd0,
        3'b101,
        32'h0000CCDD
    );

    check_load(
        "LHU address 2",
        32'd2,
        3'b101,
        32'h0000AABB
    );


    // =========================================================
    // SB
    //
    // Initial:
    // AABBCCDD
    //
    // Store 0x55 at address 1
    //
    // Expected:
    // AABB55DD
    // =========================================================

    store(
        32'd1,
        32'h00000055,
        3'b000
    );

    check_memory_word(
        "SB address 1",
        0,
        32'hAABB55DD
    );


    // =========================================================
    // SH UPPER HALF
    //
    // Initial:
    // AABB55DD
    //
    // Store 0x1234 at address 2
    //
    // Expected:
    // 123455DD
    // =========================================================

    store(
        32'd2,
        32'h00001234,
        3'b001
    );

    check_memory_word(
        "SH address 2",
        0,
        32'h123455DD
    );


    // =========================================================
    // SH LOWER HALF
    //
    // Initial:
    // 123455DD
    //
    // Store 0xBEEF at address 0
    //
    // Expected:
    // 1234BEEF
    // =========================================================

    store(
        32'd0,
        32'h0000BEEF,
        3'b001
    );

    check_memory_word(
        "SH address 0",
        0,
        32'h1234BEEF
    );


    // =========================================================
    // SW AT NEXT WORD
    // =========================================================

    store(
        32'd4,
        32'h11223344,
        3'b010
    );

    check_memory_word(
        "SW address 4",
        1,
        32'h11223344
    );

    check_load(
        "LW address 4",
        32'd4,
        3'b010,
        32'h11223344
    );


    // =========================================================
    // WRITE ENABLE DISABLED
    //
    // Attempt to overwrite memory[1]
    // =========================================================

    address = 32'd4;
    write_data = 32'hDEADBEEF;
    funct3 = 3'b010;
    write_enable = 1'b0;

    @(posedge clk);
    #1;

    check_memory_word(
        "Write disabled",
        1,
        32'h11223344
    );


    // =========================================================
    // INVALID LOAD FUNCT3
    // =========================================================

    check_load(
        "Invalid load funct3",
        32'd0,
        3'b111,
        32'd0
    );


    // =========================================================
    // FINISH
    // =========================================================

    $display("");
    $display("========================================");
    $display("      DATA MEMORY TESTBENCH FINISHED");
    $display("========================================");

    $finish;

end

endmodule