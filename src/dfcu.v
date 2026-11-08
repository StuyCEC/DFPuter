module ControlUnit (
    input reg[3:0] opcode,
    input reg[3:0] opt1,
    input reg[3:0] opt2,

    input wire clk,

    input reg[2:0] state,

    output reg[3:0] rd
)

always @(*) begin
    if (state == )
end