`timescale 1ns/1ps

module wishbone_leds (
    input logic clk,
    input logic reset,
    input logic [31:0] wb_dat_i,
    output logic [31:0] wb_dat_o,
    input logic wb_we_i,
    input logic [3:0] wb_sel_i,
    input logic wb_cyc_i,
    input logic wb_stb_i,
    output logic wb_ack_o,
    output logic [15:0] led_out
);

assign wb_dat_o = {16'd0, led_out};

assign wb_ack_o = wb_cyc_i && wb_stb_i;

always_ff @(posedge clk) begin

    if (reset) begin
        led_out <= 16'd0;
    end

    else if (wb_cyc_i && wb_stb_i && wb_we_i) begin

        if (wb_sel_i[0])
            led_out[7:0] <= wb_dat_i[7:0];

        if (wb_sel_i[1])
            led_out[15:8] <= wb_dat_i[15:8];
    end

end

endmodule