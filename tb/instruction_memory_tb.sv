`timescale 1ns/1ps

module instruction_memory_tb;

    logic [31:0] tb_pc;
    logic [31:0] tb_instruction;

    instruction_memory dut (
        .pc(tb_pc),
        .instruction(tb_instruction)
    );

    initial begin
        $dumpfile("instruction_memory.vcd");
        $dumpvars(0, instruction_memory_tb);

        // PC = 0 -> first instruction
        tb_pc = 32'd0;
        #1;

        if (tb_instruction === 32'h12345678)
            $display("PASS: PC = 0 -> instruction = 0x12345678");
        else
            $error("FAIL: expected 0x12345678, got 0x%h", tb_instruction);


        // PC = 4 -> second instruction
        tb_pc = 32'd4;
        #1;

        if (tb_instruction === 32'hAABBCCDD)
            $display("PASS: PC = 4 -> instruction = 0xAABBCCDD");
        else
            $error("FAIL: expected 0xAABBCCDD, got 0x%h", tb_instruction);


        // PC = 8 -> third instruction
        tb_pc = 32'd8;
        #1;

        if (tb_instruction === 32'h00000013)
            $display("PASS: PC = 8 -> instruction = 0x00000013");
        else
            $error("FAIL: expected 0x00000013, got 0x%h", tb_instruction);


        // PC = 12 -> fourth instruction
        tb_pc = 32'd12;
        #1;

        if (tb_instruction === 32'hDEADBEEF)
            $display("PASS: PC = 12 -> instruction = 0xDEADBEEF");
        else
            $error("FAIL: expected 0xDEADBEEF, got 0x%h", tb_instruction);


        $display("Instruction memory testbench finished.");
        $finish;
    end

endmodule