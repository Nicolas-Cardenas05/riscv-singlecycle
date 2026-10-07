`timescale 1ns/1ps

module comp (
    input logic [31:0] data_a,
    input logic [31:0] data_b,

    output logic equal,
    output logic less_than_signed,
    output logic less_than_unsigned
);

assign equal = (data_a == data_b);

assign less_than_signed =
    ($signed(data_a) < $signed(data_b));

assign less_than_unsigned =
    (data_a < data_b);

endmodule