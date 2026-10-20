`timescale 1ns/1ps

module leds (
    input  logic clk,
    input  logic reset,
    input  logic write_enable,
    input  logic [31:0] write_data,
    input  logic [2:0] funct3,
    output logic [15:0] led_out,
    output logic [31:0] read_data
);

always_ff @(posedge clk) begin
    if (reset) begin
        led_out <= 16'd0;
    end
    else if (write_enable && (funct3 == 3'b010)) begin
        led_out <= write_data[15:0];
    end
end

assign read_data = {16'd0, led_out};

endmodule