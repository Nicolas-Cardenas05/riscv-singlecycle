`timescale 1ns/1ps

module pc_tb;
    logic tb_clk;
    logic tb_reset;
    logic tb_pc_selector;

    logic [31:0] tb_alu_address;
    logic [31:0] tb_pc;
    logic [31:0] tb_pc_plus_4;
    logic [31:0] tb_pc_next;

    pc_register dut_register (
        .clk(tb_clk),
        .reset(tb_reset),
        .pc_next(tb_pc_next),
        .pc(tb_pc)
    );

    pc_adder dut_adder (
        .pc(tb_pc),
        .pc_plus_4(tb_pc_plus_4)
    );

    pc_mux dut_mux (
        .pc_plus_4(tb_pc_plus_4),
        .alu_address(tb_alu_address),
        .pc_selector(tb_pc_selector),
        .pc_next(tb_pc_next)
    );

    // Clock
    always #5 tb_clk = ~tb_clk;

    initial begin
        $dumpfile("pc.vcd");
        $dumpvars(0, pc_tb);

        tb_clk = 1'b0;
        tb_reset = 1'b1;
        tb_pc_selector = 1'b0;
        tb_alu_address = 32'd0;

        // RESET -> PC = 0
        @(posedge tb_clk);
        #1;

        if (tb_pc === 32'd0)
            $display("PASS: RESET -> PC = 0");
        else
            $error("FAIL RESET: expected 0, got %0d", tb_pc);

        // Disable reset
        tb_reset = 1'b0;

        // PC = 4
        @(posedge tb_clk);
        #1;

        if (tb_pc === 32'd4)
            $display("PASS: PC = 4");
        else
            $error("FAIL PC: expected 4, got %0d", tb_pc);

        // PC = 8
        @(posedge tb_clk);
        #1;

        if (tb_pc === 32'd8)
            $display("PASS: PC = 8");
        else
            $error("FAIL PC: expected 8, got %0d", tb_pc);

        // PC = 12
        @(posedge tb_clk);
        #1;

        if (tb_pc === 32'd12)
            $display("PASS: PC = 12");
        else
            $error("FAIL PC: expected 12, got %0d", tb_pc);

        // Simulate branch/jump
        tb_pc_selector = 1'b1;
        tb_alu_address = 32'd100;

        @(posedge tb_clk);
        #1;

        if (tb_pc === 32'd100)
            $display("PASS: JUMP -> PC = 100");
        else
            $error("FAIL JUMP: expected 100, got %0d", tb_pc);

        // Return to PC + 4
        tb_pc_selector = 1'b0;

        @(posedge tb_clk);
        #1;

        if (tb_pc === 32'd104)
            $display("PASS: PC after jump = 104");
        else
            $error("FAIL PC: expected 104, got %0d", tb_pc);


        $display("PC testbench finished.");
        $finish;

    end
    
endmodule