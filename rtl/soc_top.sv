`timescale 1ns/1ps

module soc_top (
    input  logic clk,
    input  logic reset,
    input logic [15:0] gpio_in,
    output logic [15:0] gpio_out,
    output logic [6:0] segments,
    output logic [7:0] anodes,
    output logic dp
);

logic [31:0] data_read;
logic [31:0] data_address;
logic [31:0] data_write;
logic data_write_enable;
logic [2:0] data_funct3;
logic [31:0] debug_pc;
logic [31:0] ram_read_data;
logic ram_select;
logic ram_write_enable;
logic [31:0] leds_read_data;
logic leds_select;
logic leds_write_enable;
logic [31:0] switches_read_data;
logic switches_select;
logic [31:0] seven_segment_read_data;
logic seven_segment_select;
logic seven_segment_write_enable;

assign ram_select = (data_address < 32'h0000_1000);
assign leds_select = (data_address == 32'h1000_0000);
assign switches_select = (data_address == 32'h10000004);
assign seven_segment_select = (data_address == 32'h1000_1000);
assign ram_write_enable = data_write_enable && ram_select;
assign leds_write_enable = data_write_enable && leds_select;
assign seven_segment_write_enable = data_write_enable && seven_segment_select;

single_cycle_cpu single_cycle_cpu_inst (
    .clk(clk),
    .reset(reset),
    .data_read(data_read),
    .data_address(data_address),
    .data_write(data_write),
    .data_write_enable(data_write_enable),
    .data_funct3(data_funct3),
    .debug_pc(debug_pc)
);

data_memory data_memory_inst (
    .clk(clk),
    .write_enable(ram_write_enable),
    .write_data(data_write),
    .address(data_address),
    .funct3(data_funct3),
    .read_data(ram_read_data)
);

leds leds_inst (
    .clk(clk),
    .reset(reset),
    .write_enable(leds_write_enable),
    .write_data(data_write),
    .funct3(data_funct3),
    .led_out(gpio_out),
    .read_data(leds_read_data)
);

switches switches_inst (
    .switch_in(gpio_in),
    .read_data(switches_read_data)
);

show_seven_segment show_seven_segment_inst (
    .clk(clk),
    .reset(reset),
    .write_enable(seven_segment_write_enable),
    .write_data(data_write),
    .funct3(data_funct3),
    .segments(segments),
    .anodes(anodes),
    .dp(dp),
    .read_data(seven_segment_read_data)
);

always_comb begin
    if (ram_select) begin
        data_read = ram_read_data;
    end
    else if (leds_select) begin
        data_read = leds_read_data;
    end
    else if (switches_select) begin
        data_read = switches_read_data;
    end
    else if (seven_segment_select) begin
        data_read = seven_segment_read_data;
    end
    else begin
        data_read = 32'd0;
    end
end

endmodule