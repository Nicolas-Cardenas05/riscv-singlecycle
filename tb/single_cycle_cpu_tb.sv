`timescale 1ns/1ps

module single_cycle_cpu_tb;

logic clk;
logic reset;
logic [15:0] gpio_out;
logic [15:0] gpio_in;
logic trace_done;
integer trace_file;
integer instruction_count;
integer cycle_count;
logic [6:0] segments;
logic [7:0] anodes;
logic dp;

// ==========================================================
// DEVICE UNDER TEST
// ==========================================================

soc_top dut (
    .clk(clk),
    .reset(reset),
    .gpio_in(gpio_in),
    .gpio_out(gpio_out),
    .segments(segments),
    .anodes(anodes),
    .dp(dp)
);

// ==========================================================
// CLOCK GENERATION
// ==========================================================

always #5 clk = ~clk;


// ==========================================================
// RTL EXECUTION TRACE
// ==========================================================

always @(posedge clk) begin

    if (!reset && !trace_done) begin

        // --------------------------------------------------
        // Register write
        // --------------------------------------------------

        if (
            dut.single_cycle_cpu_inst.register_write_enable &&
            (dut.single_cycle_cpu_inst.instruction[11:7] != 5'd0)
        ) begin

            // Load instructions also report memory address
            if (
                dut.single_cycle_cpu_inst.instruction[6:0]
                == 7'b0000011
            ) begin

                $fdisplay(
                    trace_file,
                    "PC=%08h INST=%08h RD=%0d VALUE=%08h MEM=%08h",
                    dut.single_cycle_cpu_inst.pc,
                    dut.single_cycle_cpu_inst.instruction,
                    dut.single_cycle_cpu_inst.instruction[11:7],
                    dut.single_cycle_cpu_inst.result,
                    dut.data_address
                );

            end
            else begin

                $fdisplay(
                    trace_file,
                    "PC=%08h INST=%08h RD=%0d VALUE=%08h",
                    dut.single_cycle_cpu_inst.pc,
                    dut.single_cycle_cpu_inst.instruction,
                    dut.single_cycle_cpu_inst.instruction[11:7],
                    dut.single_cycle_cpu_inst.result
                );

            end

        end

        // --------------------------------------------------
        // Memory store
        // --------------------------------------------------

        else if (dut.data_write_enable) begin

            case (dut.data_funct3)

                // SB
                3'b000: begin

                    $fdisplay(
                        trace_file,
                        "PC=%08h INST=%08h MEM=%08h VALUE=%08h",
                        dut.single_cycle_cpu_inst.pc,
                        dut.single_cycle_cpu_inst.instruction,
                        dut.data_address,
                        {24'd0, dut.data_write[7:0]}
                    );

                end


                // SH
                3'b001: begin

                    $fdisplay(
                        trace_file,
                        "PC=%08h INST=%08h MEM=%08h VALUE=%08h",
                        dut.single_cycle_cpu_inst.pc,
                        dut.single_cycle_cpu_inst.instruction,
                        dut.data_address,
                        {16'd0, dut.data_write[15:0]}
                    );

                end


                // SW
                3'b010: begin

                    $fdisplay(
                        trace_file,
                        "PC=%08h INST=%08h MEM=%08h VALUE=%08h",
                        dut.single_cycle_cpu_inst.pc,
                        dut.single_cycle_cpu_inst.instruction,
                        dut.data_address,
                        dut.data_write
                    );

                end


                default: begin

                    $fdisplay(
                        trace_file,
                        "PC=%08h INST=%08h",
                        dut.single_cycle_cpu_inst.pc,
                        dut.single_cycle_cpu_inst.instruction
                    );

                end

            endcase

        end

        // --------------------------------------------------
        // Instructions without architectural writeback
        // --------------------------------------------------

        else begin

            $fdisplay(
                trace_file,
                "PC=%08h INST=%08h",
                dut.single_cycle_cpu_inst.pc,
                dut.single_cycle_cpu_inst.instruction
            );

        end


        instruction_count = instruction_count + 1;


        // --------------------------------------------------
        // Terminal loop: jal x0, 0
        // --------------------------------------------------

        if (
            dut.single_cycle_cpu_inst.instruction
            == 32'h0000006F
        ) begin

            trace_done = 1'b1;

        end

    end

end


// ==========================================================
// SIMULATED MEMORY-MAPPED OUTPUT PORT
// ==========================================================

always @(posedge clk) begin

    if (
        !reset &&
        dut.data_write_enable &&
        (dut.data_address == 32'h000000F0) &&
        (dut.data_funct3 == 3'b010)
    ) begin

        $display(
            "CPU OUTPUT: %0d (0x%08h)",
            dut.data_write,
            dut.data_write
        );

    end

end


// ==========================================================
// SEVEN-SEGMENT DISPLAY HELPER
// ==========================================================

task automatic show_seven_segment (
    input logic [6:0] segments
);

integer digit;

begin

    case (segments)

        7'h3F: digit = 0;
        7'h06: digit = 1;
        7'h5B: digit = 2;
        7'h4F: digit = 3;
        7'h66: digit = 4;
        7'h6D: digit = 5;
        7'h7D: digit = 6;
        7'h07: digit = 7;
        7'h7F: digit = 8;
        7'h6F: digit = 9;

        default: digit = -1;

    endcase


    $display("");

    $display(
        "7-SEGMENT: digit=%0d pattern=0x%02h",
        digit,
        segments
    );

    $display(
        "    %s",
        segments[0] ? "-----" : "     "
    );

    $display(
        "   %s     %s",
        segments[5] ? "|" : " ",
        segments[1] ? "|" : " "
    );

    $display(
        "   %s     %s",
        segments[5] ? "|" : " ",
        segments[1] ? "|" : " "
    );

    $display(
        "    %s",
        segments[6] ? "-----" : "     "
    );

    $display(
        "   %s     %s",
        segments[4] ? "|" : " ",
        segments[2] ? "|" : " "
    );

    $display(
        "   %s     %s",
        segments[4] ? "|" : " ",
        segments[2] ? "|" : " "
    );

    $display(
        "    %s",
        segments[3] ? "-----" : "     "
    );

    $display("");

end

endtask


// ==========================================================
// SIMULATED SEVEN-SEGMENT DISPLAY
// ==========================================================

always @(posedge clk) begin

    if (
        !reset &&
        dut.data_write_enable &&
        (dut.data_address == 32'h000000F4) &&
        (dut.data_funct3 == 3'b010)
    ) begin

        show_seven_segment(
            dut.data_write[6:0]
        );

    end

end


// ==========================================================
// TEST SEQUENCE
// ==========================================================

initial begin

    gpio_in = 16'd0;

    trace_file = $fopen(
        "build/logs/rtl_trace.log",
        "w"
    );


    if (trace_file == 0) begin

        $fatal(
            1,
            "Could not open build/logs/rtl_trace.log"
        );

    end


    instruction_count = 0;
    cycle_count = 0;

    clk = 1'b0;
    reset = 1'b1;
    trace_done = 1'b0;


    $dumpfile(
        "build/waves/single_cycle_cpu.vcd"
    );

    $dumpvars(
        0,
        single_cycle_cpu_tb
    );


    // --------------------------------------------------
    // RESET
    // --------------------------------------------------

    @(posedge clk);
    #1;

    reset = 1'b0;


    // --------------------------------------------------
    // EXECUTION
    // --------------------------------------------------

    while (
        !trace_done &&
        cycle_count < 5000
    ) begin

        @(posedge clk);

        cycle_count = cycle_count + 1;

    end


    #1;


    // --------------------------------------------------
    // TIMEOUT CHECK
    // --------------------------------------------------

    if (!trace_done) begin

        $fatal(
            1,
            "CPU did not reach terminal loop after %0d cycles",
            cycle_count
        );

    end


    // --------------------------------------------------
    // RESULTS
    // --------------------------------------------------

    $display("");

    $display(
        "========================================"
    );

    $display(
        "      SINGLE-CYCLE SOC TEST RESULTS"
    );

    $display(
        "========================================"
    );


    $display(
        "Executed instructions : %0d",
        instruction_count
    );

    $display(
        "Execution cycles       : %0d",
        cycle_count
    );

    $display(
        "Final PC               : 0x%08h",
        dut.single_cycle_cpu_inst.pc
    );

    $display(
        "Final instruction      : 0x%08h",
        dut.single_cycle_cpu_inst.instruction
    );

    $display(
        "Terminal loop reached  : YES"
    );


    $display(
        "========================================"
    );

    $display(
        "              TEST PASSED"
    );

    $display(
        "========================================"
    );


    $fclose(trace_file);

    $finish;

end

endmodule