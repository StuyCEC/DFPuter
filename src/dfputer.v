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

    // OP CODES
    
    localparam [3:0]
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
        OP_HLT = 4'hF;

    

endmodule
