`timescale 1ns/1ps

module wishbone_ram (
    input logic clk,
    input logic reset,

    input logic [31:2] wb_adr_i,

    input logic [31:0] wb_dat_i,
    output logic [31:0] wb_dat_o,

    input logic wb_we_i,
    input logic [3:0] wb_sel_i,

    input logic wb_cyc_i,
    input logic wb_stb_i,
    output logic wb_ack_o
);

logic [31:0] memory [0:1023];

assign wb_dat_o = memory[wb_adr_i[11:2]];
assign wb_ack_o = wb_cyc_i && wb_stb_i;

always_ff @(posedge clk) begin
    if (wb_cyc_i && wb_stb_i && wb_we_i) begin
        if (wb_sel_i[0])
            memory[wb_adr_i[11:2]][7:0] <= wb_dat_i[7:0];
        if (wb_sel_i[1])
            memory[wb_adr_i[11:2]][15:8] <= wb_dat_i[15:8];
        if (wb_sel_i[2])
            memory[wb_adr_i[11:2]][23:16] <= wb_dat_i[23:16];
        if (wb_sel_i[3])
            memory[wb_adr_i[11:2]][31:24] <= wb_dat_i[31:24];
    end
end

endmodule