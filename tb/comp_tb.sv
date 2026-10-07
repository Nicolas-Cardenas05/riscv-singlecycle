`timescale 1ns/1ps

module comp_tb;

logic [31:0] tb_data_a;
logic [31:0] tb_data_b;

logic tb_equal;
logic tb_less_than_signed;
logic tb_less_than_unsigned;


comp dut (
    .data_a(tb_data_a),
    .data_b(tb_data_b),
    .equal(tb_equal),
    .less_than_signed(tb_less_than_signed),
    .less_than_unsigned(tb_less_than_unsigned)
);


task automatic check_comp (
    input string test_name,
    input logic [31:0] data_a,
    input logic [31:0] data_b,
    input logic expected_equal,
    input logic expected_less_signed,
    input logic expected_less_unsigned
);

begin

    tb_data_a = data_a;
    tb_data_b = data_b;

    #1;

    if (
        (tb_equal === expected_equal) &&
        (tb_less_than_signed === expected_less_signed) &&
        (tb_less_than_unsigned === expected_less_unsigned)
    ) begin

        $display(
            "PASS: %-30s EQ=%b LTS=%b LTU=%b",
            test_name,
            tb_equal,
            tb_less_than_signed,
            tb_less_than_unsigned
        );

    end
    else begin

        $error(
            "FAIL: %-30s",
            test_name
        );

        $display(
            "  equal              Expected=%b Actual=%b",
            expected_equal,
            tb_equal
        );

        $display(
            "  less_than_signed   Expected=%b Actual=%b",
            expected_less_signed,
            tb_less_than_signed
        );

        $display(
            "  less_than_unsigned Expected=%b Actual=%b",
            expected_less_unsigned,
            tb_less_than_unsigned
        );

    end

end

endtask


initial begin

    $dumpfile("comp.vcd");
    $dumpvars(0, comp_tb);


    // --------------------------------------------------
    // EQUAL VALUES
    // --------------------------------------------------

    check_comp(
        "5 == 5",
        32'd5,
        32'd5,
        1'b1,
        1'b0,
        1'b0
    );


    check_comp(
        "0 == 0",
        32'd0,
        32'd0,
        1'b1,
        1'b0,
        1'b0
    );


    // --------------------------------------------------
    // POSITIVE VALUES
    // --------------------------------------------------

    check_comp(
        "5 < 10",
        32'd5,
        32'd10,
        1'b0,
        1'b1,
        1'b1
    );


    check_comp(
        "10 > 5",
        32'd10,
        32'd5,
        1'b0,
        1'b0,
        1'b0
    );


    // --------------------------------------------------
    // SIGNED NEGATIVE VS POSITIVE
    // --------------------------------------------------

    check_comp(
        "-1 < 1",
        32'hFFFFFFFF,
        32'd1,
        1'b0,
        1'b1,
        1'b0
    );


    check_comp(
        "1 vs -1",
        32'd1,
        32'hFFFFFFFF,
        1'b0,
        1'b0,
        1'b1
    );


    // --------------------------------------------------
    // SIGNED NEGATIVE VALUES
    // --------------------------------------------------

    check_comp(
        "-10 < -5",
        -32'sd10,
        -32'sd5,
        1'b0,
        1'b1,
        1'b1
    );


    check_comp(
        "-5 > -10",
        -32'sd5,
        -32'sd10,
        1'b0,
        1'b0,
        1'b0
    );


    // --------------------------------------------------
    // EXTREME SIGNED VALUES
    // --------------------------------------------------

    check_comp(
        "MIN_INT < 0 signed",
        32'h80000000,
        32'd0,
        1'b0,
        1'b1,
        1'b0
    );


    check_comp(
        "MAX_INT < FFFFFFFF unsigned",
        32'h7FFFFFFF,
        32'hFFFFFFFF,
        1'b0,
        1'b0,
        1'b1
    );


    // --------------------------------------------------
    // UNSIGNED EDGE CASE
    // --------------------------------------------------

    check_comp(
        "FFFFFFFF vs 1",
        32'hFFFFFFFF,
        32'd1,
        1'b0,
        1'b1,
        1'b0
    );


    // --------------------------------------------------
    // FINISH
    // --------------------------------------------------

    $display("");
    $display("========================================");
    $display("       COMPARATOR TESTBENCH FINISHED");
    $display("========================================");

    $finish;

end

endmodule