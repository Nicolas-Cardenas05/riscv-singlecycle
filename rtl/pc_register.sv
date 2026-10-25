`timescale 1ns/1ps
module pc_register (
    input logic clk,
    input logic reset,
    input logic [31:0] pc_next,
    input logic enable,
    output logic [31:0] pc
);

always_ff @(posedge clk)
    if (reset) begin
        pc <= 32'd0;
    end else if (enable) begin
        pc <= pc_next;
    end
endmodule