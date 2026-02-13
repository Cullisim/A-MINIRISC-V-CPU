`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/24 10:51:04
// Design Name: 
// Module Name: myCPU
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

module myCPU (
    input  logic         cpu_rst,
    input  logic         cpu_clk,

    // Interface to IROM, you need add some signals
    // 1. 新增：IROM (指令存储器) 接口
    // ============================================
    output logic [31:0]  inst_addr,     // PC 输出
    input  logic [31:0]  inst,          // 指令输入

    // ============================================
    // 2. 新增：DRAM (数据存储器) 接口
    // ============================================
    output logic [31:0]  data_addr,     // 访存地址
    input  logic [31:0]  data_rdata,    // 读数据
    output logic         data_wen,      // 写使能
    output logic [31:0]  data_wdata,    // 写数据
    // Interface to DRAM, you need add some signals

    output logic         debug_wb_have_inst,
    output logic [31:0]  debug_wb_pc,
    output               debug_wb_ena,
    output logic [ 4:0]  debug_wb_reg,
    output logic [31:0]  debug_wb_value

);

    // TODO: 完成你自己的单周期CPU设计
    
   // ... 信号定义区域 ...
    logic [31:0] npc_offset_input; // 新增一个中间信号
    // =========================================================================
    // 1. 内部信号定义
    // =========================================================================
    logic [31:0] pc_curr;
    logic [31:0] pc_next;
    logic [31:0] pc_add4;
    
    logic [31:0] imm;
    
    logic [31:0] rR1_data;
    logic [31:0] rR2_data;
    logic [31:0] wb_data;
    
    logic [31:0] alu_op_A;
    logic [31:0] alu_op_B;
    logic [31:0] alu_result;
    logic [3:0]  alu_control_sig;
    logic        alu_is_true;
    
    // Control Signals
    logic [1:0]  npc_op;
    logic        reg_write;
    logic [1:0]  mem_to_reg;
    logic        mem_write;
    logic        offset_origin; // 来自 Control，但在当前 NPC/IMMGEN 设计中可能由 NPC 直接处理
    logic        alu_src;

    // =========================================================================
    // 2. 模块例化
    // =========================================================================

    // --- PC (Program Counter) ---
    PC u_pc (
        .clk    (cpu_clk),
        .rst    (cpu_rst),
        .npc    (pc_next),
        .pc_out (pc_curr)
    );
    
    // 连接 IROM 地址接口
    assign inst_addr = pc_curr;
    assign npc_offset_input = (npc_op == 2'b10) ? alu_result : imm;

    // --- NPC (Next PC Logic) ---
    NPC u_npc (
        .isTrue (alu_is_true),
        .npc_op (npc_op),
        .pc     (pc_curr),
        .offset (npc_offset_input),      // 跳转偏移量来自立即数
        .npc    (pc_next),
        .pcadd4 (pc_add4)
    );

    // --- IMMGEN (Immediate Generator) ---
    IMMGEN u_immgen (
        .instr (inst),
        .imm   (imm)
    );

    // --- Control Unit ---
    Control u_control (
        .opcode       (inst[6:0]),
        .NpcOp        (npc_op),
        .RegWrite     (reg_write),
        .MemToReg     (mem_to_reg),
        .MemWrite     (mem_write),
        .OffsetOrigin (offset_origin),
        .ALUSrc       (alu_src)
    );

    // --- Register File (RF) ---
    RF u_rf (
        .clk      (cpu_clk),
        .rst      (cpu_rst),
        .wen      (reg_write),
        .waddr    (inst[11:7]),  // rd
        .wdata    (wb_data),
        .rR1      (inst[19:15]), // rs1
        .rR2      (inst[24:20]), // rs2
        .rR1_data (rR1_data),
        .rR2_data (rR2_data)
    );

    // --- ACTL (ALU Control) ---
    // 注意：funct 输入需要拼接 inst[30] 和 inst[14:12]
    ACTL u_actl (
        .opcode     (inst[6:0]),
        .funct      ({inst[30], inst[14:12]}),
        .ALUControl (alu_control_sig)
    );

    // --- MUX2_1 (ALU Source B Select) ---
    // 选择 rR2_data (0) 还是 imm (1)
    MUX2_1 #( .WIDTH(32) ) u_mux_alu_src (
        .A       (rR2_data),
        .B       (imm),
        .Control (alu_src),
        .Result  (alu_op_B)
    );

    // --- ALU ---
    assign alu_op_A = rR1_data;
    
    ALU u_alu (
        .A          (alu_op_A),
        .B          (alu_op_B),
        .ALUControl (alu_control_sig),
        .Result     (alu_result),
        .isTrue     (alu_is_true)
    );

    // --- Interface to DRAM ---
    assign data_addr  = alu_result;
    assign data_wdata = rR2_data; // Store 指令存储的数据总是来自 rs2
    assign data_wen   = mem_write;

    // --- MUX4_1 (Write Back Select) ---
    // 00: ALU Result
    // 01: DRAM Read Data
    // 10: PC + 4 (JAL/JALR)
    // 11: Immediate (LUI) - 对应图5-20红线
    MUX4_1 #( .WIDTH(32) ) u_mux_wb (
        .A       (alu_result),
        .B       (data_rdata),
        .C       (pc_add4),
        .D       (imm),       // LUI direct
        .Control (mem_to_reg),
        .Result  (wb_data)
    );

    // =========================================================================
    // 3. Debug 信号赋值
    // =========================================================================
    // 假设每条指令都有效（单周期），复位期间除外
    assign debug_wb_have_inst = ~cpu_rst; 
    assign debug_wb_pc        = pc_curr;
    assign debug_wb_ena       = reg_write & ~cpu_rst;
    assign debug_wb_reg       = inst[11:7];
    assign debug_wb_value     = wb_data;
endmodule

