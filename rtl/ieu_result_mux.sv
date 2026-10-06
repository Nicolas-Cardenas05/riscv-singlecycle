`timescale 1ns/1ps
module ieu_result_mux (
    input logic [31:0] alu_result,
    input logic [31:0] pc_plus_4,
    input logic alu_result_selector,
    output logic [31:0] ieu_result
);

always_comb begin : ieu_result_mux_logic
    case (alu_result_selector)
        1'b0 : ieu_result = alu_result;
        1'b1 : ieu_result = pc_plus_4;
        default : ieu_result = 32'd0;
    endcase
end
endmodule