`timescale 1ns/1ps
module srca_mux (
    input logic [31:0] data_a,
    input logic [31:0] pc,
    input logic alu_a_selector,
    output logic [31:0] src_a
);

always_comb begin : srca_mux_logic
    case (alu_a_selector)
        1'b0 : src_a = data_a;
        1'b1 : src_a = pc;
        default : src_a = 32'd0;
    endcase
end
endmodule