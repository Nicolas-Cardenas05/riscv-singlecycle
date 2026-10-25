`timescale 1ns/1ps

module wishbone_seven_segment (
    input logic clk,
    input logic reset,

    input logic [31:0] wb_dat_i,
    output logic [31:0] wb_dat_o,

    input logic wb_we_i,
    input logic [3:0] wb_sel_i,

    input logic wb_cyc_i,
    input logic wb_stb_i,
    output logic wb_ack_o,

    output logic [6:0] segments,
    output logic [7:0] anodes,
    output logic dp
);

logic [31:0] display_value;
logic [16:0] refresh_counter;
logic [2:0] digit_select;
logic [3:0] digit_value;

assign wb_dat_o = display_value;
assign wb_ack_o = wb_cyc_i && wb_stb_i;
assign digit_select = refresh_counter[16:14];
assign dp = 1'b1;

always_ff @(posedge clk) begin
    if (reset) begin
        display_value <= 32'd0;
    end

    else if (wb_cyc_i && wb_stb_i && wb_we_i) begin
        if (wb_sel_i[0])
            display_value[7:0] <= wb_dat_i[7:0];

        if (wb_sel_i[1])
            display_value[15:8] <= wb_dat_i[15:8];

        if (wb_sel_i[2])
            display_value[23:16] <= wb_dat_i[23:16];

        if (wb_sel_i[3])
            display_value[31:24] <= wb_dat_i[31:24];
    end
end


always_ff @(posedge clk) begin
    if (reset)
        refresh_counter <= 17'd0;
    else
        refresh_counter <= refresh_counter + 1'b1;
end

always_comb begin
    case (digit_select)
        3'd0: begin
            anodes = 8'b11111110;
            digit_value = display_value[3:0];
        end

        3'd1: begin
            anodes = 8'b11111101;
            digit_value = display_value[7:4];
        end

        3'd2: begin
            anodes = 8'b11111011;
            digit_value = display_value[11:8];
        end

        3'd3: begin
            anodes = 8'b11110111;
            digit_value = display_value[15:12];
        end

        3'd4: begin
            anodes = 8'b11101111;
            digit_value = display_value[19:16];
        end

        3'd5: begin
            anodes = 8'b11011111;
            digit_value = display_value[23:20];
        end

        3'd6: begin
            anodes = 8'b10111111;
            digit_value = display_value[27:24];
        end

        3'd7: begin
            anodes = 8'b01111111;
            digit_value = display_value[31:28];
        end

        default: begin
            anodes = 8'b11111111;
            digit_value = 4'd0;
        end
    endcase
end

always_comb begin
    case (digit_value)
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

endmodule