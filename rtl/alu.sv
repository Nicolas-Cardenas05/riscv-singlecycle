`timescale 1ns/1ps
module alu (
    input logic [31:0] operand_a,
    input logic [31:0] operand_b,
    input logic [3:0] alu_control,
    output logic [31:0] alu_result,
    output logic [31:0] alu_address
);

assign alu_address = operand_a + operand_b;

always_comb begin : alu_logic
    case (alu_control)
        4'b0000: alu_result = operand_a + operand_b;
        4'b0001: alu_result = operand_a - operand_b;
        4'b0010: alu_result = operand_a & operand_b;
        4'b0011: alu_result = operand_a | operand_b;

        4'b0100: begin
            if ($signed(operand_a) < $signed(operand_b))
                alu_result = 32'd1;
            else
                alu_result = 32'd0;
        end

        4'b0101: alu_result = operand_a ^ operand_b;

        4'b0110: alu_result = operand_a << operand_b[4:0];

        4'b0111: begin
            if (operand_a < operand_b)
                alu_result = 32'd1;
            else
                alu_result = 32'd0;
        end

        4'b1000: alu_result = operand_a >> operand_b[4:0];

        4'b1001: alu_result =
            $signed(operand_a) >>> operand_b[4:0];

        4'b1010: alu_result = operand_b;

        default: alu_result = 32'd0;
    endcase 
end
endmodule