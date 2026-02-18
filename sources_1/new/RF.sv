`timescale 1ns / 1ps
//寄存器堆的读取与写入操作


module RF #(
    parameter   ADDR_WIDTH = 5  ,
    parameter   DATAWIDTH  = 32
)(
    input  logic                    clk            ,
    input  logic                    rst            ,
    // 写入                  
    input  logic                    wen      ,
    input  logic [ADDR_WIDTH - 1:0] waddr    ,
    input  logic [DATAWIDTH - 1:0]  wdata       ,
    // 读取
    input  logic [ADDR_WIDTH - 1:0] rR1   ,
    input  logic [ADDR_WIDTH - 1:0] rR2   ,

    output logic [DATAWIDTH - 1:0]  rR1_data  ,
    output logic [DATAWIDTH - 1:0]  rR2_data
);
    logic [DATAWIDTH - 1:0] reg_bank [31:0];    //设置寄存器堆，32个寄存器，每个寄存器DATAWIDTH位宽
 
 //读出操作——————————————利用地址，输出从寄存器堆中的读出的数据
assign  rR1_data = reg_bank[rR1]; 
assign rR2_data = reg_bank[rR2];
   
// 写入操作——————————————当满足wen有效且写入地址不为0时，将wdata写入寄存器堆中对应地址的寄存器
    integer i; 
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            
            for (i = 0; i < 32; i = i + 1) begin
                reg_bank[i] <= {DATAWIDTH{1'b0}};
            end
        end
        else if (wen && (waddr != 0)) begin
            reg_bank[waddr] <= wdata;
        end
    end
endmodule