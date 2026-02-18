`timescale 1ns / 1ps

module IMMGEN#(
    parameter   DATAWIDTH = 32	
)(
    input  logic [31:0]            instr   ,
    output logic [DATAWIDTH - 1:0] imm       
);
   // 输出不同类型指令的立即数
   always_comb begin
    case (instr[6:0])
        7'b0010011: imm = {{20{instr[31]}}, instr[31:20]}; // I-type
        7'b0000011: imm = {{20{instr[31]}}, instr[31:20]}; // I-type
        7'b0100011: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // S-type
        7'b1100011: imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type
        7'b1101111: imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}; // J-type
        7'b1100111: imm = {{20{instr[31]}}, instr[31:20]}; // I-type (jalr)
        7'b0110111, 7'b0010111: imm = {instr[31:12], 12'b0};
        default: imm = 0;
    endcase
   end
endmodule