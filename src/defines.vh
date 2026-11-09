// OP CODES
`define NOP    4'h0,
`define OP_MOV 4'h1,
`define OP_LD  4'h2,
`define OP_ST  4'h3,
`define OP_LDI 4'h4,

`define OP_ADD 4'h5,
`define OP_SUB 4'h6,
        
`define OP_OR  4'h7,
`define OP_AND 4'h8,
`define OP_NOT 4'h9,
`define OP_SHL 4'hA,
`define OP_SHR 4'hB,

`define OP_JMP 4'hC,
`define OP_JZ  4'hD,
`define OP_JNZ 4'hE,
`define OP_KIL 4'hF;

// STATES
`define RETR_UPR 3'd0,
`define RETR_LWR 3'd1,
`define RETR_MRY 3'd2,

`define WAIT_UPR 3'd3,
`define WAIT_LWR 3'd4,
`define WAIT_MRY 3'd5,

`define EXECUTE  3'd6,
`define KILL     3'd7;