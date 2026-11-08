module ControlUnit (
    input wire[3:0] opcode,
    input wire[3:0] opt1,
    input wire[3:0] opt2,

    input wire clk,

    input wire[2:0] state,
    input wire[3:0] sflags,
     
    output reg reg_write,
    output reg[15:0] datout
);

`include "defines.vh"

always @(*) begin
    reg_write = 0;
    datout = 4'h0;

    if (state == EXECUTE) begin
        case (opcode)
            OP_MOV: begin
                datout = {12'h0, opt1};
                reg_write = 1;
            end
            OP_ADD:

        endcase
    end
end