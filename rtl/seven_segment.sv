`timescale 1ns/1ps

module show_seven_segment (
    input  logic clk,
    input  logic reset,
    input  logic write_enable,
    input  logic [31:0] write_data,
    input  logic [2:0] funct3,
    output logic [6:0] segments,
    output logic [7:0] anodes,
    output logic dp,
    output logic [31:0] read_data
);

logic [31:0] display_value;
logic [16:0] refresh_counter;
logic [2:0] digit_select;
logic [3:0] current_nibble;

always_ff @(posedge clk) begin
    if (reset) begin
        display_value <= 32'd0;
    end
    else if (write_enable && (funct3 == 3'b010)) begin
        display_value <= write_data;
    end
end

assign read_data = display_value;

always_ff @(posedge clk) begin
    if (reset) begin
        refresh_counter <= 17'd0;
    end
    else begin
        refresh_counter <= refresh_counter + 1'b1;
    end
end

assign digit_select = refresh_counter[16:14];

always_comb begin
    case (digit_select)
        3'd0: begin
            current_nibble = display_value[3:0];
            anodes = 8'b11111110;
        end
        3'd1: begin
            current_nibble = display_value[7:4];
            anodes = 8'b11111101;
        end
        3'd2: begin
            current_nibble = display_value[11:8];
            anodes = 8'b11111011;
        end
        3'd3: begin
            current_nibble = display_value[15:12];
            anodes = 8'b11110111;
        end
        3'd4: begin
            current_nibble = display_value[19:16];
            anodes = 8'b11101111;
        end
        3'd5: begin
            current_nibble = display_value[23:20];
            anodes = 8'b11011111;
        end
        3'd6: begin
            current_nibble = display_value[27:24];
            anodes = 8'b10111111;
        end
        3'd7: begin
            current_nibble = display_value[31:28];
            anodes = 8'b01111111;
        end
        default: begin
            current_nibble = 4'd0;
            anodes = 8'b11111111;
        end
    endcase
end

always_comb begin
    case (current_nibble)
        4'h0: segments = 7'b1000000;
        4'h1: segments = 7'b1111001;
        4'h2: segments = 7'b0100100;
        4'h3: segments = 7'b0110000;
        4'h4: segments = 7'b0011001;
        4'h5: segments = 7'b0010010;
        4'h6: segments = 7'b0000010;
        4'h7: segments = 7'b1111000;
        4'h8: segments = 7'b0000000;
        4'h9: segments = 7'b0010000;
        4'hA: segments = 7'b0001000;
        4'hB: segments = 7'b0000011;
        4'hC: segments = 7'b1000110;
        4'hD: segments = 7'b0100001;
        4'hE: segments = 7'b0000110;
        4'hF: segments = 7'b0001110;
        default: segments = 7'b1111111;
    endcase
end

assign dp = 1'b1;

endmodule