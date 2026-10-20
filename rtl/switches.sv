`timescale 1ns/1ps

module switches (
    input logic [15:0] switch_in,
    output logic [31:0] read_data
);

assign read_data = {16'd0,switch_in};

endmodule