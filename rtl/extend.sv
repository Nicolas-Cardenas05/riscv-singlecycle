`timescale 1ns/1ps
module extend (
    input logic [31:7] imm_instruction,
    input logic [2:0] imm_selector,
    output logic [31:0] immediate
);

always_comb begin : extend_logic
    case(imm_selector)
    // I-type
    3'b000 : immediate = {{20{imm_instruction[31]}}, imm_instruction[31:20]};
    // S-type
    3'b001 : immediate = {{20{imm_instruction[31]}}, imm_instruction[31:25], imm_instruction[11:7]};
    // B-type
    3'b010 : immediate = {{20{imm_instruction[31]}}, imm_instruction[7], imm_instruction[30:25], imm_instruction[11:8], 1'b0};
    // J-type
    3'b011 : immediate = {{12{imm_instruction[31]}}, imm_instruction[19:12], imm_instruction[20], imm_instruction[30:21], 1'b0};
    //U-Type
    3'b100: immediate = {imm_instruction[31:12], 12'b0};
    default : immediate = 32'd0;
    endcase
end
endmodule