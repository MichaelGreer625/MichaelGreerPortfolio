/*
  main control logic
  must set ALL signals for each opcode case
*/

module control
(
    input [3:0] opcode,
    output reg [1:0] RegDst,
    output reg RegSrc2Ctl,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg MemToReg,
    output reg Branch,
    output reg BranchReg,
    output reg ALUSrc,
    output reg [2:0] ALUOp,      // route to alu.ctl
    output reg [2:0] SetFlags,   // route to flag_reg.wen ZVN
    output reg [1:0] ClearRST, 
    output reg Halt
);

always @(*) case (opcode)
4'b0000 : begin        // ADD 
                RegDst  = 2'b01;
                RegSrc2Ctl = 1'b0; 
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                Branch = 1'b0;
                BranchReg = 1'b0;
                ALUSrc = 1'b0;
                ALUOp = 3'b000 ;
                SetFlags = 3'b111; 
                ClearRST = 2'b00;
                Halt = 1'b0;
           end
4'b0001 : begin        // SUB
                RegDst  = 2'b01;
                RegSrc2Ctl = 1'b0; 
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                Branch = 1'b0;
                BranchReg = 1'b0;
                ALUSrc = 1'b0;
                ALUOp = 3'b001; 
                SetFlags = 3'b111; 
                ClearRST = 2'b00;
                Halt = 1'b0;
           end
4'b0010 : begin        // RED
                RegDst  = 2'b01;
                RegSrc2Ctl = 1'b0; 
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                Branch = 1'b0;
                BranchReg = 1'b0;
                ALUSrc = 1'b0;
                ALUOp = 3'b010; 
                SetFlags = 3'b000; 
                Halt = 1'b0;
           end
4'b0011 : begin        // XOR
                RegDst  = 2'b01;
                RegSrc2Ctl = 1'b0; 
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                Branch = 1'b0;
                BranchReg = 1'b0;
                ALUSrc = 1'b0;
                ALUOp = 3'b011;
                SetFlags = 3'b100; 
                ClearRST = 2'b00;
                Halt = 1'b0;
           end
4'b0100 : begin        // SLL
                RegDst  = 2'b01;
                RegSrc2Ctl = 1'b0; 
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                Branch = 1'b0;
                BranchReg = 1'b0;
                ALUSrc = 1'b1;
                ALUOp = 3'b100;
                SetFlags = 3'b100; 
                ClearRST = 2'b01;
                Halt = 1'b0;
           end
4'b0101 : begin        // SRA
                RegDst  = 2'b01;
                RegSrc2Ctl = 1'b0; 
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                Branch = 1'b0;
                BranchReg = 1'b0;
                ALUSrc = 1'b1;
                ALUOp = 3'b101;
                SetFlags = 3'b100; 
                ClearRST = 2'b01;
                Halt = 1'b0;
           end
4'b0110 : begin        // ROR
                RegDst  = 2'b01;
                RegSrc2Ctl = 1'b0; 
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                Branch = 1'b0;
                BranchReg = 1'b0;
                ALUSrc = 1'b1;
                ALUOp = 3'b110;
                SetFlags = 3'b100; 
                ClearRST = 2'b01;
                Halt = 1'b0;
           end
4'b0111 : begin        // PADDSB
                RegDst  = 2'b01;
                RegSrc2Ctl = 1'b0; 
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                Branch = 1'b0;
                BranchReg = 1'b0;
                ALUSrc = 1'b0;
                ALUOp = 3'b111;
                SetFlags = 3'b000; 
                ClearRST = 2'b00;
                Halt = 1'b0;
           end
4'b1000 : begin        // LW
                RegDst  = 2'b01;
                RegSrc2Ctl = 1'b0; 
                RegWrite = 1'b1;
                MemRead = 1'b1;
                MemWrite = 1'b0;
                MemToReg = 1'b1;
                Branch = 1'b0;
                BranchReg = 1'b0;
                ALUSrc = 1'b1;
                ALUOp = 3'b000;
                SetFlags = 3'b000; 
                ClearRST = 2'b01;
                Halt = 1'b0;
           end
4'b1001 : begin        // SW
                RegDst  = 2'b01;
                RegSrc2Ctl = 1'b1; 
                RegWrite = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b1;
                MemToReg = 1'b0;
                Branch = 1'b0;
                BranchReg = 1'b0;
                ALUSrc = 1'b1;
                ALUOp = 3'b000;
                SetFlags = 3'b000; 
                ClearRST = 2'b01;
                Halt = 1'b0;
           end
4'b1010 : begin        // LHB
                RegDst  = 2'b11;
                RegSrc2Ctl = 1'b1; 
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                Branch = 1'b0;
                BranchReg = 1'b0;
                ALUSrc = 1'b1;
                ALUOp = 3'b000;
                SetFlags = 3'b000; 
                ClearRST = 2'b11;
                Halt = 1'b0;
           end
4'b1011 : begin        // LLB
                RegDst  = 2'b10;
                RegSrc2Ctl = 1'b1; 
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                Branch = 1'b0;
                BranchReg = 1'b0;
                ALUSrc = 1'b1;
                ALUOp = 3'b000;
                SetFlags = 3'b000; 
                ClearRST = 2'b11;
                Halt = 1'b0;
           end
4'b1100 : begin        // B
                RegDst  = 2'b01;
                RegSrc2Ctl = 1'b0; 
                RegWrite = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                Branch = 1'b1;
                BranchReg = 1'b0;
                ALUSrc = 1'b0;
                ALUOp = 3'b000;
                SetFlags = 3'b000; 
                ClearRST = 2'b11;
                Halt = 1'b0;
           end
4'b1101 : begin        // BR
                RegDst  = 2'b01;
                RegSrc2Ctl = 1'b0; 
                RegWrite = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                Branch = 1'b1;
                BranchReg = 1'b1;
                ALUSrc = 1'b0;
                ALUOp = 3'b000;
                SetFlags = 3'b000; 
                ClearRST = 2'b01;
                Halt = 1'b0;
           end
4'b1110 : begin        // PCS
                RegDst  = 2'b00;
                RegSrc2Ctl = 1'b0; 
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                Branch = 1'b0;
                BranchReg = 1'b0;
                ALUSrc = 1'b0;
                ALUOp = 3'b000;
                SetFlags = 3'b000; 
                ClearRST = 2'b11;
                Halt = 1'b0;
           end
4'b1111 : begin        // HALT
                RegDst  = 2'b00;
                RegSrc2Ctl = 1'b0; 
                RegWrite = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                Branch = 1'b0;
                BranchReg = 1'b0;
                ALUSrc = 1'b0;
                ALUOp = 3'b000;
                SetFlags = 3'b000; 
                ClearRST = 2'b11;
                Halt = 1'b1;
           end
endcase

endmodule
