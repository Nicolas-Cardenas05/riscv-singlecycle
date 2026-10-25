`timescale 1ns/1ps

module soc_top_tb;

logic clk;
logic reset;

logic [15:0] gpio_in;
logic [15:0] gpio_out;

logic [6:0] segments;
logic [7:0] anodes;
logic dp;

logic previous_wait;

logic [31:2] previous_wb_adr;
logic [31:0] previous_wb_dat_o;
logic previous_wb_we;
logic [3:0] previous_wb_sel;

integer wishbone_transfers;
integer wishbone_reads;
integer wishbone_writes;

soc_top dut (
    .clk(clk),
    .reset(reset),
    .gpio_in(gpio_in),
    .gpio_out(gpio_out),
    .segments(segments),
    .anodes(anodes),
    .dp(dp)
);


initial begin
    clk = 1'b0;

    forever begin
        #5 clk = ~clk;
    end
end

always @(posedge clk) begin

    if (reset) begin

        previous_wait <= 1'b0;

        previous_wb_adr <= 30'd0;
        previous_wb_dat_o <= 32'd0;
        previous_wb_we <= 1'b0;
        previous_wb_sel <= 4'd0;

        wishbone_transfers <= 0;
        wishbone_reads <= 0;
        wishbone_writes <= 0;

    end

    else begin

        // ACK must only be asserted during a valid WISHBONE transfer.
        if (dut.wb_ack && !(dut.wb_cyc && dut.wb_stb)) begin
            $display("WISHBONE ERROR: ACK asserted without CYC and STB.");
            $fatal;
        end


        // STB must only be valid while CYC is asserted.
        if (dut.wb_stb && !dut.wb_cyc) begin
            $display("WISHBONE ERROR: STB asserted while CYC is low.");
            $fatal;
        end


        // If the previous transfer was waiting for ACK,
        // the master must keep the transaction active and stable.
        if (previous_wait) begin

            if (!(dut.wb_cyc && dut.wb_stb)) begin
                $display("WISHBONE ERROR: Master terminated transfer before ACK.");
                $fatal;
            end

            if (dut.wb_adr !== previous_wb_adr) begin
                $display("WISHBONE ERROR: ADR changed while waiting for ACK.");
                $fatal;
            end

            if (dut.wb_dat_o !== previous_wb_dat_o) begin
                $display("WISHBONE ERROR: DAT_O changed while waiting for ACK.");
                $fatal;
            end

            if (dut.wb_we !== previous_wb_we) begin
                $display("WISHBONE ERROR: WE changed while waiting for ACK.");
                $fatal;
            end

            if (dut.wb_sel !== previous_wb_sel) begin
                $display("WISHBONE ERROR: SEL changed while waiting for ACK.");
                $fatal;
            end

        end


        // Count completed WISHBONE transfers.
        if (dut.wb_cyc && dut.wb_stb && dut.wb_ack) begin

            wishbone_transfers <= wishbone_transfers + 1;

            if (dut.wb_we)
                wishbone_writes <= wishbone_writes + 1;
            else
                wishbone_reads <= wishbone_reads + 1;

        end


        previous_wait <= dut.wb_cyc &&
                         dut.wb_stb &&
                         !dut.wb_ack;

        previous_wb_adr <= dut.wb_adr;
        previous_wb_dat_o <= dut.wb_dat_o;
        previous_wb_we <= dut.wb_we;
        previous_wb_sel <= dut.wb_sel;

    end

end

initial begin

    $dumpfile("soc_top.vcd");
    $dumpvars(0, soc_top_tb);

    reset = 1'b1;
    gpio_in = 16'hA53C;

    #20;

    reset = 1'b0;

    // Allow enough time for the CPU to initialize
    // and execute several WISHBONE transactions.
    repeat (100) @(posedge clk);


    if (gpio_out !== 16'hA53C) begin
        $display("ERROR: LEDs do not match switches.");
        $display("Expected: 0xA53C");
        $display("Received: 0x%04h", gpio_out);
        $fatal;
    end

    else begin
        $display("PASS: LEDs match switches.");
        $display("gpio_in  = 0x%04h", gpio_in);
        $display("gpio_out = 0x%04h", gpio_out);
    end


    if (dut.wishbone_seven_segment_inst.display_value !== 32'h0000_A53C) begin
        $display("ERROR: Seven-segment register does not match switches.");
        $display("Expected: 0x0000A53C");
        $display(
            "Received: 0x%08h",
            dut.wishbone_seven_segment_inst.display_value
        );
        $fatal;
    end

    else begin
        $display("PASS: Seven-segment register matches switches.");
        $display(
            "display_value = 0x%08h",
            dut.wishbone_seven_segment_inst.display_value
        );
    end


    // Change the switches to verify repeated bus transactions.
    gpio_in = 16'h1234;

    repeat (100) @(posedge clk);


    if (gpio_out !== 16'h1234) begin
        $display("ERROR: LEDs did not update after switch change.");
        $display("Expected: 0x1234");
        $display("Received: 0x%04h", gpio_out);
        $fatal;
    end


    if (dut.wishbone_seven_segment_inst.display_value !== 32'h0000_1234) begin
        $display("ERROR: Seven-segment did not update after switch change.");
        $display("Expected: 0x00001234");
        $display(
            "Received: 0x%08h",
            dut.wishbone_seven_segment_inst.display_value
        );
        $fatal;
    end


    $display("");
    $display("========================================");
    $display(" WISHBONE SoC TEST PASSED");
    $display("========================================");
    $display("");

    $display("");
    $display("WISHBONE transactions: %0d", wishbone_transfers);
    $display("WISHBONE reads:        %0d", wishbone_reads);
    $display("WISHBONE writes:       %0d", wishbone_writes);

    $finish;

end

endmodule