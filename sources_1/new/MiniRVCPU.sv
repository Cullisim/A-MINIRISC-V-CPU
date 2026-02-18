`timescale 1ns / 1ps

module miniRV_SoC (
    input  logic         fpga_rst,   // 高电平有效复位
    input  logic         fpga_clk,   // 时钟

    // Debug 接口 (用于仿真波形观察)
    output logic         debug_wb_have_inst, 
    output logic [31:0]  debug_wb_pc,        
    output               debug_wb_ena,       
    output logic [ 4:0]  debug_wb_reg,       
    output logic [31:0]  debug_wb_value      
);

    // 1. 内部信号定义
    logic cpu_clk;
    assign cpu_clk = fpga_clk; // 时钟直连

    // CPU 与 存储器之间的连接信号
    logic [31:0] inst_addr;
    logic [31:0] inst;
    logic [31:0] data_addr;
    logic [31:0] data_rdata;
    logic        data_wen;
    logic [31:0] data_wdata;

    // =========================================================
    // 2. 模块例化 
    // =========================================================

    // --- CPU Core ---
    myCPU Core_cpu (
        .cpu_rst            (fpga_rst),
        .cpu_clk            (cpu_clk),

        // 指令存储器接口 (IROM)
        .inst_addr          (inst_addr),
        .inst               (inst),

        // 数据存储器接口 (DRAM) - 直接连接!
        .data_addr          (data_addr),
        .data_rdata         (data_rdata),
        .data_wen           (data_wen),
        .data_wdata         (data_wdata),

        // Debug 信号
        .debug_wb_have_inst (debug_wb_have_inst),
        .debug_wb_pc        (debug_wb_pc),
        .debug_wb_ena       (debug_wb_ena),
        .debug_wb_reg       (debug_wb_reg),
        .debug_wb_value     (debug_wb_value)
    );

    // --- IROM (指令存储器) ---
    // PC 是字节地址，而 IP 核按 32位字(4字节) 寻址
    // 因此取 [15:2] (假设 IP 核大小为 16KB / 14位地址线)
    IROM Mem_IROM (
        .a          (inst_addr[15:2]), 
        .spo        (inst)
    );

    // --- DRAM (数据存储器) ---
    // 直接连接 CPU 的数据端口
    // 同样取 [15:2] 作为字地址
    DRAM Mem_DRAM (
        .clk        (cpu_clk),          // 必须接时钟
        .a          (data_addr[15:2]),  // 地址线
        .spo        (data_rdata),       // 读出数据 -> CPU
        .we         (data_wen),         // 写使能 -> CPU
        .d          (data_wdata)        // 写数据 -> CPU
    );

endmodule