`timescale 1ns / 1ps

module tb_myCPU();

    // 1. 信号定义
    logic        cpu_clk;
    logic        cpu_rst;
    logic [31:0] inst_addr;
    logic [31:0] inst;
    logic [31:0] data_addr;
    logic [31:0] data_rdata;
    logic        data_wen;
    logic [31:0] data_wdata;

    // Debug 接口
    logic        debug_wb_have_inst;
    logic [31:0] debug_wb_pc;
    logic        debug_wb_ena;
    logic [4:0]  debug_wb_reg;
    logic [31:0] debug_wb_value;

    // 2. 时钟与复位
    initial begin
        cpu_clk = 0;
        forever #5 cpu_clk = ~cpu_clk;
    end

    initial begin
        cpu_rst = 1;
        #100; 
        cpu_rst = 0;
    end

    // 3. 存储器模型
    logic [31:0] irom_mem [0:4095];
    initial begin
        $readmemh("D:/lab/cs2025_v2-stu/CPU5/STU/MiniRV/MiniRV.srcs/sources_1/new/inst_data.txt", irom_mem); 
    end
    assign inst = irom_mem[inst_addr[13:2]];

    logic [31:0] dram_mem [0:4095];
    assign data_rdata = dram_mem[data_addr[13:2]];
    always @(posedge cpu_clk) begin
        if (data_wen) dram_mem[data_addr[13:2]] <= data_wdata;
    end

    // 4. DUT 例化
    myCPU u_cpu (
        .cpu_rst            (cpu_rst),
        .cpu_clk            (cpu_clk),
        .inst_addr          (inst_addr),
        .inst               (inst),
        .data_addr          (data_addr),
        .data_rdata         (data_rdata),
        .data_wen           (data_wen),
        .data_wdata         (data_wdata),
        .debug_wb_have_inst (debug_wb_have_inst),
        .debug_wb_pc        (debug_wb_pc),
        .debug_wb_ena       (debug_wb_ena),
        .debug_wb_reg       (debug_wb_reg),
        .debug_wb_value     (debug_wb_value)
    );

    // 5. 校验逻辑
    task check_inst(input string inst_name, input int exp_reg, input int exp_val);
        begin
            if (debug_wb_reg !== exp_reg) begin
                $display("\n\033[31m[ERROR] %s (PC=0x%h): Wrong Reg! Exp: x%0d, Got: x%0d\033[0m", 
                         inst_name, debug_wb_pc, exp_reg, debug_wb_reg);
                $stop;
            end else if (debug_wb_value !== exp_val) begin
                $display("\n\033[31m[ERROR] %s (PC=0x%h): Value Mismatch! Exp: 0x%h, Got: 0x%h\033[0m", 
                         inst_name, debug_wb_pc, exp_val, debug_wb_value);
                $stop;
            end else begin
                $display("\033[32m[PASS]\033[0m PC=0x%h | %-15s | Reg=x%0d | Val=0x%h", 
                         debug_wb_pc, inst_name, debug_wb_reg, debug_wb_value);
            end
        end
    endtask

    always @(negedge cpu_clk) begin
        if (!cpu_rst && debug_wb_ena && debug_wb_reg != 0) begin
            case (debug_wb_pc)
                // --- 基础指令 ---
                32'h00: check_inst("ADDI x1, 10",   1, 10);
                32'h04: check_inst("ADDI x2, -5",   2, -5); 
                32'h08: check_inst("ADD x3",        3, 5);  
                32'h0C: check_inst("SUB x4",        4, 15); 
                32'h10: check_inst("AND x5",        5, 10); 
                32'h14: check_inst("OR  x6",        6, -5); 
                32'h18: check_inst("XOR x7",        7, -15);
                32'h1C: check_inst("SLL x8",        8, 320);
                32'h20: check_inst("SRL x9",        9, 0);  
                32'h24: check_inst("SRA x10",       10, -1);
                32'h28: check_inst("LUI x11",       11, 4096);
                32'h2C: check_inst("ORI x12",       12, 15);
                32'h30: check_inst("ANDI x13",      13, 10);
                32'h34: check_inst("XORI x14",      14, 10); 
                32'h38: check_inst("SLLI x15",      15, 60); 
                32'h3C: check_inst("SRLI x16",      16, 15); 
                32'h40: check_inst("SRAI x17",      17, -1); 

                // --- 访存 (SW 44h 忽略) ---
                32'h48: check_inst("LW x18",        18, 15); 

                // --- 分支测试 (关键修复点) ---
                // BEQ x12(15), x18(15) -> 跳过 50h(Trap)，去 54h
                32'h54: check_inst("BEQ Success",   19, 1);
                
                // BNE x12(15), x0(0) -> 跳过 5Ch(Trap)，去 60h
                32'h60: check_inst("BNE Success",   20, 1);

                // BLT x2(-5), x1(10) -> 跳过 68h(Trap)，去 6Ch
                32'h6C: check_inst("BLT Success",   21, 1);

                // BGE x1(10), x2(-5) -> 跳过 74h(Trap)，去 78h
                32'h78: check_inst("BGE Success",   22, 1);

                // --- 跳转测试 ---
                // JAL x23, 8 -> PC=7Ch, Link=80h, Target=84h
                32'h7C: check_inst("JAL Link",      23, 32'h80);
                32'h84: check_inst("JAL Target",    24, 1);

                // JALR x0, x25, 0 -> x25=90h, Target=90h
                32'h88: check_inst("JALR Prep",     25, 144); // 90h
                // 【新增】检查 JALR 的链接地址写回 (PC+4 = 0x90)
                32'h8C: check_inst("JALR Link",     26, 144); // 0x90 (144)
                // 32'h8C: JALR executing (no wb to x0)
                32'h90: check_inst("JALR Target",   27, 1);

                default: begin
                    $display("\n\033[31m[ERROR] Unexpected Writeback at PC=0x%h (Reg x%0d, Val 0x%h)\033[0m", 
                             debug_wb_pc, debug_wb_reg, debug_wb_value);
                    $display("        This means a BRANCH/JUMP failed and hit a TRAP.");
                    $stop;
                end
            endcase
        end
    end

    initial begin
        #3000;
        $display("\n==================================================");
        $display("\033[32m      ALL TESTS PASSED SUCCESSFULLY!      \033[0m");
        $display("==================================================");
        $finish;
    end

endmodule