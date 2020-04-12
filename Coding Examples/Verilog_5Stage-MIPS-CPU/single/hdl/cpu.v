/*
  top level cpu module
*/

module cpu
(
    input clk,
    input rst_n,
    output hlt,
    output [15:0] pc
);

wire Halt;                      // halting signal

wire [15:0] pc_next;            // next PC value (PC+2 or branch)
wire [15:0] pc_new;             // value saved to pc reg
wire [15:0] instr;              // instruction loaded from iMEM @ pc_out
wire [15:0] pc_out;             // output value from pc_reg (CURRENT PC)

wire Branch;                    // B & BR enable (need high for both)
wire BranchReg;                 // BR enable (need high for BR)
wire [2:0] SetFlags;            // enable flags to be set
wire [2:0] FlagsIn;             // flags : ALU -> flag reg
wire [2:0] FlagsOut;            // flags : flag reg -> PCcontrol

wire RegWrite;                  // register write enable
wire RegSrc2Ctl;                // choose reginput 2 address (higher on SW/LLB/LHB)
wire [3:0] RegWriteAddr;        // register write address
wire [1:0] RegDst;              // select correct DstData
wire [15:0] DstData;            // regfile write data
wire [15:0] RegOut1;            // regfile[addr1]
wire [15:0] RegOut2;            // regfile[addr2]
wire [15:0] MemAluReturn;       // muxed between alu result & memory output by MemToReg
wire [15:0] MemAddr;            // memory address

wire [15:0] imm_result;
wire [15:0] imm_shift;
wire [15:0] imm_extended;

wire ALUSrc;                    // select regfile[addr2] or sign extended imm value for ALU.b
wire [2:0] ALUOp;                // ALU control opcode
wire [15:0] ALUOut;             // ALU output
wire [15:0] Src1;                // input for ALU source 1

wire MemToReg;                  // writeback memory result to regs
wire MemRead;                   // memory read enable
wire MemWrite;                  // memory write enable
wire [15:0] DataOut;            // data out from mem

wire [15:0] llb, lhb;           // results from LHB/LLB calcs

assign pc = pc_out;             // route out pc from module

// halt program by cycling in same pc
assign pc_new = Halt ? pc_out : pc_next;

// route out the halt signal
assign hlt = Halt;

// sign extened last 4bit imm
assign imm_extended = {{12{instr[3]}}, instr[3:0]};

// need to shift << 1 for LW/SW ops
assign imm_result = (MemRead | MemWrite) ? imm_extended << 1 : imm_extended;

// register write address
assign RegWriteAddr = instr[11:8];

// memory access address
assign MemAddr = ALUOut;

// for LW/SW need to shift the offset
assign Src1 = (MemRead | MemWrite) ? RegOut1 & 16'hFFFE : RegOut1;

// LLB & LHB instruction support
assign llb = (RegOut2 & 16'hFF00) | instr[7:0];
assign lhb = (RegOut2 & 16'h00FF) | (instr[7:0] << 8);

// select correct DstData to write to regfile
assign DstData = (RegDst == 2'b00) ? pc_next :          // PCS
                 (RegDst == 2'b01) ? MemAluReturn :      // Memory or ALU
                 (RegDst == 2'b10) ? llb :               // LLB
                 lhb;                                    // LHB

// choose to send back ALU result or memory load
assign MemAluReturn = MemToReg ? DataOut : ALUOut;


// PC reg
pc_reg pcreg(
.clk(clk),
.rst_n(rst_n),
.in(pc_new),
.wen(rst_n),
.out(pc_out)
);

//flag reg
flag_reg flags(
.clk(clk),
.rst(rst_n),
.wen(SetFlags),                 // enable writing flags
.flags_in(FlagsIn),
.flags_out(FlagsOut)
);

// PC control
PC_control pc_ctl
(
.C(instr[11:9]),                // condition code
.I(instr[8:0]),                 // branch imm
.F(FlagsOut),                   // flags
.rst_n(rst_n),                  // reset
.Branch(Branch),                // branch enable
.BranchReg(BranchReg),          // support for BR
.PC_in(pc_out),                 // current pc
.rs_in(RegOut1),                // support for BR
.PC_out(pc_next)                // pc next
);

// instruction memory
memory1c iMEM(
.data_out(instr),
.data_in(),
.addr(pc_out),
.enable(rst_n),
.wr(1'b0),                      // never write imem
.clk(clk),
.rst(rst_n)
);

// main control
control ctl(
.opcode(instr[15:12]),
.RegDst(RegDst),
.RegSrc2Ctl(RegSrc2Ctl),
.RegWrite(RegWrite),
.MemRead(MemRead),
.MemWrite(MemWrite),
.MemToReg(MemToReg),
.Branch(Branch),
.BranchReg(BranchReg),
.ALUSrc(ALUSrc),
.ALUOp(ALUOp),
.SetFlags(SetFlags),
.Halt(Halt)
);

// register file
RegisterFile RegFile(
.clk(clk),
.rst(rst_n),
.SrcReg1(instr[7:4]),                                   // Register 1 Address 'ssss'
.SrcReg2(RegSrc2Ctl ? instr[11:8] : instr[3:0]),        // Register 2 Address 'tttt', for SW\LLB\LHB need [11:8]
.DstReg(RegWriteAddr),                                  // Register Write Address 'dddd' 
.WriteReg(RegWrite),
.DstData(DstData),
.SrcData1(RegOut1),
.SrcData2(RegOut2)
);

// ALU
alu ALUblk(
.a(Src1),
.b(ALUSrc ? imm_result : RegOut2),                     // choose immediate or regfile[Addr2]
.ctl(ALUOp),
.result(ALUOut),
.flags(FlagsIn)
);

// data memory
memory1c dMEM(
.data_out(DataOut),
.data_in(RegOut2),
.addr(MemAddr),
.enable(MemRead | MemWrite),                            // must enable for both read/write
.wr(MemWrite),
.clk(clk),
.rst(rst_n)
);

endmodule
