`timescale 1ns / 1ps
//二选一选择器
module MUX2_1 #(
    parameter WIDTH = 32
)
(
    input  logic [WIDTH - 1:0] A          ,
    input  logic [WIDTH - 1:0] B          ,
    input  logic Control    ,
    output logic [WIDTH - 1:0] Result
);
    // 2-1 mux
    always_comb begin
        case (Control)
            1'b0: Result = A;
            1'b1: Result = B;
            default: Result = 0;
        endcase
    end
endmodule