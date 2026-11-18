/*
 * Copyright (c) 2024 Asad Patwekar
 * SPDX-License-Identifier: Apache-2.0
 */

 /*
 * asadpetwalker
 * StuyCEC
 * Dufocklian Puter
 */

`default_nettype none

module DFPuter (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

`include "defines.vh"

wire retr_mry = ui_in[7];

reg [3:0] curr_sflags;
wire [3:0] sflags;

reg [7:0] regfile [0:15];

reg [2:0] state;
reg [7:0] pc;
reg [7:0] sp;

reg [3:0] op;
reg [3:0] regdest;
reg [3:0] opt1;
reg [3:0] opt2;

wire [7:0] cu_datout;
wire reg_wdata;
wire mem_wdata;
wire flag_write;

wire [7:0] jmp_target;
wire jmp_en;

reg [7:0] gpio_out;
reg [7:0] gpio_uio_out;
reg [7:0] gpio_uio_oe;

reg ram_cen;
reg ram_gwen;
reg [7:0] ram_wen;
reg [7:0] ram_addr;
reg [7:0] ram_din;
wire [7:0] ram_dout;

reg next_ram_cen;
reg next_ram_gwen;
reg [7:0] next_ram_wen;
reg [7:0] next_ram_addr;
reg [7:0] next_ram_din;

integer i;

assign uo_out = gpio_out;
assign uio_out = gpio_uio_out;
assign uio_oe = retr_mry ? 8'h00 : gpio_uio_oe;

gf180mcu_ocd_ip_sram__sram256x8m8wm1 memory (
    .CLK(clk),
    .CEN(ram_cen),
    .GWEN(ram_gwen),
    .WEN(ram_wen),
    .A(ram_addr),
    .D(ram_din),
    .Q(ram_dout)
);

ControlUnit exec (
    .opcode(op),
    .opt1(opt1),
    .opt2(opt2),
    .reg_val1(regfile[opt1]),
    .reg_val2(regfile[opt2]),
    .curr_sflags(curr_sflags),
    .state(state),
    .sflags(sflags),
    .mem_write(mem_wdata),
    .reg_write(reg_wdata),
    .flag_write(flag_write),
    .datout(cu_datout),
    .jmp_target(jmp_target),
    .jmp_en(jmp_en)
);

