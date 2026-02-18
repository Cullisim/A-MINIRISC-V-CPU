`timescale 1ns / 1ps
//根据不同的ALUControl信号，ALU模块执行不同的运算，并输出isTrue
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