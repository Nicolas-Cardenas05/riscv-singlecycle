`timescale 1ns/1ps

module wishbone_buttons (
    input  logic        clk,
    input  logic        reset,
    input  logic        btn_up,
    input  logic        btn_down,
    input  logic        btn_left,
    input  logic        btn_right,
    input  logic        btn_center,
    output logic [31:0] wb_dat_o,
    input  logic        wb_cyc_i,
    input  logic        wb_stb_i,
    output logic        wb_ack_o
);

logic [4:0] buttons_meta;
logic [4:0] buttons_sync;

always_ff @(posedge clk) begin
    if (reset) begin
        buttons_meta <= 5'b00000;
        buttons_sync <= 5'b00000;
    end else begin
        buttons_meta <= {
            btn_center,
            btn_right,
            btn_left,
            btn_down,
            btn_up
        };
        buttons_sync <= buttons_meta;
    end
end

always_comb begin
    wb_dat_o = {27'b0, buttons_sync};
    wb_ack_o = wb_cyc_i && wb_stb_i;
end

endmodule