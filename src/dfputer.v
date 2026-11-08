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

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    localparam [3:0]     // OP CODES
        NOP    = 4'h0,
        OP_MOV = 4'h1,
        OP_LD  = 4'h2,
        OP_ST  = 4'h3,
        OP_LDI = 4'h4,

        OP_ADD = 4'h5,
        OP_SUB = 4'h6,
        
        OP_OR  = 4'h7,
        OP_AND = 4'h8,
        OP_NOT = 4'h9,
        OP_SHL = 4'hA,
        OP_SHR = 4'hB,

        OP_JMP = 4'hC,
        OP_JZ  = 4'hD,
        OP_JNZ = 4'hE,
        OP_KIL = 4'hF;

    localparam [2:0]    // STATES
        RETR_UPR = 3'd0,
        RETR_LWR = 3'd1,
        RETR_MRY = 3'd2,

        WAIT_UPR = 3'd3,
        WAIT_LWR = 3'd4,
        WAIT_MRY = 3'd5,

        EXECUTE  = 3'd6,
        KILL     = 3'd7;

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
