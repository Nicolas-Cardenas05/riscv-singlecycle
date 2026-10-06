`timescale 1ns/1ps
module result_mux (
    input logic [31:0] ieu_result,
    input logic [31:0] read_data,
    input logic result_selector,
    output logic [31:0] result
);

always_comb begin : result_mux_logic
    case (result_selector)
        1'b0 : result = ieu_result;
        1'b1 : result = read_data;
        default : result = 32'd0;
    endcase
end
endmodule