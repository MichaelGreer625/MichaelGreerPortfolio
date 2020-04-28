/*
  control module that determines the next PC
  supports branches on immediates, register values, etc
*/

module branchControl(
    input [2:0] C,
    input [8:0] I,
    input [2:0] F,
    input rst_n,
    input Branch,
    input BranchReg,
    input [15:0] PC_in,
    input [15:0] rs_in,
    output [15:0] PC_out,
    output flush
);

wire take_branch;
wire [15:0] PC_plus, PC_choice, shiftedImmExt;
wire [8:0] shiftedImm;

// branch is taken so flush
assign flush = (take_branch & Branch);

// select correct next PC
assign PC_out = (take_branch & Branch & BranchReg) ? rs_in :
                (take_branch & Branch) ? PC_choice :
                PC_in;

// shifted/extended value for immediate I
assign shiftedImm = I << 1;
assign shiftedImmExt = {{7{shiftedImm[8]}},shiftedImm};

cla_16 inc_imm(.a(PC_in), .b(shiftedImmExt), .cin(1'b0), .sum(PC_choice), .cout()); 

// 2: based on ccc code do different flag checks to select the correct pc out value

assign take_branch = (C == 3'b000) ? ((F[2] == 0) ? 1 : 0) :
                     (C == 3'b001) ? ((F[2] == 1) ? 1 : 0) :
                     (C == 3'b010) ? (((F[2] == 0) & (F[0] == 0)) ? 1 : 0) :
                     (C == 3'b011) ? ((F[0] == 1) ? 1 : 0) : 
                     (C == 3'b100) ? (((F[2] == 1) | ((F[2] == 0) & (F[0] == 0))) ? 1 : 0) :
                     (C == 3'b101) ? (((F[2] == 1) | (F[0] == 1)) ? 1 : 0) :
                     (C == 3'b110) ? ((F[1] == 1) ? 1 : 0) :
                     (C == 3'b111) ? 1 : 0;
endmodule