`timescale 1ns / 1ps

module tb_miniRV_SoC();

    // 1. 信号定义
    logic        fpga_clk;
    logic        fpga_rst;

    logic        debug_wb_have_inst;
    logic [31:0] debug_wb_pc;
    logic        debug_wb_ena;
    logic [4:0]  debug_wb_reg;
    logic [31:0] debug_wb_value;

    integer err_count = 0;

    // 2. 时钟与复位
    initial begin
        fpga_clk = 0;
        forever #5 fpga_clk = ~fpga_clk;
    end

    initial begin
        fpga_rst = 1;
        #200;
        fpga_rst = 0; 
    end

    // 3. 例化 DUT
    miniRV_SoC u_soc (
        .fpga_rst           (fpga_rst),
        .fpga_clk           (fpga_clk),
        .debug_wb_have_inst (debug_wb_have_inst),
        .debug_wb_pc        (debug_wb_pc),
        .debug_wb_ena       (debug_wb_ena),
        .debug_wb_reg       (debug_wb_reg),
        .debug_wb_value     (debug_wb_value)
    );

    // 4. 验证任务
    
    // 【任务 A】Check: 用于必须写回的指令 (ADDI, LW 等)
    task check(input string inst_name, input int exp_reg, input int exp_val);
        begin
            // 严格检查：如果到了该指令的 PC，但 ena 为 0，说明指令读出来是 0 (NOP)
            if (!debug_wb_ena) begin
                $display("\033[31m[ERROR] %s (PC=0x%h): Expected WriteBack but debug_wb_ena=0! \n(Hint: CPU likely executing NOPs. Check if IROM .coe is loaded!)\033[0m", 
                         inst_name, debug_wb_pc);
                err_count++;
                $stop; // 遇到错误直接停止，方便调试
            end 
            else if (debug_wb_reg !== exp_reg) begin
                $display("\033[31m[ERROR] %s (PC=0x%h): Wrong Reg! Exp: x%0d, Got: x%0d\033[0m", inst_name, debug_wb_pc, exp_reg, debug_wb_reg);
                err_count++;
                $stop;
            end 
            else if (debug_wb_value !== exp_val) begin
                $display("\033[31m[ERROR] %s (PC=0x%h): Value Mismatch! Exp: 0x%h, Got: 0x%h\033[0m", inst_name, debug_wb_pc, exp_val, debug_wb_value);
                err_count++;
                $stop;
            end 
            else begin
                $display("\033[32m[PASS]\033[0m PC=0x%h | %-15s | Reg=x%0d | Val=0x%h", debug_wb_pc, inst_name, debug_wb_reg, debug_wb_value);
            end
        end
    endtask

    // 【任务 B】Monitor: 用于不写回的指令 (SW, BEQ 等)
    task monitor(input string inst_name);
        begin
            // 反向检查：如果 SW 指令竟然产生了写回，那也是错的
            if (debug_wb_ena) begin
                $display("\033[31m[ERROR] %s (PC=0x%h): Should NOT WriteBack but debug_wb_ena=1!\033[0m", inst_name, debug_wb_pc);
                err_count++;
                $stop;
            end else begin
                $display("\033[33m[INFO]\033[0m PC=0x%h | %-15s | Executed (No Writeback)", debug_wb_pc, inst_name);
            end
        end
    endtask

    // 5. 主监控进程
    // 使用 negedge 采样，确保信号稳定
    always @(negedge fpga_clk) begin
        if (!fpga_rst) begin
            case (debug_wb_pc)
                // --- 1. 基础运算 (必须 Check) ---
                32'h00: check("ADDI x1, 10",   1, 10);
                32'h04: check("ADDI x2, -5",   2, -5); 
                32'h08: check("ADD x3",        3, 5);  
                32'h0C: check("SUB x4",        4, 15); 
                32'h10: check("AND x5",        5, 10); 
                32'h14: check("OR  x6",        6, -5); 
                32'h18: check("XOR x7",        7, -15);
                32'h1C: check("SLL x8",        8, 320);
                32'h20: check("SRL x9",        9, 0);  
                32'h24: check("SRA x10",       10, -1);
                
                // --- 2. I-Type 逻辑 ---
                32'h28: check("LUI x11",       11, 4096);
                32'h2C: check("ORI x12",       12, 15);
                32'h30: check("ANDI x13",      13, 10);
                32'h34: check("XORI x14",      14, 10); 
                32'h38: check("SLLI x15",      15, 60); 
                32'h3C: check("SRLI x16",      16, 15); 
                32'h40: check("SRAI x17",      17, -1); 

                // --- 3. 访存 (SW用Monitor, LW用Check) ---
                32'h44: monitor("SW Mem");      
                32'h48: check("LW x18",        18, 15); // <--- 如果 IROM 空，这里会报错

                // --- 4. 分支跳转 (Monitor) ---
                32'h4C: monitor("BEQ Check");   
                32'h54: check("BEQ Success",   19, 1);
                
                32'h58: monitor("BNE Check");   
                32'h60: check("BNE Success",   20, 1);
                
                32'h64: monitor("BLT Check");   
                32'h6C: check("BLT Success",   21, 1);
                
                32'h70: monitor("BGE Check");   
                32'h78: check("BGE Success",   22, 1);

                // --- 5. 跳转 ---
                32'h7C: check("JAL Link",      23, 32'h80);
                32'h84: check("JAL Target",    24, 1);
                32'h88: check("JALR Prep",     25, 144);
                32'h8C: check("JALR Link",     26, 144); 
                32'h90: check("JALR Target",   27, 1);
            endcase
        end
    end

    // 6. 结束判断
    initial begin
        #5000;
        if (err_count == 0) begin
            $display("\n==================================================");
            $display("\033[32m      ALL SOC TESTS PASSED SUCCESSFULLY!      \033[0m");
            $display("==================================================");
        end else begin
            $display("\n==================================================");
            $display("\033[31m      SIMULATION FAILED (See Errors Above)    \033[0m");
            $display("==================================================");
        end
        $finish;
    end

endmodule