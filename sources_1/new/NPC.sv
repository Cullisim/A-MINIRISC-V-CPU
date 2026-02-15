`timescale 1ns / 1ps

// 该模块对应下一指令的地址

module NPC#(
    parameter   DATAWIDTH = 32
)(
    input  logic                   isTrue   ,
    input  logic [1:0]             npc_op   ,
    input  logic [DATAWIDTH - 1:0] pc       ,
    input  logic [DATAWIDTH - 1:0] offset   ,
    output logic [DATAWIDTH - 1:0] npc      ,
    output logic [DATAWIDTH - 1:0] pcadd4  
);
assign pcadd4 = pc + 4;
always_comb begin
    
    case (npc_op)
        2'b00: npc = pc + 4; //对应非跳转指令
        2'b01: npc = isTrue ? (pc + offset) : pc+4;   //根据判断条件决定是否是跳转指令
        2'b10: npc = (~1)&offset;    //jalr指令
        2'b11: npc = pc + offset;
        default: npc = 0;
    endcase
end

endmodule
