`timescale 1ns/1ps

module soc_top (
    input  logic clk,
    input  logic reset,
    input logic [15:0] gpio_in,
    output logic [15:0] gpio_out,
    output logic [6:0] segments,
    output logic [7:0] anodes,
    output logic dp,

    output logic [3:0] vga_red,
    output logic [3:0] vga_green,
    output logic [3:0] vga_blue,
    output logic vga_hsync,
    output logic vga_vsync,

    input logic btn_up,
    input logic btn_down,
    input logic btn_left,
    input logic btn_right,
    input logic btn_center
);

logic [31:0] data_read;
logic [31:0] data_address;
logic [31:0] data_write;
logic data_write_enable;
logic [2:0] data_funct3;
logic [31:0] debug_pc;

logic data_request;
logic cpu_stall;

logic wb_request;
logic wb_stall;
logic [31:0] wb_data_read;
logic [31:2] wb_adr;
logic [31:0] wb_dat_o;
logic [31:0] wb_dat_i;
logic wb_we;
logic [3:0] wb_sel;
logic wb_cyc;
logic wb_stb;
logic wb_ack;

logic [31:0] leds_wb_dat_o;
logic [31:0] leds_wb_dat_i;
logic leds_wb_we;
logic [3:0] leds_wb_sel;
logic leds_wb_cyc;
logic leds_wb_stb;
logic leds_wb_ack;

logic [31:0] switches_wb_dat_i;
logic switches_wb_we;
logic [3:0] switches_wb_sel;
logic switches_wb_cyc;
logic switches_wb_stb;
logic switches_wb_ack;

logic [31:0] switches_wb_dat_o;
logic [31:0] seven_segment_wb_dat_o;
logic [31:0] seven_segment_wb_dat_i;
logic seven_segment_wb_we;
logic [3:0] seven_segment_wb_sel;
logic seven_segment_wb_cyc;
logic seven_segment_wb_stb;
logic seven_segment_wb_ack;

logic [31:0] ram_wb_dat_o;
logic [31:0] ram_wb_dat_i;
logic ram_wb_we;
logic [3:0] ram_wb_sel;
logic ram_wb_cyc;
logic ram_wb_stb;
logic ram_wb_ack;

logic [31:0] vram_wb_dat_o;
logic [31:0] vram_wb_dat_i;
logic vram_wb_we;
logic [3:0] vram_wb_sel;
logic vram_wb_cyc;
logic vram_wb_stb;
logic vram_wb_ack;

logic [14:0] vga_word_address;
logic [31:0] vga_word_data;

logic [31:0] buttons_wb_dat_i;
logic buttons_wb_cyc;
logic buttons_wb_stb;
logic buttons_wb_ack;

assign cpu_stall = wb_stall;
assign wb_request = data_request;

single_cycle_cpu single_cycle_cpu_inst (
    .clk(clk),
    .reset(reset),
    .data_read(data_read),
    .data_address(data_address),
    .data_write(data_write),
    .data_write_enable(data_write_enable),
    .data_funct3(data_funct3),
    .debug_pc(debug_pc),
    .data_request(data_request),
    .stall(cpu_stall)
);

cpu_wishbone_master cpu_wishbone_master_inst (
    .clk(clk),
    .reset(reset),
    .data_request(wb_request),
    .data_write_enable(data_write_enable),
    .data_address(data_address),
    .data_write(data_write),
    .data_funct3(data_funct3),
    .data_read(wb_data_read),
    .stall(wb_stall),
    .wb_adr_o(wb_adr),
    .wb_dat_o(wb_dat_o),
    .wb_dat_i(wb_dat_i),
    .wb_we_o(wb_we),
    .wb_sel_o(wb_sel),
    .wb_cyc_o(wb_cyc),
    .wb_stb_o(wb_stb),
    .wb_ack_i(wb_ack)
);

wishbone_interconnect wishbone_interconnect_inst (
    .wb_adr_i(wb_adr),
    .wb_dat_i(wb_dat_o),
    .wb_dat_o(wb_dat_i),
    .wb_we_i(wb_we),
    .wb_sel_i(wb_sel),
    .wb_cyc_i(wb_cyc),
    .wb_stb_i(wb_stb),
    .wb_ack_o(wb_ack),

    .leds_dat_o(leds_wb_dat_o),
    .leds_dat_i(leds_wb_dat_i),
    .leds_we_o(leds_wb_we),
    .leds_sel_o(leds_wb_sel),
    .leds_cyc_o(leds_wb_cyc),
    .leds_stb_o(leds_wb_stb),
    .leds_ack_i(leds_wb_ack),

    .switches_dat_o(switches_wb_dat_o),
    .switches_dat_i(switches_wb_dat_i),
    .switches_we_o(switches_wb_we),
    .switches_sel_o(switches_wb_sel),
    .switches_cyc_o(switches_wb_cyc),
    .switches_stb_o(switches_wb_stb),
    .switches_ack_i(switches_wb_ack),

    .seven_segment_dat_o(seven_segment_wb_dat_o),
    .seven_segment_dat_i(seven_segment_wb_dat_i),
    .seven_segment_we_o(seven_segment_wb_we),
    .seven_segment_sel_o(seven_segment_wb_sel),
    .seven_segment_cyc_o(seven_segment_wb_cyc),
    .seven_segment_stb_o(seven_segment_wb_stb),
    .seven_segment_ack_i(seven_segment_wb_ack),

    .ram_dat_o(ram_wb_dat_o),
    .ram_dat_i(ram_wb_dat_i),
    .ram_we_o(ram_wb_we),
    .ram_sel_o(ram_wb_sel),
    .ram_cyc_o(ram_wb_cyc),
    .ram_stb_o(ram_wb_stb),
    .ram_ack_i(ram_wb_ack),

    .vram_dat_o(vram_wb_dat_o),
    .vram_dat_i(vram_wb_dat_i),
    .vram_we_o(vram_wb_we),
    .vram_sel_o(vram_wb_sel),
    .vram_cyc_o(vram_wb_cyc),
    .vram_stb_o(vram_wb_stb),
    .vram_ack_i(vram_wb_ack),

    .buttons_dat_i(buttons_wb_dat_i),
    .buttons_cyc_o(buttons_wb_cyc),
    .buttons_stb_o(buttons_wb_stb),
    .buttons_ack_i(buttons_wb_ack)
);

wishbone_ram wishbone_ram_inst (
    .clk(clk),
    .reset(reset),
    .wb_adr_i(wb_adr),
    .wb_dat_i(ram_wb_dat_o),
    .wb_dat_o(ram_wb_dat_i),
    .wb_we_i(ram_wb_we),
    .wb_sel_i(ram_wb_sel),
    .wb_cyc_i(ram_wb_cyc),
    .wb_stb_i(ram_wb_stb),
    .wb_ack_o(ram_wb_ack)
);

wishbone_vram wishbone_vram_inst (
    .clk(clk),
    .reset(reset),
    .wb_adr_i(wb_adr),
    .wb_dat_i(vram_wb_dat_o),
    .wb_dat_o(vram_wb_dat_i),
    .wb_we_i(vram_wb_we),
    .wb_sel_i(vram_wb_sel),
    .wb_cyc_i(vram_wb_cyc),
    .wb_stb_i(vram_wb_stb),
    .wb_ack_o(vram_wb_ack),
    .vga_word_address(vga_word_address),
    .vga_word_data(vga_word_data)
);

vga_controller vga_controller_inst (
    .clk(clk),
    .reset(reset),
    .vga_word_data(vga_word_data),
    .vga_word_address(vga_word_address),
    .vga_red(vga_red),
    .vga_green(vga_green),
    .vga_blue(vga_blue),
    .vga_hsync(vga_hsync),
    .vga_vsync(vga_vsync)
);

wishbone_leds wishbone_leds_inst (
    .clk(clk),
    .reset(reset),
    .wb_dat_i(leds_wb_dat_o),
    .wb_dat_o(leds_wb_dat_i),
    .wb_we_i(leds_wb_we),
    .wb_sel_i(leds_wb_sel),
    .wb_cyc_i(leds_wb_cyc),
    .wb_stb_i(leds_wb_stb),
    .wb_ack_o(leds_wb_ack),
    .led_out(gpio_out)
);

wishbone_switches wishbone_switches_inst (
    .clk(clk),
    .reset(reset),
    .switch_in(gpio_in),
    .wb_dat_o(switches_wb_dat_i),
    .wb_we_i(switches_wb_we),
    .wb_sel_i(switches_wb_sel),
    .wb_cyc_i(switches_wb_cyc),
    .wb_stb_i(switches_wb_stb),
    .wb_ack_o(switches_wb_ack)
);

wishbone_seven_segment wishbone_seven_segment_inst (
    .clk(clk),
    .reset(reset),
    .wb_dat_i(seven_segment_wb_dat_o),
    .wb_dat_o(seven_segment_wb_dat_i),
    .wb_we_i(seven_segment_wb_we),
    .wb_sel_i(seven_segment_wb_sel),
    .wb_cyc_i(seven_segment_wb_cyc),
    .wb_stb_i(seven_segment_wb_stb),
    .wb_ack_o(seven_segment_wb_ack),
    .segments(segments),
    .anodes(anodes),
    .dp(dp)
);

wishbone_buttons wishbone_buttons_inst (
    .clk(clk),
    .reset(reset),
    .btn_up(btn_up),
    .btn_down(btn_down),
    .btn_left(btn_left),
    .btn_right(btn_right),
    .btn_center(btn_center),
    .wb_dat_o(buttons_wb_dat_i),
    .wb_cyc_i(buttons_wb_cyc),
    .wb_stb_i(buttons_wb_stb),
    .wb_ack_o(buttons_wb_ack)
);

assign data_read = wb_data_read;

endmodule