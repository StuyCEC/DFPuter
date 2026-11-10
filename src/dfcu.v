module ControlUnit (
    input wire[3:0] opcode,
    input wire[3:0] opt1,
    input wire[3:0] opt2,
    input wire[7:0] reg_val1,
    input wire[7:0] reg_val2,
    input wire[7:0] mem_val1,
    input wire[7:0] mem_val2,
    input wire[3:0] curr_flags,
    input wire clk,

    input wire[2:0] state,
    
    output wire[3:0] sflags,
    output reg mem_write, 
    output reg reg_write,
    output reg[7:0] datout,
    output reg[11:0] jmp_target,
    output reg jmp_en
);

`include "defines.vh"

always @(*) begin
    reg_write = 1'b0;
    mem_write = 1'b0;
    datout = 16'h0;

    if (state == EXECUTE) begin
        case (opcode)
            // MEM, REGFILE CODES
            OP_MOV: begin          // MOV Rd Rx
                datout = reg_val1;
                reg_write = 1;
            end
            OP_LD: begin          // LD Rd Mx{1} Mx{2}
                datout = {mem_val1, mem_val2};
                reg_write = 1;
            end
            OP_ST: begin         // ST Rr Mx{1} Mx{2}
                datout = reg_val1;
                mem_write = 1;
            end
            OP_LDI: begin        // LDI Rd DATA_BYTE
                datout = {opt1, opt2};
                reg_write = 1;
            end

            // ALU CODES
            OP_ADD: begin        // ADD Rd DAT1 DAT2
                datout = reg_val1 + reg_val1;
                // sflags[2] = CARRY(reg_val1+reg_val2);
                // sflags[3] = 
                reg_write = 1;
            end
            OP_SUB: begin        // SUB Rd DAT1 DAT2
                datout = reg_val1 - reg_val1;
                reg_write = 1;
            end
            OP_OR: begin         // OR Rd DAT1 DAT2
                datout = reg_val1 | reg_val1;
                reg_write = 1;
            end
            OP_AND: begin        // AND Rd DAT1 DAT2
                datout = reg_val1 & reg_val1;
                reg_write = 1;
            end
            OP_NOT: begin       // NOT Rd DAT1
                datout = ~reg_val1;
                reg_write = 1;
            end
            OP_SHL: begin       // SHL Rd DAT1
                datout = reg_val1 << 1;
                reg_write = 1;
            end
            OP_SHR: begin       // SHR Rd DAT1
                datout = reg_val1 >> 1;
                reg_write = 1;
            end

            // LOOP CODES
            OP_JMP: begin
                jmp_target = {4'h0, opt1, opt2};
                jmp_en = 1;
            end
            OP_JZ: begin
                if (curr_sflags[0] == 1'b1) begin
                    jmp_en = 1'b1;
                    jmp_target = {4'h0, opt1, opt2};
                end
            end
            OP_JNZ: begin
                if (curr_sflags[0] == 1'b0) begin
                    jmp_en = 1'b1;
                    jmp_target = {4'h0, opt1, opt2};
                end
            end

            // OTHER
            NOP: begin

            end
            OP_KIL: begin

            end
        endcase

        case (opcode) begin
            OP_ADD, OP_SUB, OP_AND, OP_OR, OP_NOT, OP_SHL,OP_SHR: sflags[0] = 1'b1;
        end
    end
end