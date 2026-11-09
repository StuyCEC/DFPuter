module ControlUnit (
    input wire[3:0] opcode,
    input wire[3:0] opt1,
    input wire[3:0] opt2,
    input wire[7:0] reg_val1,
    input wire[7:0] reg_val2,
    input wire[7:0] mem_val1,
    input wire[7:0] mem_val2,
    input wire clk,

    input wire[2:0] state,
    
    output wire[3:0] sflags,
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
            OP_MOV: begin          // MOV RD Rx
                datout = reg_val1;
                reg_write = 1;
            end
            OP_LD: begin          // LD RD Mx{1} Mx{2}
                datout = {mem_val1, mem_val2};
                reg_write = 1;
            end
            OP_ST: begin         // ST RR Mx{1} Mx{2}
                datout = reg_val1;
                mem_write = 1;
            end
            OP_LDI: begin        // LDI RD Rx{1} Rx{2}
                datout = {opt1, opt2};
                reg_write = 1;
            end

            // ALU CODES
            OP_ADD: begin
                datout = reg_val1 + reg_val1;
                // sflags[2] = CARRY(reg_val1+reg_val2);
                // sflags[3] = 
                reg_write = 1;
            end
            OP_SUB: begin
                datout = reg_val1 - reg_val1;
                reg_write = 1;
            end
            OP_OR: begin
                datout = reg_val1 | reg_val1;
                reg_write = 1;
            end
            OP_AND: begin
                datout = reg_val1 & reg_val1;
                reg_write = 1;
            end
            OP_NOT: begin
                datout = ~reg_val1;
                reg_write = 1;
            end
            OP_SHL: begin
                datout = reg_val1 << 1;
                reg_write = 1;
            end
            OP_SHR: begin
                datout = reg_val1 >> 1;
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