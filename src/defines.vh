`ifndef DEFINES_VH
`define DEFINES_VH

// OPCODES
`define NOP        4'h0
`define OP_NST     4'h1
`define OP_LD      4'h2
`define OP_ST      4'h3
`define OP_LDI     4'h4

`define OP_ADD     4'h5
`define OP_SUB     4'h6

`define OP_XOR     4'h7
`define OP_OR      4'h8
`define OP_AND     4'h9
`define OP_NOT     4'hA
`define OP_SHL     4'hB
`define OP_SHR     4'hC

`define OP_JZ      4'hD
`define OP_JNZ     4'hE
`define OP_EXT     4'hF

// SUBOPCODES
`define OP_NST_MOV 4'h0
`define OP_NST_CMP 4'h1
`define OP_NST_KIL 4'h2

`define EXT_KIL    4'h0
`define EXT_PUSH   4'h1
`define EXT_POP    4'h2
`define EXT_GREAD  4'h3
`define EXT_GWRITE 4'h4

// STATES
`define FETCH      2'd0
`define EXECUTE    2'd1
`define RETR_MRY   2'd2
`define KILL       2'd3

`endif