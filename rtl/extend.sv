`timescale 1ns/1ps
module extend (
    input logic [31:7] imm_instruction,
    input logic [1:0] imm_selector,
    output logic [31:0] immediate
);

always_comb begin : extend_logic
    case(imm_selector)
    // I-type
    2'b00 : immediate = {{20{imm_instruction[31]}}, imm_instruction[31:20]};
    // S-type
    2'b01 : immediate = {{20{imm_instruction[31]}}, imm_instruction[31:25], imm_instruction[11:7]};
    // B-type
    2'b10 : immediate = {{20{imm_instruction[31]}}, imm_instruction[7], imm_instruction[30:25], imm_instruction[11:8], 1'b0};
    // J-type
    2'b11 : immediate = {{12{imm_instruction[31]}}, imm_instruction[19:12], imm_instruction[20], imm_instruction[30:21], 1'b0};

    default : immediate = 32'd0;
    endcase
end
endmodule