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
                        alu_control = 3'b001;
                        register_write_enable = 1'b1;
                    end else begin //add
                        alu_control = 3'b000;
                        register_write_enable = 1'b1;
                    end 
                end

                3'b111 : begin //and
                    alu_control = 3'b010;
                    register_write_enable = 1'b1;
                end

                3'b110 : begin //or
                    alu_control = 3'b011;
                    register_write_enable = 1'b1;
                end

                3'b010 : begin //slt
                    alu_control = 3'b100;
                    register_write_enable = 1'b1;
                end

                default : begin
                end
            endcase
        end

        7'b0010011 : begin //I-type
            case (funct3)
                3'b000 : begin //addi
                    alu_control = 3'b000;
                    register_write_enable = 1'b1;
                    alu_b_selector = 1'b1;
                end

                3'b111 : begin //andi
                    alu_control = 3'b010;
                    register_write_enable = 1'b1;
                    alu_b_selector = 1'b1;
                end

                3'b110 : begin //ori
                    alu_control = 3'b011;
                    register_write_enable = 1'b1;
                    alu_b_selector = 1'b1;
                end

                3'b010 : begin //slti
                    alu_control = 3'b100;
                    register_write_enable = 1'b1;
                    alu_b_selector = 1'b1;
                end

                default : begin
                end
            endcase
        end

        7'b0000011 : begin //I-type
            case (funct3)
                3'b010 : begin //lw
                    alu_control = 3'b000;
                    alu_b_selector = 1'b1;
                    result_selector = 1'b1;
                    register_write_enable = 1'b1;
                end
            
                default : begin
                end
            endcase
        end
        
        7'b0100011 : begin //S-type
            case (funct3)
                3'b010 : begin //sw
                    alu_control = 3'b000;
                    imm_selector = 2'b01;
                    alu_b_selector = 1'b1;
                    memory_write_enable = 1'b1;
                end

                default : begin
                end
            endcase
        end

        7'b1100011 : begin //B-type
            case (funct3)
                3'b000 : begin //beq
                    imm_selector = 2'b10;
                    alu_a_selector = 1'b1;
                    alu_b_selector = 1'b1;

                    if (equal) begin
                        pc_selector = 1'b1;
                    end
                end

                default : begin
                end
            endcase
        end

        7'b1101111 : begin //jal
            imm_selector = 2'b11;
            alu_a_selector = 1'b1;
            alu_b_selector = 1'b1;
            register_write_enable = 1'b1;
            alu_result_selector = 1'b1;
            pc_selector = 1'b1;
        end

        default : begin
        end
    endcase
end
endmodule