/*
 * Copyright (c) 2024 Asad Patwekar
 * SPDX-License-Identifier: Apache-2.0
 */

 /*
 asadpetwalker
 StuyCEC
 Dufocklian Puter
 */

`default_nettype none

module DFPuter (

    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    `include "defines.vh"

    wire retr_mry = ui_in[7];

    // STATUS FLAGS: 
    // ZERO     0
    // NEGATIVE 1
    // CARRY    2
    // OVERFLOW 3
    reg[3:0] sflags;

    reg[7:0] regfile[0:15];
    reg[7:0] memory[0:255]; // 256 instructions

    reg[2:0] state; reg[2:0] next_state;
    reg [11:0] pc; reg[11:0] pc_next;

    reg[3:0] nextop;
    reg[3:0] op;

    reg[3:0] regdest;
    reg[3:0] nexdest;

    reg[3:0] opt1;
    reg[3:0] opt2;

    reg[15:0] cu_datout;
    reg reg_wdata;
    reg mem_wdata;

    ControlUnit exec (
        .opcode(op),
        .opt1(opt1),
        .opt2(opt2),
        .reg_val1(regfile[opt1]),
        .reg_val2(regfile[opt2]),
        
        
        
        .clk(clk),
        
        .state(state),
        .sflags(sflags),
        
        .mem_write(mem_wdata),
        .reg_write(reg_wdata),
        .datout(cu_datout)
    );

    // State Management
    always @(posedge clk) begin
        if (!rst_n) begin
            state <= RETR_UPR;
        end else begin
            state <= next_state;
            pc <= pc_next;
        end
    end

    // Command Reading
    always @(posedge clk) begin
        next_state = state;
        pc_next = pc;
        wdata = 1'b0;
        case (state)
            WAIT_LWR: next_state = RETR_LWR;
            WAIT_UPR: next_state = RETR_UPR;
            RETR_UPR: begin
                nextop <= ui_in[7:4];
                nexdest <= uio_in[3:0];
                next_state <= EXECUTE;
            end
            RETR_LWR: begin
                opt1 <= uio_in[7:4];
                opt2 <= uio_in[3:0];
                next_state = WAIT_LWR;
            end
            EXECUTE: begin
                regdest <= nexdest;
                op <= nextop;

                if (!rst_n) begin
                    regfile[0] <= 16'h0;
                end else if (wdata) begin
                    regfile[regdest] <= cu_datout;
                end
            end

        endcase
    end


endmodule
