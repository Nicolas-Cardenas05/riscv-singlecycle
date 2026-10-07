`timescale 1ns/1ps

module data_memory (
    input logic clk,
    input logic write_enable,
    input logic [31:0] write_data,
    input logic [31:0] address,
    input logic [2:0] funct3,

    output logic [31:0] read_data
);

logic [31:0] memory [63:0];

logic [31:0] memory_word;
logic [7:0] selected_byte;
logic [15:0] selected_half;


// --------------------------------------------------
// Select the 32-bit memory word
// --------------------------------------------------

assign memory_word = memory[address[7:2]];


// --------------------------------------------------
// Select byte inside the word
// --------------------------------------------------

always_comb begin : byte_select_logic

    case (address[1:0])

        2'b00:
            selected_byte = memory_word[7:0];

        2'b01:
            selected_byte = memory_word[15:8];

        2'b10:
            selected_byte = memory_word[23:16];

        2'b11:
            selected_byte = memory_word[31:24];

        default:
            selected_byte = 8'd0;

    endcase

end


// --------------------------------------------------
// Select halfword inside the word
// --------------------------------------------------

always_comb begin : half_select_logic

    case (address[1])

        1'b0:
            selected_half = memory_word[15:0];

        1'b1:
            selected_half = memory_word[31:16];

        default:
            selected_half = 16'd0;

    endcase

end


// --------------------------------------------------
// Load logic
// --------------------------------------------------

always_comb begin : load_logic

    case (funct3)

        // LB
        3'b000: begin
            read_data = {
                {24{selected_byte[7]}},
                selected_byte
            };
        end

        // LH
        3'b001: begin
            read_data = {
                {16{selected_half[15]}},
                selected_half
            };
        end

        // LW
        3'b010: begin
            read_data = memory_word;
        end

        // LBU
        3'b100: begin
            read_data = {
                24'd0,
                selected_byte
            };
        end

        // LHU
        3'b101: begin
            read_data = {
                16'd0,
                selected_half
            };
        end

        default: begin
            read_data = 32'd0;
        end

    endcase

end


// --------------------------------------------------
// Store logic
// --------------------------------------------------

always_ff @(posedge clk) begin

    if (write_enable) begin

        case (funct3)

            // SB
            3'b000: begin

                case (address[1:0])

                    2'b00:
                        memory[address[7:2]][7:0]
                            <= write_data[7:0];

                    2'b01:
                        memory[address[7:2]][15:8]
                            <= write_data[7:0];

                    2'b10:
                        memory[address[7:2]][23:16]
                            <= write_data[7:0];

                    2'b11:
                        memory[address[7:2]][31:24]
                            <= write_data[7:0];

                    default: begin
                    end

                endcase

            end


            // SH
            3'b001: begin

                if (address[1] == 1'b0) begin
                    memory[address[7:2]][15:0]
                        <= write_data[15:0];
                end
                else begin
                    memory[address[7:2]][31:16]
                        <= write_data[15:0];
                end

            end


            // SW
            3'b010: begin
                memory[address[7:2]]
                    <= write_data;
            end


            default: begin
            end

        endcase

    end

end

endmodule