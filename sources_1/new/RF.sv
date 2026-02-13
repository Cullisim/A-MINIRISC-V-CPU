`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/08 12:42:16
// Design Name: 
// Module Name: RF
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

module RF #(
    parameter   ADDR_WIDTH = 5  ,
    parameter   DATAWIDTH  = 32
)(
    input  logic                    clk            ,
    input  logic                    rst            ,
    // Write rd                   
    input  logic                    wen      ,
    input  logic [ADDR_WIDTH - 1:0] waddr    ,
    input  logic [DATAWIDTH - 1:0]  wdata       ,
    // Read  rs1 rs2
    input  logic [ADDR_WIDTH - 1:0] rR1   ,
    input  logic [ADDR_WIDTH - 1:0] rR2   ,

    output logic [DATAWIDTH - 1:0]  rR1_data  ,
    output logic [DATAWIDTH - 1:0]  rR2_data
);
    logic [DATAWIDTH - 1:0] reg_bank [31:0];
 // -----------------------------------------------------
    // 1. ������ (Read Operations) - ����߼�
    // -----------------------------------------------------
    // ������߼��ǣ��������ַ��0�������0��RISC�ܹ������淶��0�żĴ�����Ϊ0����
    // ���������Ӧ��ַ�ļĴ���ֵ��
    // ������ʵ�鲻Ҫ��0�żĴ�����Ϊ0������ֱ��д��assign rs_reg1_rdata = reg_bank[rs_reg1_addr];
    
  // ֱ�Ӷ�ȡ reg_bank ���飬���ٶ� 0 ��ַ�������ж�
assign  rR1_data = reg_bank[rR1];
assign rR2_data = reg_bank[rR2];
    // -----------------------------------------------------
    // 2. д���� (Write Operations) - ʱ���߼�
    // -----------------------------------------------------
    // ����������wr_reg_enΪ1ʱд�룬rstΪ�첽�ߵ�ƽ��λ
    
    integer i; // ����ѭ����λ
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // �첽��λ�������мĴ�������
            for (i = 0; i < 32; i = i + 1) begin
                reg_bank[i] <= {DATAWIDTH{1'b0}};
            end
        end
        else if (wen && (waddr != 0)) begin
            // дʹ����Ч �� д���ַ��Ϊ0 ʱд������
            // (ͬ����Ϊ�˱���0�żĴ���������д)
            reg_bank[waddr] <= wdata;
        end
    end
endmodule