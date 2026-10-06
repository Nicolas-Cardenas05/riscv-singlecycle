`timescale 1ns/1ps

module data_memory_tb;

logic clk;
logic write_enable;
logic [31:0] write_data;
logic [31:0] address;
logic [31:0] read_data;

data_memory dut (
    .clk(clk),
    .write_enable(write_enable),
    .write_data(write_data),
    .address(address),
    .read_data(read_data)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("data_memory.vcd");
    $dumpvars(0, data_memory_tb);

    clk = 0;
    write_enable = 0;
    write_data = 0;
    address = 0;

    // Test 1: write 25 to address 0
    address = 32'd0;
    write_data = 32'd25;
    write_enable = 1;

    @(posedge clk);
    #1;

    write_enable = 0;

    if (read_data === 32'd25)
        $display("PASS: address 0 = 25");
    else
        $error("FAIL: address 0 expected 25, got %0d", read_data);


    // Test 2: write 100 to address 4
    address = 32'd4;
    write_data = 32'd100;
    write_enable = 1;

    @(posedge clk);
    #1;

    write_enable = 0;

    if (read_data === 32'd100)
        $display("PASS: address 4 = 100");
    else
        $error("FAIL: address 4 expected 100, got %0d", read_data);


    // Test 3: read address 0 again
    address = 32'd0;
    #1;

    if (read_data === 32'd25)
        $display("PASS: address 0 still = 25");
    else
        $error("FAIL: address 0 expected 25, got %0d", read_data);


    // Test 4: attempt to write while write_enable = 0
    address = 32'd4;
    write_data = 32'd999;
    write_enable = 0;

    @(posedge clk);
    #1;

    if (read_data === 32'd100)
        $display("PASS: write disabled, address 4 remains 100");
    else
        $error("FAIL: address 4 changed unexpectedly, got %0d", read_data);


    $display("Data memory test finished.");
    $finish;
end

endmodule