`timescale 1ns/1ps
module comp (
    input logic [31:0] data_a,
    input logic [31:0] data_b,
    output logic equal
);

assign equal = (data_a == data_b);

endmodule