`timescale 1ns/1ps
module pc_adder (
    input logic [31:0] pc,
    output logic [31:0] pc_plus_4
);

always_comb begin : pc_adder
    pc_plus_4 = pc + 32'd4;
end
endmodule