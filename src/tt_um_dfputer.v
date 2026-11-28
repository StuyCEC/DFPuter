/*
- Copyright (c) 2024 Asad Patwekar
- SPDX-License-Identifier: Apache-2.0
 */

/*
asadpetwalker
StuyCEC
Dufocklian Puter
 */

`default_nettype none

module tt_um_dfputer (
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

reg [3:0] curr_sflags;
wire [3:0] sflags;

reg [7:0] regfile [0:7];

reg [1:0] state;
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
assign uio_oe = gpio_uio_oe;

gf180mcu_ocd_ip_sram__sram256x8m8wm1 sram_inst (
    .CLK  (clk),
    .CEN  (ram_cen),
    .GWEN (ram_gwen),
    .WEN  (ram_wen),
    .A    (ram_addr),
    .D    (ram_din),
    .Q    (ram_dout)
);

ControlUnit exec (
    .opcode(op),
    .opt1(opt1),
    .opt2(opt2),
    .reg_val1(regfile[opt1[2:0]]),
    .reg_val2(regfile[opt2[2:0]]),
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
        case (state)
            `EXECUTE: begin
                if (op == `OP_LD) begin
                    next_ram_cen = 1'b0;
                    next_ram_addr = regfile[opt1[2:0]];
                end else if (mem_wdata) begin
                    next_ram_cen = 1'b0;
                    next_ram_gwen = 1'b0;
                    next_ram_wen = 8'h00;
                    next_ram_addr = regfile[opt2[2:0]];
                    next_ram_din = cu_datout;
                end else if (op == `OP_EXT) begin
                    case (opt1)
                        `EXT_PUSH: begin
                            next_ram_cen = 1'b0;
                            next_ram_gwen = 1'b0;
                            next_ram_wen = 8'h00;
                            next_ram_addr = sp;
                            next_ram_din = regfile[regdest[2:0]];
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

always @(posedge clk) begin
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
        state <= `FETCH;
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

        for (i = 0; i < 8; i = i + 1)
            regfile[i] <= 8'h00;
    end else begin
        case (state)
            `FETCH: begin
                op      <= ui_in[7:4];
                regdest <= ui_in[3:0];
                opt1    <= uio_in[7:4];
                opt2    <= uio_in[3:0];
                pc      <= pc + 8'd1;
                state   <= `EXECUTE;
            end

            `EXECUTE: begin
                state <= `FETCH;

                if (op == `OP_NST && opt1 == `OP_NST_KIL) begin
                    state <= `KILL;
                end

                if (reg_wdata)
                    regfile[regdest[2:0]] <= cu_datout;

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
                                4'h0: regfile[regdest[2:0]] <= ui_in;
                                4'h1: regfile[regdest[2:0]] <= uio_in;
                                4'h2: regfile[regdest[2:0]] <= gpio_out;
                                4'h3: regfile[regdest[2:0]] <= gpio_uio_oe;
                                default: regfile[regdest[2:0]] <= 8'h00;
                            endcase
                        end

                        `EXT_GWRITE: begin
                            case (opt2)
                                4'h1: gpio_uio_out <= (reg_wdata && (regdest[2:0] == opt2)) ? cu_datout : regfile[regdest[2:0]];
                                4'h2: gpio_out     <= (reg_wdata && (regdest[2:0] == opt2)) ? cu_datout : regfile[regdest[2:0]];
                                4'h3: gpio_uio_oe  <= (reg_wdata && (regdest[2:0] == opt2)) ? cu_datout : regfile[regdest[2:0]];
                            endcase
                        end
                    endcase
                end
            end

            `RETR_MRY: begin
                regfile[regdest[2:0]] <= ram_dout;
                state <= `FETCH;
            end

            `KILL: begin
                state <= `KILL;
            end

            default: begin
                state <= `FETCH;
            end
        endcase
    end
end

endmodule