`timescale 1ns/1ps
module controller (
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic funct7_b5,
    input logic equal,
    output logic [2:0] alu_control,
    output logic memory_write_enable,
    output logic [1:0] imm_selector,
    output logic pc_selector,
    output logic register_write_enable,
    output logic alu_a_selector,
    output logic alu_b_selector,
    output logic alu_result_selector,
    output logic result_selector
);

always_comb begin : controller_logic
    alu_control           = 3'b000;
    memory_write_enable   = 1'b0;
    imm_selector          = 2'b00;
    pc_selector           = 1'b0;
    register_write_enable = 1'b0;
    alu_a_selector        = 1'b0;
    alu_b_selector        = 1'b0;
    alu_result_selector   = 1'b0;
    result_selector       = 1'b0;

    case (opcode)
        7'b0110011 : begin //R-type
            case (funct3)
                3'b000 : begin
                    if (funct7_b5) begin //sub

                    end else begin //add

                    end 
                end

                3'b111 : begin //and
                end

                3'b110 : begin //or
                end

                3'b010 : begin //slt
                end

                default :
            endcase
        end

        7'b0010011 : begin //I-type
            case (funct3)
                3'b000 : begin //addi
                end

                3'b111 : begin //andi
                end

                3'b110 : begin //ori
                end

                3'b010 : begin //slti
                end

                default :
            endcase
        end

        7'b0000011 : begin //I-type
            case (funct3)
                3'b010 : begin //lw
                end
            
                default :
            endcase
        end
        
        7'b0100011 : begin //S-type
            case (funct3)
                3'b010 : begin //sw
                end

                default :
            endcase
        end

        7'b1100011 : begin //B-type
            case (funct3)
                3'b000 : begin //beq
                end

                default :
            endcase
        end

        7'b1101111 : begin //jal
          
        end

        default :
    endcase
end
endmodule