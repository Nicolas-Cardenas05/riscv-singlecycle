`timescale 1ns/1ps
module alu (
    input logic [31:0] operand_a,
    input logic [31:0] operand_b,
    input logic [2:0] alu_control,
    output logic [31:0] alu_result
);

always_comb begin : alu_logic
   case (alu_control)
    3'b000 : alu_result = operand_a + operand_b;
    3'b001 : alu_result = operand_a - operand_b;
    3'b010 : alu_result = operand_a & operand_b;
    3'b011 : alu_result = operand_a | operand_b;
    3'b100 : begin
        if ($signed(operand_a) < $signed(operand_b)) begin
            alu_result = 32'b1;
        end else begin
            alu_result = 32'b0;
        end
    end
    
    default : alu_result = 32'b0;
endcase 
end
endmodule