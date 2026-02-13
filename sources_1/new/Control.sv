`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/30 8:26:09
// Design Name: 
// Module Name: Control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Control(
    input  logic [6:0]  opcode      ,
    output logic [1:0]  NpcOp       ,
    output logic        RegWrite    ,
    output logic [1:0]  MemToReg    ,
    output logic        MemWrite    ,
    output logic        OffsetOrigin,
    output logic        ALUSrc      
);
   // controller module
   always_comb begin
   // ... inside always_comb ...
case (opcode)
    // 1. R-Type (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA)
    7'b0110011: begin 
        NpcOp = 2'b00; RegWrite = 1; MemToReg = 2'b00; MemWrite = 0; ALUSrc = 0; OffsetOrigin = 0;
    end

    // 2. I-Type ALU (ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI) -> 缺失！
    7'b0010011: begin
        NpcOp = 2'b00; RegWrite = 1; MemToReg = 2'b00; MemWrite = 0; ALUSrc = 1; OffsetOrigin = 0;
    end

    // 3. Load (LB, LH, LW, LBU, LHU)
    7'b0000011: begin 
        NpcOp = 2'b00; RegWrite = 1; MemToReg = 2'b01; MemWrite = 0; ALUSrc = 1; OffsetOrigin = 0;
    end

    // 4. Store (SB, SH, SW)
    7'b0100011: begin 
        NpcOp = 2'b00; RegWrite = 0; MemToReg = 2'b00; MemWrite = 1; ALUSrc = 1; OffsetOrigin = 1;
    end

    // 5. Branch (BEQ, BNE, BLT, BGE, BLTU, BGEU) -> 缺失！
    7'b1100011: begin
        NpcOp = 2'b01; // 告诉 NPC 这是一个条件跳转
        RegWrite = 0; MemToReg = 2'b00; MemWrite = 0; ALUSrc = 0; OffsetOrigin = 0;
    end

    // 6. JAL (Jump and Link) -> 缺失！
    7'b1101111: begin
        NpcOp = 2'b11; // 告诉 NPC 这是一个无条件跳转
        RegWrite = 1; MemToReg = 2'b10; // 写回 PC+4
        MemWrite = 0; ALUSrc = 0; OffsetOrigin = 0;
    end

    // 7. JALR (Jump and Link Register) -> 缺失！
    7'b1100111: begin
        NpcOp = 2'b10; // 告诉 NPC 这是一个寄存器跳转
        RegWrite = 1; MemToReg = 2'b10; // 写回 PC+4
        MemWrite = 0; ALUSrc = 1; // ALU 计算 rs1 + imm
        OffsetOrigin = 0;
    end

    // 8. LUI (Load Upper Immediate) -> 缺失！
    7'b0110111: begin
        NpcOp = 2'b00; RegWrite = 1; MemToReg = 2'b11; // Mux4 选择 imm
        MemWrite = 0; ALUSrc = 1; OffsetOrigin = 0;
    end

    // 默认
    default: begin
        NpcOp = 2'b00; RegWrite = 0; MemToReg = 2'b00; MemWrite = 0; ALUSrc = 0; OffsetOrigin = 0;
    end
endcase
   end
endmodule
