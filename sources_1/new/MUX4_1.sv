`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/06 12:42:16
// Design Name: 
// Module Name: MUX4_1
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

module MUX4_1 #(
    parameter WIDTH = 32
)
(
    input  logic [WIDTH - 1:0] A          ,
    input  logic [WIDTH - 1:0] B          ,
    input  logic [WIDTH - 1:0] C          ,
    input  logic [WIDTH - 1:0] D          ,
    input  logic [1:0]         Control    ,
    output logic [WIDTH - 1:0] Result
);
    // 4-1 mux
    always_comb begin
        case (Control)
            2'b00: Result = A;
            2'b01: Result = B;
            2'b10: Result = C;
            2'b11: Result = D;
            default: Result = 0;
        endcase
    end
endmodule