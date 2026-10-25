`timescale 1ns/1ps

module wishbone_interconnect (
    input logic [31:2] wb_adr_i,
    input logic [31:0] wb_dat_i,
    output logic [31:0] wb_dat_o,
    input logic wb_we_i,
    input logic [3:0] wb_sel_i,
    input logic wb_cyc_i,
    input logic wb_stb_i,
    output logic wb_ack_o,

    output logic [31:0] leds_dat_o,
    input logic [31:0] leds_dat_i,
    output logic leds_we_o,
    output logic [3:0] leds_sel_o,
    output logic leds_cyc_o,
    output logic leds_stb_o,
    input logic leds_ack_i,

    output logic [31:0] switches_dat_o,
    input logic [31:0] switches_dat_i,
    output logic switches_we_o,
    output logic [3:0] switches_sel_o,
    output logic switches_cyc_o,
    output logic switches_stb_o,
    input logic switches_ack_i,
    
    output logic [31:0] seven_segment_dat_o,
    input logic [31:0] seven_segment_dat_i,
    output logic seven_segment_we_o,
    output logic [3:0] seven_segment_sel_o,
    output logic seven_segment_cyc_o,
    output logic seven_segment_stb_o,
    input logic seven_segment_ack_i,

    output logic [31:0] ram_dat_o,
    input logic [31:0] ram_dat_i,
    output logic ram_we_o,
    output logic [3:0] ram_sel_o,
    output logic ram_cyc_o,
    output logic ram_stb_o,
    input logic ram_ack_i,

    output logic [31:0] vram_dat_o,
    input logic [31:0] vram_dat_i,
    output logic vram_we_o,
    output logic [3:0] vram_sel_o,
    output logic vram_cyc_o,
    output logic vram_stb_o,
    input logic vram_ack_i
);

localparam logic [31:2] LEDS_ADDRESS = 30'h0400_0000;
localparam logic [31:2] SWITCHES_ADDRESS = 30'h0400_0001;
localparam logic [31:2] SEVEN_SEGMENT_ADDRESS = 30'h0400_0400;
localparam logic [31:2] VRAM_BASE = 30'h0800_0000;
localparam logic [31:2] VRAM_END  = 30'h0800_4B00;

always_comb begin
    leds_dat_o = wb_dat_i;
    leds_we_o = wb_we_i;
    leds_sel_o = wb_sel_i;
    leds_cyc_o = 1'b0;
    leds_stb_o = 1'b0;
    switches_dat_o = wb_dat_i;
    switches_we_o = wb_we_i;
    switches_sel_o = wb_sel_i;
    switches_cyc_o = 1'b0;
    switches_stb_o = 1'b0;
    seven_segment_dat_o = wb_dat_i;
    seven_segment_we_o = wb_we_i;
    seven_segment_sel_o = wb_sel_i;
    seven_segment_cyc_o = 1'b0;
    seven_segment_stb_o = 1'b0;
    wb_dat_o = 32'd0;
    wb_ack_o = 1'b0;
    ram_dat_o = wb_dat_i;
    ram_we_o = wb_we_i;
    ram_sel_o = wb_sel_i;
    ram_cyc_o = 1'b0;
    ram_stb_o = 1'b0;
    vram_dat_o = wb_dat_i;
    vram_we_o = wb_we_i;
    vram_sel_o = wb_sel_i;
    vram_cyc_o = 1'b0;
    vram_stb_o = 1'b0;

    if (wb_adr_i < 30'h0000_0400) begin
        ram_cyc_o = wb_cyc_i;
        ram_stb_o = wb_stb_i;
        wb_dat_o = ram_dat_i;
        wb_ack_o = ram_ack_i;
    end

    else if ((wb_adr_i >= VRAM_BASE) && (wb_adr_i < VRAM_END)) begin
        vram_cyc_o = wb_cyc_i;
        vram_stb_o = wb_stb_i;
        wb_dat_o = vram_dat_i;
        wb_ack_o = vram_ack_i;
    end

    else begin
        case (wb_adr_i)

            LEDS_ADDRESS: begin
                leds_cyc_o = wb_cyc_i;
                leds_stb_o = wb_stb_i;
                wb_dat_o = leds_dat_i;
                wb_ack_o = leds_ack_i;
            end

            SWITCHES_ADDRESS: begin
                switches_cyc_o = wb_cyc_i;
                switches_stb_o = wb_stb_i;
                wb_dat_o = switches_dat_i;
                wb_ack_o = switches_ack_i;
            end

            SEVEN_SEGMENT_ADDRESS: begin
                seven_segment_cyc_o = wb_cyc_i;
                seven_segment_stb_o = wb_stb_i;
                wb_dat_o = seven_segment_dat_i;
                wb_ack_o = seven_segment_ack_i;
            end

            default: begin
                wb_dat_o = 32'd0;

                if (wb_cyc_i && wb_stb_i)
                    wb_ack_o = 1'b1;
            end
        endcase
    end
end
endmodule