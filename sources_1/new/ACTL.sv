`timescale 1ns / 1ps
//采用单极译码方式，用ACTL模块输出对应的信号进入ALU中
module ACTL(
    input  logic [6:0] opcode,
    input  logic [3:0] funct,
    output logic [3:0] ALUControl
);

    always_comb begin
        // 使用 casez 进行模糊匹配
        casez ({opcode, funct})
            
            // ============================================
            // 1. R-Type 指令 (opcode: 0110011)
            // ============================================
            {7'b0110011, 4'b0000}: ALUControl = 4'b0000; // ADD
            {7'b0110011, 4'b1000}: ALUControl = 4'b0001; // SUB
            {7'b0110011, 4'b0111}: ALUControl = 4'b0010; // AND
            {7'b0110011, 4'b0110}: ALUControl = 4'b0011; // OR
            {7'b0110011, 4'b0100}: ALUControl = 4'b0100; // XOR
            {7'b0110011, 4'b0001}: ALUControl = 4'b0101; // SLL
            {7'b0110011, 4'b0101}: ALUControl = 4'b0110; // SRL
            {7'b0110011, 4'b1101}: ALUControl = 4'b0111; // SRA

            // ============================================
            // 2. I-Type 运算指令 (opcode: 0010011)
            // ============================================
            // 算术/逻辑运算 (funct3 匹配部分位)
            {7'b0010011, 4'b?000}: ALUControl = 4'b0000; // ADDI (funct3=000)
            {7'b0010011, 4'b?111}: ALUControl = 4'b0010; // ANDI (funct3=111)
            {7'b0010011, 4'b?110}: ALUControl = 4'b0011; // ORI  (funct3=110)
            {7'b0010011, 4'b?100}: ALUControl = 4'b0100; // XORI (funct3=100)
            
            // 移位运算 (必须精确匹配 inst[30] 和 funct3)
            // SLLI (funct3=001, inst[30]=0) -> funct=0001
            {7'b0010011, 4'b0001}: ALUControl = 4'b0101; // SLLI
            
            // SRLI (funct3=101, inst[30]=0) -> funct=0101
            
            {7'b0010011, 4'b0101}: ALUControl = 4'b0110; // SRLI 
            
            // SRAI (funct3=101, inst[30]=1) -> funct=1101
            {7'b0010011, 4'b1101}: ALUControl = 4'b0111; // SRAI

            // ============================================
            // 3. 访存指令 (Load/Store 使用加法计算地址)
            // ============================================
            {7'b0000011, 4'b????}: ALUControl = 4'b0000; // LW (Add)
            {7'b0100011, 4'b????}: ALUControl = 4'b0000; // SW (Add)

            // ============================================
            // 4. 分支指令 (opcode: 1100011)
            // ============================================
            {7'b1100011, 4'b?000}: ALUControl = 4'b1000; // BEQ
            {7'b1100011, 4'b?001}: ALUControl = 4'b1001; // BNE
            {7'b1100011, 4'b?100}: ALUControl = 4'b1010; // BLT
            {7'b1100011, 4'b?101}: ALUControl = 4'b1011; // BGE

            // ============================================
            // 5. 跳转指令
            // ============================================
            {7'b1101111, 4'b????}: ALUControl = 4'b0000; // JAL (Add, PC+4 logic handled elsewhere)
            {7'b1100111, 4'b????}: ALUControl = 4'b0000; // JALR (Add rs1+imm)
            {7'b0110111, 4'b????}: ALUControl = 4'b0000; // LUI (ALU not used or Add)

            // 默认加法
            default: ALUControl = 4'b0000;
        endcase
    end
endmodule