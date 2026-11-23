`default_nettype none

module ControlUnit (
    input wire [3:0] opcode,
    input wire [3:0] opt1,
    input wire [3:0] opt2,
    input wire [7:0] reg_val1,
    input wire [7:0] reg_val2,
    input wire [3:0] curr_sflags,
    input wire [2:0] state,

    output reg [3:0] sflags,
    output reg mem_write,
    output reg reg_write,
    output reg flag_write,
    output reg [7:0] datout,
    output reg [7:0] jmp_target,
    output reg jmp_en
);

`include "defines.vh"

reg [8:0] result;

always @(*) begin
    reg_write = 1'b0;
    mem_write = 1'b0;
    flag_write = 1'b0;
    datout = 8'h00;
    sflags = 4'h0;
    jmp_target = {opt1, opt2};
    jmp_en = 1'b0;
    result = 9'h000;

    if (state == `EXECUTE) begin
        case (opcode)
            `OP_NST: begin
                case (opt1)
                    `OP_NST_MOV: begin
                        datout = reg_val1;
                        reg_write = 1'b1;
                    end

                    `OP_NST_CMP: begin
                        datout = reg_val1 - reg_val2;
                        sflags[2] = reg_val1 >= reg_val2;
                        sflags[3] = (reg_val1[7] ^ reg_val2[7]) &
                                    (reg_val1[7] ^ datout[7]);
                        flag_write = 1'b1;
                    end

                    `OP_NST_KIL: begin
                    end

                    default: ;
                endcase
            end

            `OP_ST: begin
                datout = reg_val1;
                mem_write = 1'b1;
            end

            `OP_LDI: begin
                datout = {opt1, opt2};
                reg_write = 1'b1;
            end

            `OP_ADD: begin
                result = {1'b0, reg_val1} + {1'b0, reg_val2};
                datout = result[7:0];
                sflags[2] = result[8];
                sflags[3] = ~(reg_val1[7] ^ reg_val2[7]) &
                            (reg_val1[7] ^ datout[7]);
                reg_write = 1'b1;
                flag_write = 1'b1;
            end

            `OP_SUB: begin
                datout = reg_val1 - reg_val2;
                sflags[2] = reg_val1 >= reg_val2;
                sflags[3] = (reg_val1[7] ^ reg_val2[7]) &
                            (reg_val1[7] ^ datout[7]);
                reg_write = 1'b1;
                flag_write = 1'b1;
            end

            `OP_XOR: begin
                result = reg_val1 ^ reg_val2;
                datout = result[7:0];
                reg_write = 1'b1;
                flag_write = 1'b1;
            end

            `OP_OR: begin
                datout = reg_val1 | reg_val2;
                reg_write = 1'b1;
                flag_write = 1'b1;
            end

            `OP_AND: begin
                datout = reg_val1 & reg_val2;
                reg_write = 1'b1;
                flag_write = 1'b1;
            end

            `OP_NOT: begin
                datout = ~reg_val1;
                reg_write = 1'b1;
                flag_write = 1'b1;
            end

            `OP_SHL: begin
                datout = reg_val1 << 1;
                sflags[2] = reg_val1[7];
                reg_write = 1'b1;
                flag_write = 1'b1;
            end

            `OP_SHR: begin
                datout = reg_val1 >> 1;
                sflags[2] = reg_val1[0];
                reg_write = 1'b1;
                flag_write = 1'b1;
            end

            `OP_JZ: begin
                jmp_en = curr_sflags[0];
            end

            `OP_JNZ: begin
                jmp_en = !curr_sflags[0];
            end
        endcase

        if (flag_write) begin
            sflags[0] = datout == 8'h00;
            sflags[1] = datout[7];
        end
    end
end

endmodule