`timescale 1ns/1ps

module wishbone_vram (
    input logic clk,
    input logic reset,

    input logic [31:2] wb_adr_i,
    input logic [31:0] wb_dat_i,
    output logic [31:0] wb_dat_o,

    input logic wb_we_i,
    input logic [3:0] wb_sel_i,

    input logic wb_cyc_i,
    input logic wb_stb_i,
    output logic wb_ack_o,

    input logic [14:0] vga_word_address,
    output logic [31:0] vga_word_data
);

logic [31:0] memory [0:19199];
logic [14:0] wb_word_address;

assign wb_word_address = wb_adr_i[16:2];


// ------------------------------------------------------------
// WISHBONE port
// ------------------------------------------------------------

always_ff @(posedge clk) begin

    if (reset) begin
        wb_dat_o <= 32'd0;
        wb_ack_o <= 1'b0;
    end

    else begin
        wb_ack_o <= 1'b0;
        if (wb_cyc_i && wb_stb_i && !wb_ack_o) begin

            if (wb_we_i) begin

                if (wb_sel_i[0])
                    memory[wb_word_address][7:0] <= wb_dat_i[7:0];

                if (wb_sel_i[1])
                    memory[wb_word_address][15:8] <= wb_dat_i[15:8];

                if (wb_sel_i[2])
                    memory[wb_word_address][23:16] <= wb_dat_i[23:16];

                if (wb_sel_i[3])
                    memory[wb_word_address][31:24] <= wb_dat_i[31:24];

            end

            else begin
                wb_dat_o <= memory[wb_word_address];
            end
            wb_ack_o <= 1'b1;
        end
    end
end


// ------------------------------------------------------------
// VGA read port
// ------------------------------------------------------------

always_ff @(posedge clk) begin
    vga_word_data <= memory[vga_word_address];
end

endmodule