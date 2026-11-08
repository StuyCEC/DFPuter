module ControlUnit (
    input wire[3:0] opcode,
    input wire[3:0] opt1,
    input wire[3:0] opt2,

    input wire clk,

    input wire[2:0] state,
    input wire[3:0] sflags,
    input wire reg_write,

    output reg[3:0] rd
)
`include "defines.vh"

always @(*) begin
    if (state == EXECUTE) begin
        case (opcode)
            OP_ADD:
                
        endcase
    end
end