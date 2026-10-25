`timescale 1ns/1ps

module wishbone_switches (
    input  logic clk,
    input  logic reset,
    input  logic [15:0] switch_in,
    output logic [31:0] wb_dat_o,
    input  logic wb_we_i,
    input  logic [3:0] wb_sel_i,
    input  logic wb_cyc_i,
    input  logic wb_stb_i,
    output logic wb_ack_o
);

always_ff @(posedge clk) begin
    if (reset) begin
        wb_ack_o <= 1'b0;
    end

    else begin
        if (wb_cyc_i && wb_stb_i && !wb_ack_o) begin
            wb_ack_o <= 1'b1;
        end
        else begin
            wb_ack_o <= 1'b0;
        end
    end
end

always_comb begin
    wb_dat_o = {16'd0, switch_in};
end

endmodule