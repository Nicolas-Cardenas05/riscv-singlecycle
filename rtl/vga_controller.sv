`timescale 1ns/1ps

module vga_controller (
    input logic clk,
    input logic reset,

    input logic [31:0] vga_word_data,
    output logic [14:0] vga_word_address,

    output logic [3:0] vga_red,
    output logic [3:0] vga_green,
    output logic [3:0] vga_blue,

    output logic vga_hsync,
    output logic vga_vsync
);

logic [1:0] pixel_divider;

logic [9:0] horizontal_counter;
logic [9:0] vertical_counter;

logic active_video;
logic hsync_next;
logic vsync_next;

logic [8:0] logical_x;
logic [7:0] logical_y;

logic [16:0] pixel_address;
logic [1:0] pixel_byte_select;

logic active_video_reg;
logic [1:0] pixel_byte_select_reg;

logic [7:0] pixel_data;


// ------------------------------------------------------------
// 25 MHz pixel enable from 100 MHz system clock
// ------------------------------------------------------------

always_ff @(posedge clk) begin
    if (reset)
        pixel_divider <= 2'd0;
    else
        pixel_divider <= pixel_divider + 1'b1;
end

// ------------------------------------------------------------
// VGA timing counters
// 640x480 @ approximately 60 Hz
// ------------------------------------------------------------

always_ff @(posedge clk) begin
    if (reset) begin
        horizontal_counter <= 10'd0;
        vertical_counter <= 10'd0;
    end
    else if (pixel_divider == 2'b11) begin
        if (horizontal_counter == 10'd799) begin
            horizontal_counter <= 10'd0;
            if (vertical_counter == 10'd524)
                vertical_counter <= 10'd0;
            else
                vertical_counter <= vertical_counter + 1'b1;
        end
        else begin
            horizontal_counter <= horizontal_counter + 1'b1;
        end
    end
end

// ------------------------------------------------------------
// VGA timing generation
// ------------------------------------------------------------

always_comb begin
    active_video = (horizontal_counter < 10'd640) && (vertical_counter < 10'd480);
    hsync_next = !((horizontal_counter >= 10'd656) && (horizontal_counter < 10'd752));
    vsync_next = !((vertical_counter >= 10'd490) && (vertical_counter < 10'd492));
end

// ------------------------------------------------------------
// Convert physical 640x480 coordinates to logical 320x240
// Each framebuffer pixel is displayed as a 2x2 VGA block
// ------------------------------------------------------------

always_comb begin
    logical_x = horizontal_counter[9:1];
    logical_y = vertical_counter[8:1];
    if (active_video) begin
        pixel_address =
            ({9'd0, logical_y} << 8) +
            ({9'd0, logical_y} << 6) +
            {8'd0, logical_x};
    end
    else begin
        pixel_address = 17'd0;
    end
    vga_word_address = pixel_address[16:2];
    pixel_byte_select = pixel_address[1:0];
end


// ------------------------------------------------------------
// Pipeline control signals to match synchronous VRAM read
// ------------------------------------------------------------

always_ff @(posedge clk) begin
    if (reset) begin
        active_video_reg <= 1'b0;
        pixel_byte_select_reg <= 2'd0;
        vga_hsync <= 1'b1;
        vga_vsync <= 1'b1;
    end
    else begin
        active_video_reg <= active_video;
        pixel_byte_select_reg <= pixel_byte_select;
        vga_hsync <= hsync_next;
        vga_vsync <= vsync_next;
    end
end


// ------------------------------------------------------------
// Select one 8-bit pixel from the 32-bit VRAM word
// ------------------------------------------------------------

always_comb begin
    case (pixel_byte_select_reg)
        2'b00: pixel_data = vga_word_data[7:0];
        2'b01: pixel_data = vga_word_data[15:8];
        2'b10: pixel_data = vga_word_data[23:16];
        2'b11: pixel_data = vga_word_data[31:24];
        default: pixel_data = 8'd0;
    endcase
end

// ------------------------------------------------------------
// RRRGGGBB framebuffer format
//
// [7:5] = Red
// [4:2] = Green
// [1:0] = Blue
// ------------------------------------------------------------

always_comb begin

    if (active_video_reg) begin
        vga_red = {pixel_data[7:5], pixel_data[7]};
        vga_green = {pixel_data[4:2], pixel_data[4]};
        vga_blue = {pixel_data[1:0], pixel_data[1:0]};
    end

    else begin
        vga_red = 4'd0;
        vga_green = 4'd0;
        vga_blue = 4'd0;
    end
end

endmodule