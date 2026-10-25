`timescale 1ns/1ps

module cpu_wishbone_master (
    input logic clk,
    input logic reset,
    input logic data_request,
    input logic data_write_enable,
    input logic [31:0] data_address,
    input logic [31:0] data_write,
    input logic [2:0] data_funct3,
    output logic [31:0] data_read,
    output logic stall,
    output logic [31:2] wb_adr_o,
    output logic [31:0] wb_dat_o,
    input logic [31:0] wb_dat_i,
    output logic wb_we_o,
    output logic [3:0] wb_sel_o,
    output logic wb_cyc_o,
    output logic wb_stb_o,
    input logic wb_ack_i
);

typedef enum logic {
    IDLE,
    ACTIVE
} state_t;

state_t state;

logic [31:0] address_reg;
logic [31:0] write_data_reg;
logic write_enable_reg;
logic [2:0] funct3_reg;

always_ff @(posedge clk) begin

    if (reset) begin
        state <= IDLE;

        address_reg <= 32'd0;
        write_data_reg <= 32'd0;
        write_enable_reg <= 1'b0;
        funct3_reg <= 3'b000;
    end

    else begin
        case (state)
            IDLE: begin
                if (data_request) begin
                    address_reg <= data_address;
                    write_data_reg <= data_write;
                    write_enable_reg <= data_write_enable;
                    funct3_reg <= data_funct3;
                    state <= ACTIVE;
                end
            end

            ACTIVE: begin
                if (wb_ack_i) begin
                    state <= IDLE;
                end
            end
        endcase
    end
end

always_comb begin
    wb_adr_o = address_reg[31:2];
    wb_dat_o = 32'd0;
    wb_we_o = write_enable_reg;
    wb_cyc_o = 1'b0;
    wb_stb_o = 1'b0;
    data_read = 32'd0;
    stall = 1'b0;
    wb_sel_o = 4'b0000;

    case (state)
        IDLE: begin
            if (data_request) begin
                stall = 1'b1;
            end
        end

        ACTIVE: begin
            wb_cyc_o = 1'b1;
            wb_stb_o = 1'b1;
            if (!wb_ack_i) begin
                stall = 1'b1;
            end
        end
    endcase

    case (funct3_reg) 
        3'b000, 3'b100: begin
            case (address_reg[1:0])
                2'b00: wb_sel_o = 4'b0001;
                2'b01: wb_sel_o = 4'b0010;
                2'b10: wb_sel_o = 4'b0100;
                2'b11: wb_sel_o = 4'b1000;
            endcase
        end 
        
        3'b001, 3'b101: begin
            if (address_reg[1] == 1'b0)
                wb_sel_o = 4'b0011;
            else
                wb_sel_o = 4'b1100;
        end

        3'b010: begin
            wb_sel_o = 4'b1111;
        end

        default: begin
            wb_sel_o = 4'b0000;
        end
    endcase

    case (funct3_reg)
        3'b000: begin
            case (address_reg[1:0])
                2'b00: wb_dat_o = {24'd0, write_data_reg[7:0]};
                2'b01: wb_dat_o = {16'd0, write_data_reg[7:0], 8'd0};
                2'b10: wb_dat_o = {8'd0, write_data_reg[7:0], 16'd0};
                2'b11: wb_dat_o = {write_data_reg[7:0], 24'd0};
            endcase
        end

        3'b001: begin
            if (address_reg[1] == 1'b0)
                wb_dat_o = {16'd0, write_data_reg[15:0]};
            else
                wb_dat_o = {write_data_reg[15:0], 16'd0};
        end

        3'b010: begin
            wb_dat_o = write_data_reg;
        end

        default: begin
            wb_dat_o = 32'd0;
        end
    endcase

    case (funct3_reg)
        // LB
        3'b000: begin
            case (address_reg[1:0])
                2'b00: data_read = {{24{wb_dat_i[7]}}, wb_dat_i[7:0]};
                2'b01: data_read = {{24{wb_dat_i[15]}}, wb_dat_i[15:8]};
                2'b10: data_read = {{24{wb_dat_i[23]}}, wb_dat_i[23:16]};
                2'b11: data_read = {{24{wb_dat_i[31]}}, wb_dat_i[31:24]};
            endcase
        end

        // LH
        3'b001: begin
            if (address_reg[1] == 1'b0)
                data_read = {{16{wb_dat_i[15]}}, wb_dat_i[15:0]};
            else
                data_read = {{16{wb_dat_i[31]}}, wb_dat_i[31:16]};
        end

        // LW
        3'b010: begin
            data_read = wb_dat_i;
        end

        // LBU
        3'b100: begin
            case (address_reg[1:0])
                2'b00: data_read = {24'd0, wb_dat_i[7:0]};
                2'b01: data_read = {24'd0, wb_dat_i[15:8]};
                2'b10: data_read = {24'd0, wb_dat_i[23:16]};
                2'b11: data_read = {24'd0, wb_dat_i[31:24]};
            endcase
        end

        // LHU
        3'b101: begin
            if (address_reg[1] == 1'b0)
                data_read = {16'd0, wb_dat_i[15:0]};
            else
                data_read = {16'd0, wb_dat_i[31:16]};
        end

        default: begin
            data_read = 32'd0;
        end
    endcase

end

endmodule