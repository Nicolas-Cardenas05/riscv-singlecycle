`timescale 1ns/1ps

module register_file_tb;
    logic tb_clk;
    logic tb_write_enable;
    logic [4:0] tb_address_a;
    logic [4:0] tb_address_b;
    logic [4:0] tb_address_result;
    logic [31:0] tb_write_data;
    logic [31:0] tb_read_data_a;
    logic [31:0] tb_read_data_b;

register_file dut (
    .clk(tb_clk),
    .write_enable(tb_write_enable),
    .address_a(tb_address_a),
    .address_b(tb_address_b),
    .address_result(tb_address_result),
    .write_data(tb_write_data),
    .read_data_a(tb_read_data_a),
    .read_data_b(tb_read_data_b)
);

initial begin
    tb_clk = 1'b0;
end

always #5 tb_clk = ~tb_clk;

initial begin
    $dumpfile("register_file.vcd");
    $dumpvars(0, register_file_tb);

    tb_write_enable = 1'b1;
    tb_address_result = 5'd6;
    tb_write_data = 32'd25;
    @(posedge tb_clk);
    #1;
    tb_address_a = 5'd6;
    tb_address_b = 5'd0;
    #1;

    if (tb_read_data_a === 32'd25)
        $display("PASS: x6 read through port A = d25");
    else
        $error("FAIL: expected d25, got %0d", tb_read_data_a);

    if (tb_read_data_b === 32'd0)
        $display("PASS: x0 = 0");
    else
        $error("FAIL: x0 should be 0, got %0d", tb_read_data_b);
    
    tb_write_enable = 1'b0;
    tb_address_result = 5'd6;
    tb_write_data = 32'd70;
    @(posedge tb_clk);
    #1;
    tb_address_a = 5'd6;
    tb_address_b = 5'd0;
    #1;

    if (tb_read_data_a === 32'd25)
        $display("PASS: x6 read through port A = d25, write_enable = 0 so x6 not changed");
    else
        $error("FAIL: expected d25, got %0d", tb_read_data_a);

    if (tb_read_data_b === 32'd0)
        $display("PASS: x0 = 0");
    else
        $error("FAIL: x0 should be d0, got %0d", tb_read_data_b);

    tb_write_enable = 1'b1;
    tb_address_result = 5'd0;
    tb_write_data = 32'd70;
    @(posedge tb_clk);
    #1;
    tb_address_a = 5'd6;
    tb_address_b = 5'd0;
    #1;

    if (tb_read_data_a === 32'd25)
        $display("PASS: write to x0 ignored");
    else
        $error("FAIL: expected d25, got %0d", tb_read_data_a);

    if (tb_read_data_b === 32'd0)
        $display("PASS: x0 = 0");
    else
        $error("FAIL: x0 should be d0, got %0d", tb_read_data_b);

    tb_write_enable = 1'b1;
    tb_address_result = 5'd1;
    tb_write_data = 32'd70;
    @(posedge tb_clk);
    #1;
    tb_address_a = 5'd6;
    tb_address_b = 5'd1;
    #1;

    if (tb_read_data_a === 32'd25)
        $display("PASS: x6 read through port A = d25, x6 not changed");
    else
        $error("FAIL: expected d25, got %0d", tb_read_data_a);

    if (tb_read_data_b === 32'd70)
        $display("PASS: x1 read through port B = d70");
    else
        $error("FAIL: x1 should be d70, got %0d", tb_read_data_b);

    $finish;
end
endmodule
