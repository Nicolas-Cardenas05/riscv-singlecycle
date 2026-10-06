`timescale 1ns/1ps
module srcb_mux (
    input logic [31:0] data_b,
    input logic [31:0] immediate,
    input logic alu_b_selector,
    output logic [31:0] src_b
);

always_comb begin : srcb_mux_logic
    case (alu_b_selector)
        1'b0 : src_b = data_b;
        1'b1 : src_b = immediate;
        default : src_b = 32'd0;
    endcase
end
endmodule