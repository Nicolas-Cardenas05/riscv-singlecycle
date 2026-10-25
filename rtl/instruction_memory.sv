`timescale 1ns/1ps
module instruction_memory (
    input logic [31:0] pc,
    output logic [31:0] instruction
);

logic [31:0] irom [0:1023];

initial begin
    $readmemh("program.mem", irom);
end

assign instruction = irom[pc[11:2]];
endmodule