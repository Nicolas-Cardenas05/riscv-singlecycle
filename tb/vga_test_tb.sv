`timescale 1ns/1ps

module vga_test_tb;

logic clk;
logic reset;

logic [15:0] gpio_in;
logic [15:0] gpio_out;

logic [6:0] segments;
logic [7:0] anodes;
logic dp;

logic [3:0] vga_red;
logic [3:0] vga_green;
logic [3:0] vga_blue;

logic vga_hsync;
logic vga_vsync;

integer cycle_count;
integer timeout_count;


soc_top dut (
    .clk(clk),
    .reset(reset),
    .gpio_in(gpio_in),
    .gpio_out(gpio_out),
    .segments(segments),
    .anodes(anodes),
    .dp(dp),
    .vga_red(vga_red),
    .vga_green(vga_green),
    .vga_blue(vga_blue),
    .vga_hsync(vga_hsync),
    .vga_vsync(vga_vsync)
);


always #5 clk = ~clk;


// ------------------------------------------------------------
// Wait for a stable visible pixel
// ------------------------------------------------------------

task automatic check_pixel (
    input logic [9:0] target_y,
    input logic [3:0] expected_red,
    input logic [3:0] expected_green,
    input logic [3:0] expected_blue
);

begin
    timeout_count = 0;
    while (!(dut.vga_controller_inst.vertical_counter == target_y && dut.vga_controller_inst.horizontal_counter == 10'd100 && dut.vga_controller_inst.pixel_divider == 2'b01) && timeout_count < 2000000) begin
        @(posedge clk);
        timeout_count = timeout_count + 1;
    end

    if (timeout_count >= 2000000) begin
        $display("ERROR: Timeout waiting for VGA pixel.");
        $fatal;
    end

    #1;

    if (vga_red !== expected_red || vga_green !== expected_green || vga_blue !== expected_blue) begin

        $display(
            "ERROR: VGA color mismatch at Y=%0d",
            target_y
        );

        $display(
            "Expected RGB = %h %h %h",
            expected_red,
            expected_green,
            expected_blue
        );

        $display(
            "Received RGB = %h %h %h",
            vga_red,
            vga_green,
            vga_blue
        );
        $fatal;
    end

    $display(
        "PASS: VGA Y=%0d RGB=%h%h%h",
        target_y,
        vga_red,
        vga_green,
        vga_blue
    );
end
endtask

// ------------------------------------------------------------
// Test sequence
// ------------------------------------------------------------

initial begin
    clk = 1'b0;
    reset = 1'b1;
    gpio_in = 16'd0;

    cycle_count = 0;
    timeout_count = 0;

    $dumpfile("build/waves/vga_test.vcd");
    $dumpvars(0, vga_test_tb);

    @(posedge clk);
    @(posedge clk);

    #1;
    reset = 1'b0;

    // --------------------------------------------------------
    // Wait until the CPU finishes filling the framebuffer
    // --------------------------------------------------------

    while ((gpio_out !== 16'hFFFF || dut.wishbone_seven_segment_inst.display_value !== 32'h0000_C0DE) && cycle_count < 200000) begin
        @(posedge clk);
        cycle_count = cycle_count + 1;
    end

    if (gpio_out !== 16'hFFFF || dut.wishbone_seven_segment_inst.display_value !== 32'h0000_C0DE) begin
        $display("ERROR: CPU did not finish initialization.");
        $display(
            "gpio_out = 0x%04h",
            gpio_out
        );
        $display(
            "display_value = 0x%08h",
            dut.wishbone_seven_segment_inst.display_value
        );
        $fatal;
    end

    $display("");
    $display("PASS: CPU finished framebuffer initialization.");
    $display("Cycles: %0d", cycle_count);

    // --------------------------------------------------------
    // Verify seven-segment completion value
    // --------------------------------------------------------

    if (dut.wishbone_seven_segment_inst.display_value !== 32'h0000_C0DE) begin
        $display("ERROR: Seven-segment completion value is incorrect.");
        $display(
            "Received: 0x%08h",
            dut.wishbone_seven_segment_inst.display_value
        );
        $fatal;
    end

    $display("PASS: Seven-segment value = 0x0000C0DE");

    // --------------------------------------------------------
    // Verify framebuffer contents
    // --------------------------------------------------------

    if (dut.wishbone_vram_inst.memory[0] !== 32'hE0E0_E0E0)
        $fatal("ERROR: Red framebuffer start incorrect.");

    if (dut.wishbone_vram_inst.memory[4799] !== 32'hE0E0_E0E0)
        $fatal("ERROR: Red framebuffer end incorrect.");

    if (dut.wishbone_vram_inst.memory[4800] !== 32'h1C1C_1C1C)
        $fatal("ERROR: Green framebuffer start incorrect.");

    if (dut.wishbone_vram_inst.memory[9599] !== 32'h1C1C_1C1C)
        $fatal("ERROR: Green framebuffer end incorrect.");

    if (dut.wishbone_vram_inst.memory[9600] !== 32'h0303_0303)
        $fatal("ERROR: Blue framebuffer start incorrect.");

    if (dut.wishbone_vram_inst.memory[14399] !== 32'h0303_0303)
        $fatal("ERROR: Blue framebuffer end incorrect.");

    if (dut.wishbone_vram_inst.memory[14400] !== 32'hFFFF_FFFF)
        $fatal("ERROR: White framebuffer start incorrect.");

    if (dut.wishbone_vram_inst.memory[19199] !== 32'hFFFF_FFFF)
        $fatal("ERROR: White framebuffer end incorrect.");

    $display("PASS: Framebuffer contents are correct.");

    // --------------------------------------------------------
    // Verify VGA colors in the middle of each band
    // --------------------------------------------------------

    check_pixel(
        10'd60,
        4'hF,
        4'h0,
        4'h0
    );

    check_pixel(
        10'd180,
        4'h0,
        4'hF,
        4'h0
    );

    check_pixel(
        10'd300,
        4'h0,
        4'h0,
        4'hF
    );

    check_pixel(
        10'd420,
        4'hF,
        4'hF,
        4'hF
    );

    $display("");
    $display("========================================");
    $display("          VGA SOC TEST PASSED");
    $display("========================================");
    $display("");
    $finish;
end

endmodule