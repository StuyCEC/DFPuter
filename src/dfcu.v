module ControlUnit (
    input wire[3:0] opcode,
    input wire[3:0] opt1,
    input wire[3:0] opt2,

    input wire clk,

    input wire[2:0] state,
    input wire[3:0] sflags,

    output reg mem_write, 
    output reg reg_write,
    output reg[7:0] datout
);

`include "defines.vh"

always @(*) begin
    reg_write = 1'b0;
    mem_write = 1'b0;
    datout = 16'h0;

    if (state == EXECUTE) begin
        case (opcode)
            // MEM, REGFILE CODES
            OP_MOV: begin
                datout = {4'h0, opt1};
                reg_write = 1;
            end
            OP_LD: begin 
                reg_write = 1;
            end
            OP_ST: begin
                mem_write = 1;
            end
            OP_LDI: begin
                datout = {4'h0, opt1};
                reg_write = 1;
            end

            // ALU CODES
            OP_ADD: begin
                datout = opt1 + opt2;
                reg_write = 1;
            end
            OP_SUB: begin
                datout = opt1 - opt2;
                reg_write = 1;
            end
            OP_OR: begin
                datout = opt1 | opt2;
                reg_write = 1;
            end
            OP_AND: begin
                datout = opt1 & opt2;
                reg_write = 1;
            end
            OP_NOT: begin
                datout = ~opt1;
                reg_write = 1;
            end
            OP_SHL: begin
                datout = opt1 << 1;
                reg_write = 1;
            end
            OP_SHR: begin
                datout = opt1 >> 1;
                reg_write = 1;
            end

            // LOOP CODES
            OP_JMP: begin

            end
            OP_JZ: begin

            end
            OP_JNZ: begin

            end

            // OTHER
            NOP: begin

            end
            OP_KIL: begin

            end
        endcase
    end
end