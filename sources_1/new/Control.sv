`timescale 1ns / 1ps
//根据opcode生成控制信号


module Control(
    input  logic [6:0]  opcode      ,   
    output logic [1:0]  NpcOp       ,    // 00: 普通指令, 01: 条件跳转, 10: 寄存器跳转, 11: 无条件跳转
    output logic        RegWrite    ,    // 寄存器写使能
    output logic [1:0]  MemToReg    ,    // 00: ALU结果, 01: 内存数据, 10: PC+4, 11: imm
    output logic        MemWrite    ,
    output logic        OffsetOrigin,
    output logic        ALUSrc      
);
   
   always_comb begin
   
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
