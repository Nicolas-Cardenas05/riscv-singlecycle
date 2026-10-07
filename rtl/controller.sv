`timescale 1ns/1ps

module controller (
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic funct7_b5,

    input logic equal,
    input logic less_than_signed,
    input logic less_than_unsigned,

    output logic [3:0] alu_control,
    output logic memory_write_enable,
    output logic [2:0] imm_selector,
    output logic pc_selector,
    output logic register_write_enable,
    output logic alu_a_selector,
    output logic alu_b_selector,
    output logic alu_result_selector,
    output logic result_selector,
    output logic jalr_selector
);

always_comb begin : controller_logic

    // Default control values
    alu_control           = 4'b0000;
    memory_write_enable   = 1'b0;
    imm_selector          = 3'b000;
    pc_selector           = 1'b0;
    register_write_enable = 1'b0;
    alu_a_selector        = 1'b0;
    alu_b_selector        = 1'b0;
    alu_result_selector   = 1'b0;
    result_selector       = 1'b0;
    jalr_selector         = 1'b0;


    case (opcode)

        // ==================================================
        // R-TYPE
        // ==================================================
        7'b0110011: begin

            case (funct3)

                // ADD / SUB
                3'b000: begin
                    register_write_enable = 1'b1;

                    if (funct7_b5)
                        alu_control = 4'b0001; // SUB
                    else
                        alu_control = 4'b0000; // ADD
                end


                // SLL
                3'b001: begin
                    alu_control = 4'b0110;
                    register_write_enable = 1'b1;
                end


                // SLT
                3'b010: begin
                    alu_control = 4'b0100;
                    register_write_enable = 1'b1;
                end


                // SLTU
                3'b011: begin
                    alu_control = 4'b0111;
                    register_write_enable = 1'b1;
                end


                // XOR
                3'b100: begin
                    alu_control = 4'b0101;
                    register_write_enable = 1'b1;
                end


                // SRL / SRA
                3'b101: begin
                    register_write_enable = 1'b1;

                    if (funct7_b5)
                        alu_control = 4'b1001; // SRA
                    else
                        alu_control = 4'b1000; // SRL
                end


                // OR
                3'b110: begin
                    alu_control = 4'b0011;
                    register_write_enable = 1'b1;
                end


                // AND
                3'b111: begin
                    alu_control = 4'b0010;
                    register_write_enable = 1'b1;
                end


                default: begin
                end

            endcase

        end


        // ==================================================
        // I-TYPE ALU
        // ==================================================
        7'b0010011: begin

            alu_b_selector = 1'b1;
            register_write_enable = 1'b1;
            imm_selector = 3'b000;

            case (funct3)

                // ADDI
                3'b000: begin
                    alu_control = 4'b0000;
                end


                // SLLI
                3'b001: begin
                    alu_control = 4'b0110;
                end


                // SLTI
                3'b010: begin
                    alu_control = 4'b0100;
                end


                // SLTIU
                3'b011: begin
                    alu_control = 4'b0111;
                end


                // XORI
                3'b100: begin
                    alu_control = 4'b0101;
                end


                // SRLI / SRAI
                3'b101: begin
                    if (funct7_b5)
                        alu_control = 4'b1001; // SRAI
                    else
                        alu_control = 4'b1000; // SRLI
                end


                // ORI
                3'b110: begin
                    alu_control = 4'b0011;
                end


                // ANDI
                3'b111: begin
                    alu_control = 4'b0010;
                end


                default: begin
                end

            endcase

        end


        // ==================================================
        // LOADS
        // LB / LH / LW / LBU / LHU
        // ==================================================
        7'b0000011: begin

            case (funct3)

                3'b000,
                3'b001,
                3'b010,
                3'b100,
                3'b101: begin
                    alu_control = 4'b0000;
                    imm_selector = 3'b000;
                    alu_b_selector = 1'b1;
                    result_selector = 1'b1;
                    register_write_enable = 1'b1;
                end


                default: begin
                end

            endcase

        end


        // ==================================================
        // STORES
        // SB / SH / SW
        // ==================================================
        7'b0100011: begin

            case (funct3)

                3'b000,
                3'b001,
                3'b010: begin
                    alu_control = 4'b0000;
                    imm_selector = 3'b001;
                    alu_b_selector = 1'b1;
                    memory_write_enable = 1'b1;
                end


                default: begin
                end

            endcase

        end


        // ==================================================
        // BRANCHES
        // ==================================================
        7'b1100011: begin

            imm_selector = 3'b010;
            alu_a_selector = 1'b1;
            alu_b_selector = 1'b1;

            case (funct3)

                // BEQ
                3'b000: begin
                    if (equal)
                        pc_selector = 1'b1;
                end


                // BNE
                3'b001: begin
                    if (!equal)
                        pc_selector = 1'b1;
                end


                // BLT
                3'b100: begin
                    if (less_than_signed)
                        pc_selector = 1'b1;
                end


                // BGE
                3'b101: begin
                    if (!less_than_signed)
                        pc_selector = 1'b1;
                end


                // BLTU
                3'b110: begin
                    if (less_than_unsigned)
                        pc_selector = 1'b1;
                end


                // BGEU
                3'b111: begin
                    if (!less_than_unsigned)
                        pc_selector = 1'b1;
                end


                default: begin
                    pc_selector = 1'b0;
                end

            endcase

        end


        // ==================================================
        // JAL
        // ==================================================
        7'b1101111: begin
            imm_selector = 3'b011;

            alu_a_selector = 1'b1;
            alu_b_selector = 1'b1;

            alu_result_selector = 1'b1;
            result_selector = 1'b0;

            register_write_enable = 1'b1;

            pc_selector = 1'b1;
            jalr_selector = 1'b0;
        end


        // ==================================================
        // JALR
        // ==================================================
        7'b1100111: begin

            if (funct3 == 3'b000) begin
                imm_selector = 3'b000;

                alu_a_selector = 1'b0;
                alu_b_selector = 1'b1;

                alu_result_selector = 1'b1;
                result_selector = 1'b0;

                register_write_enable = 1'b1;

                pc_selector = 1'b1;
                jalr_selector = 1'b1;
            end

        end


        // ==================================================
        // LUI
        // ==================================================
        7'b0110111: begin
            imm_selector = 3'b100;

            alu_b_selector = 1'b1;

            alu_control = 4'b1010;

            register_write_enable = 1'b1;
        end


        // ==================================================
        // AUIPC
        // ==================================================
        7'b0010111: begin
            imm_selector = 3'b100;

            alu_a_selector = 1'b1;
            alu_b_selector = 1'b1;

            alu_control = 4'b0000;

            register_write_enable = 1'b1;
        end


        // ==================================================
        // UNKNOWN / UNSUPPORTED OPCODE
        // ==================================================
        default: begin
        end

    endcase

end

endmodule