`timescale 1ns / 1ps

// 多停一个周期，输出下一条指令地址

module PC#(
    parameter   DATAWIDTH = 32
)(
    input  logic                   clk  ,
    input  logic                   rst,
    input  logic [DATAWIDTH - 1:0] npc  ,
    output logic [DATAWIDTH - 1:0] pc_out   
);
    // PC module
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out <= 0;
        end else begin
            pc_out <= npc;
        end
    end
endmodule