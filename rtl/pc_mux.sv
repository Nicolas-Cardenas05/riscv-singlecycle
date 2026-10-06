`timescale 1ns/1ps
module pc_mux (
    input logic [31:0] pc_plus_4,
    input logic [31:0] alu_address,
    input logic pc_selector,
    output logic [31:0] pc_next
);

always_comb begin : pc_mux_logic
    case (pc_selector)
        1'b0 : pc_next = pc_plus_4;
        1'b1 : pc_next = alu_address;
        default : pc_next = 32'd0;
    endcase
end
endmodule