always @(*) begin
    next_ram_cen = 1'b1;
    next_ram_gwen = 1'b1;
    next_ram_wen = 8'hFF;
    next_ram_addr = 8'h00;
    next_ram_din = 8'h00;

    if (rst_n) begin
        if (retr_mry) begin
            next_ram_cen = 1'b0;
            next_ram_gwen = 1'b0;
            next_ram_wen = 8'h00;
            next_ram_addr = {1'b0, ui_in[6:0]};
            next_ram_din = uio_in;
        end else begin
            case (state)
                `RETR_UPR: begin
                    next_ram_cen = 1'b0;
                    next_ram_addr = pc;
                end

                `RETR_LWR: begin
                    next_ram_cen = 1'b0;
                    next_ram_addr = pc + 8'd1;
                end

                `EXECUTE: begin
                    if (op == `OP_LD) begin
                        next_ram_cen = 1'b0;
                        next_ram_addr = regfile[opt1];
                    end else if (mem_wdata) begin
                        next_ram_cen = 1'b0;
                        next_ram_gwen = 1'b0;
                        next_ram_wen = 8'h00;
                        next_ram_addr = regfile[opt2];
                        next_ram_din = cu_datout;
                    end else if (op == `OP_EXT) begin
                        case (opt1)
                            `EXT_PUSH: begin
                                next_ram_cen = 1'b0;
                                next_ram_gwen = 1'b0;
                                next_ram_wen = 8'h00;
                                next_ram_addr = sp;
                                next_ram_din = regfile[regdest];
                            end

                            `EXT_POP: begin
                                next_ram_cen = 1'b0;
                                next_ram_addr = sp + 8'd1;
                            end
                        endcase
                    end
                end
            endcase
        end
    end
end

always @(negedge clk) begin
    if (!rst_n) begin
        ram_cen <= 1'b1;
        ram_gwen <= 1'b1;
        ram_wen <= 8'hFF;
        ram_addr <= 8'h00;
        ram_din <= 8'h00;
    end else begin
        ram_cen <= next_ram_cen;
        ram_gwen <= next_ram_gwen;
        ram_wen <= next_ram_wen;
        ram_addr <= next_ram_addr;
        ram_din <= next_ram_din;
    end
end

always @(posedge clk) begin
    if (!rst_n) begin
        state <= `RETR_UPR;
        pc <= 8'h00;
        sp <= 8'hFF;
        op <= 4'h0;
        regdest <= 4'h0;
        opt1 <= 4'h0;
        opt2 <= 4'h0;
        curr_sflags <= 4'h0;
        gpio_out <= 8'h00;
        gpio_uio_out <= 8'h00;
        gpio_uio_oe <= 8'h00;

        for (i = 0; i < 16; i = i + 1)
            regfile[i] <= 8'h00;
    end else if (retr_mry) begin
        state <= `RETR_UPR;
        pc <= 8'h00;
        sp <= 8'hFF;
        op <= 4'h0;
        regdest <= 4'h0;
        opt1 <= 4'h0;
        opt2 <= 4'h0;
        curr_sflags <= 4'h0;
        gpio_out <= 8'h00;
        gpio_uio_out <= 8'h00;
        gpio_uio_oe <= 8'h00;

        for (i = 0; i < 16; i = i + 1)
            regfile[i] <= 8'h00;
    end else begin
        case (state)
            `RETR_UPR: begin
                state <= `WAIT_UPR;
            end

            `WAIT_UPR: begin
                op <= ram_dout[7:4];
                regdest <= ram_dout[3:0];
                state <= `RETR_LWR;
            end

            `RETR_LWR: begin
                state <= `WAIT_LWR;
            end

            `WAIT_LWR: begin
                opt1 <= ram_dout[7:4];
                opt2 <= ram_dout[3:0];
                pc <= pc + 8'd2;
                state <= `EXECUTE;
            end

            `EXECUTE: begin
                state <= `RETR_UPR;

                if (reg_wdata)
                    regfile[regdest] <= cu_datout;

                if (flag_write)
                    curr_sflags <= sflags;

                if (jmp_en)
                    pc <= jmp_target;

                if (op == `OP_LD)
                    state <= `RETR_MRY;

                if (op == `OP_EXT) begin
                    case (opt1)
                        `EXT_KIL: begin
                            state <= `KILL;
                        end

                        `EXT_PUSH: begin
                            sp <= sp - 8'd1;
                        end

                        `EXT_POP: begin
                            sp <= sp + 8'd1;
                            state <= `RETR_MRY;
                        end

                        `EXT_GREAD: begin
                            case (opt2)
                                4'h0: regfile[regdest] <= ui_in;
                                4'h1: regfile[regdest] <= uio_in;
                                4'h2: regfile[regdest] <= gpio_out;
                                4'h3: regfile[regdest] <= gpio_uio_oe;
                                default: regfile[regdest] <= 8'h00;
                            endcase
                        end

                        `EXT_GWRITE: begin
                            case (opt2)
                                4'h1: gpio_uio_out <= regfile[regdest];
                                4'h2: gpio_out <= regfile[regdest];
                                4'h3: gpio_uio_oe <= regfile[regdest];
                            endcase
                        end
                    endcase
                end
            end

            `RETR_MRY: begin
                regfile[regdest] <= ram_dout;
                state <= `RETR_UPR;
            end

            `KILL: begin
                state <= `KILL;
            end

            default: begin
                state <= `RETR_UPR;
            end
        endcase
    end
end

endmodule