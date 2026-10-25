`timescale 1ns/1ps

module wishbone_seven_segment (
    input  logic        clk,
    input  logic        reset,

    input  logic [31:0] wb_dat_i,
    output logic [31:0] wb_dat_o,

    input  logic        wb_we_i,
    input  logic [3:0]  wb_sel_i,
    input  logic        wb_cyc_i,
    input  logic        wb_stb_i,
    output logic        wb_ack_o,

    output logic [6:0]  segments,
    output logic [7:0]  anodes,
    output logic        dp
);

    logic [31:0] display_value;
    logic        display_enable;

    logic [16:0] refresh_counter;
    logic [2:0]  digit_select;

    logic [3:0] digit_value;

    logic [6:0] decoded_segments;
    logic [7:0] active_anodes;


    // ========================================================
    // WISHBONE interface
    // ========================================================

    assign wb_ack_o = wb_cyc_i && wb_stb_i;
    assign wb_dat_o = display_value;


    // ========================================================
    // Display register
    // ========================================================

    always_ff @(posedge clk) begin
        if (reset) begin
            display_value  <= 32'b0;
            display_enable <= 1'b0;
        end else begin

            if (wb_cyc_i && wb_stb_i && wb_we_i) begin

                if (wb_sel_i[0])
                    display_value[7:0] <= wb_dat_i[7:0];

                if (wb_sel_i[1])
                    display_value[15:8] <= wb_dat_i[15:8];

                if (wb_sel_i[2])
                    display_value[23:16] <= wb_dat_i[23:16];

                if (wb_sel_i[3])
                    display_value[31:24] <= wb_dat_i[31:24];

                display_enable <= 1'b1;
            end
        end
    end


    // ========================================================
    // Refresh counter
    // ========================================================

    always_ff @(posedge clk) begin
        if (reset)
            refresh_counter <= 17'b0;
        else
            refresh_counter <= refresh_counter + 1'b1;
    end

    assign digit_select = refresh_counter[16:14];


    // ========================================================
    // Digit multiplexer
    // ========================================================

    always_comb begin

        digit_value   = 4'h0;
        active_anodes = 8'b11111111;

        case (digit_select)

            3'd0: begin
                digit_value   = display_value[3:0];
                active_anodes = 8'b11111110;
            end

            3'd1: begin
                digit_value   = display_value[7:4];
                active_anodes = 8'b11111101;
            end

            3'd2: begin
                digit_value   = display_value[11:8];
                active_anodes = 8'b11111011;
            end

            3'd3: begin
                digit_value   = display_value[15:12];
                active_anodes = 8'b11110111;
            end

            3'd4: begin
                digit_value   = display_value[19:16];
                active_anodes = 8'b11101111;
            end

            3'd5: begin
                digit_value   = display_value[23:20];
                active_anodes = 8'b11011111;
            end

            3'd6: begin
                digit_value   = display_value[27:24];
                active_anodes = 8'b10111111;
            end

            3'd7: begin
                digit_value   = display_value[31:28];
                active_anodes = 8'b01111111;
            end

            default: begin
                digit_value   = 4'h0;
                active_anodes = 8'b11111111;
            end

        endcase
    end


    // ========================================================
    // Hexadecimal decoder
    //
    // Segments are active-low on Nexys A7.
    // segments[0] = A
    // segments[1] = B
    // ...
    // segments[6] = G
    // ========================================================

    always_comb begin

        case (digit_value)

            4'h0: decoded_segments = 7'b1000000;
            4'h1: decoded_segments = 7'b1111001;
            4'h2: decoded_segments = 7'b0100100;
            4'h3: decoded_segments = 7'b0110000;
            4'h4: decoded_segments = 7'b0011001;
            4'h5: decoded_segments = 7'b0010010;
            4'h6: decoded_segments = 7'b0000010;
            4'h7: decoded_segments = 7'b1111000;
            4'h8: decoded_segments = 7'b0000000;
            4'h9: decoded_segments = 7'b0010000;
            4'hA: decoded_segments = 7'b0001000;
            4'hB: decoded_segments = 7'b0000011;
            4'hC: decoded_segments = 7'b1000110;
            4'hD: decoded_segments = 7'b0100001;
            4'hE: decoded_segments = 7'b0000110;
            4'hF: decoded_segments = 7'b0001110;

            default:
                decoded_segments = 7'b1111111;

        endcase
    end


    // ========================================================
    // Final display outputs
    //
    // This is the ONLY place that drives these outputs.
    // ========================================================

    always_comb begin

        if (display_enable) begin
            segments = decoded_segments;
            anodes   = active_anodes;
            dp       = 1'b1;
        end else begin
            segments = 7'b1111111;
            anodes   = 8'b11111111;
            dp       = 1'b1;
        end

    end

endmodule