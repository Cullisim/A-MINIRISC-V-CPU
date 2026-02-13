`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/01 10:31:41
// Design Name: 
// Module Name: ALU
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

module ALU#(
    parameter   DATAWIDTH = 32	
)(
    input  logic [DATAWIDTH - 1:0]  A           ,
    input  logic [DATAWIDTH - 1:0]  B           ,
    input  logic [3:0]              ALUControl  ,
    output logic [DATAWIDTH - 1:0]  Result      ,
    output logic                    isTrue        
);
always_comb begin
    case (ALUControl)
        4'b0000: Result = A + B; // AND
        4'b0001: Result = A - B; // OR
        4'b0010: Result = A & B; // XOR
        4'b0011: Result = A | B; // SLL
        4'b0100: Result = A ^ B; // SRL
        4'b0101: Result = A << B[4:0]; // SLL
        4'b0110: Result = A >> B[4:0]; // SRL
        4'b0111: Result = ($signed(A) >>> B[4:0]); // SRA
        4'b1000: Result = (A == B) ? 1 : 0; // BEQ
        4'b1001: Result = (A != B) ? 1 : 0; // BNE
        4'b1010: Result = ($signed(A) < $signed(B)) ? 1 : 0; // BLT
        4'b1011: Result = ($signed(A) >= $signed(B)) ? 1 : 0; // BGE
        default: Result = 0;
    endcase

    isTrue = (Result != 0);
end
endmodule