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
    reg[3:0] STATUS_FLAGS;

    reg[7:0] regfile[0:63];
    reg[7:0] memory[0:511]; // 256 instructions

    reg[2:0] state; reg[2:0] next_state;
    reg [11:0] pc; reg[11:0] pc_next;

    reg[3:0] op;
    reg[3:0] regdest;
    reg[3:0] opt1;
    reg[3:0] opt2;

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

        case (state)
            WAIT_LWR: next_state = RETR_LWR;
            WAIT_UPR: next_state = RETR_UPR;
            RETR_UPR: begin
                op <= ui_in[7:4];
                regdest <= uio_in[3:0];
                next_state <= EXECUTE;
            end
            RETR_LWR: begin
                opt1 <= uio_in[7:4];
                opt2 <= uio_in[3:0];
                next_state = WAIT_LWR;
            end
            EXECUTE: begin

            end

        endcase
    end


endmodule
