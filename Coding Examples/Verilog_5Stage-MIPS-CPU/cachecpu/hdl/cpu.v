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

wire istall;                    // stall CPU 4 cycles for icache miss
wire istall_s1;                 // pipeline istall to create nops
wire dstall;                    // stall CPU 4 cycles for dcache miss

wire icache_hit;                // valid icache miss 
wire dcache_hit;                // valid dcache miss
wire icache_req;                 // valid icache enable/access
wire dcache_req;                 // valid dcache enable/access

wire [15:0] pc_new;             // value saved to pc reg
wire [15:0] pc_out;             // output value from pc_reg (CURRENT PC)
wire [15:0] pc_branch;          // pc for branch result

wire [15:0] pc_next_s0;         // PC + 2 (stage 0)
wire [15:0] instr_s0;           // instruction loaded from iMEM @ pc_out (stage 0)
wire [15:0] instr_s0_raw;       // instruction direct from icache

wire [15:0] pc_next_s1;         // PC + 2 (stage 1)
wire [15:0] instr_s1;           // instruction loaded from iMEM @ pc_out (stage 1)

wire [3:0] rd_addr_s1;          // RD addr stage1
wire [3:0] rs_addr_s1;          // RS addr stage1
wire [3:0] rt_addr_s1;          // RT addr stage1

wire [10:0] ex_s1;              // EX control signals stage1
wire [1:0] mem_s1;              // MEM control signals stage1
wire [2:0] wb_s1;               // WB control sgianls stage1

wire [10:0] ex_s1_pre;          // EX control signals stage1
wire [1:0] mem_s1_pre;          // MEM control signals stage1
wire [2:0] wb_s1_pre;           // WB control sgianls stage1

wire [1:0] clearRST;            // clears RT/RS pipeline values for certain instructions

wire [15:0] br_regvalue;
wire flush_s0;
wire flush_s1;
wire stall_s0;                  // stall on IF/ID pipeline reg
wire zero_ctl;                  // create bubble in ID stage 
wire [2:0] flags_s2;
wire [15:0] instr_s2;           // instrucion
wire [15:0] pc_next_s2;         // PC + 2 (stage 2)
wire [10:0] ex_s2;              // EX control signals stage1
wire [1:0] mem_s2;              // MEM control signals stage1
wire [2:0] wb_s2;               // WB control sgianls stage1
wire [3:0] rd_addr_s2;          // RD addr stage2
wire [3:0] rt_addr_s2;          // RT addr stage2
wire [3:0] rs_addr_s2;          // RS addr stage2
wire [15:0] RegOut1_s2;         // regfile port 1 data
wire [15:0] RegOut2_s2;         // regfile port 2 data
wire [3:0] imm_s2;              // immdiate from opcode
wire [15:0] aluin1pre;          // alu input 1 only from bypassing
wire [15:0] aluin2pre;          // alu input 2 only from bypassing
wire [15:0] aluin1;             // alu input
wire [15:0] aluin2;             // alu input

wire [15:0] imm_xtnd;           // sign extended immediate
wire [15:0] imm_valid;          // valid immdiaite for alu input (<<1 for MEM instructions)
wire [15:0] ex_result_s2;       // either ALU result or result from PCS/LHB/LLB so pass to next stage

wire [1:0] alu1bypass;          // alu src 1 bypass enable
wire [1:0] alu2bypass;          // alu src 2 bypass enable

wire [2:0] flags_s3;
wire [15:0] pc_next_s3;         // PC + 2
wire [15:0] ex_result_s3;       // result from EX stage
wire [15:0] mem_data;           // output 2 from regfile (store data)
wire [3:0] rd_addr_s3;          // RD addr stage3
wire [1:0] mem_s3;              // MEM control signals stage3
wire [2:0] wb_s3;               // WB control signals stage3

wire [15:0] alu_ex_bypass;      // forwarded value from MEM stage
wire [15:0] alu_mem_bypass;     // forwaded value rom WB stage

wire [15:0] ex_result_s4;       // result from EX stage
wire [15:0] DataOut_s4;         // loaded data from dmem
wire [3:0] rd_addr_s4;          // RD addr stage4
wire [2:0] wb_s4;               // WB control signals stage4

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

// for icache miss just set next instr as add for consistency
assign instr_s0 = istall ? 16'h0 : instr_s0_raw;

// pass halt signal all th way through and bring it back from stage 4 (writeback)
// halt program by cycling in same pc
// assign pc_new =  wb_s1[0] ? pc_next_s1 : pc_next_s0;

// eval halt in stage0
assign pc_new = (flush_s0) ? pc_branch :
                ((instr_s0[15:12] == 4'hF) | istall | dstall) ? pc_out :
                pc_next_s0;

// route out the halt signal during writeback
assign hlt = wb_s4[0];

// LLB & LHB instruction support
assign llb = (aluin2pre & 16'hFF00) | instr_s2[7:0];
assign lhb = (aluin2pre & 16'h00FF) | (instr_s2[7:0] << 8);

// select correct DstData to write to regfile
//assign DstData = (RegDst == 2'b00) ? pc_next :          // PCS
//                 (RegDst == 2'b01) ? MemAluReturn :      // Memory or ALU
//                 (RegDst == 2'b10) ? llb :               // LLB
//                 lhb;                                    // LHB

// flush control signals in ID stage
//assign ex_s1 = (stall_s0 | zero_ctl) ? 11'h0 : ex_s1_pre;
//assign mem_s1 = (stall_s0 | zero_ctl) ? 2'h0 : mem_s1_pre;
//assign wb_s1 = (stall_s0 | zero_ctl) ? 3'h0 : wb_s1_pre;

assign zero_ctl = 1'b0;
assign ex_s1 = (stall_s0 | flush_s1 | flush_s0 | istall_s1) ? 11'h0 : ex_s1_pre;
assign mem_s1 = (stall_s0 | flush_s1 | flush_s0 | istall_s1) ? 2'h0 : mem_s1_pre;
assign wb_s1 = (stall_s0 | flush_s1 | flush_s0 | istall_s1) ? 3'h0 : wb_s1_pre;

assign rd_addr_s1 = instr_s1[11:8];
assign rt_addr_s1 = (ex_s1[10] == 1'b1) ? instr_s1[11:8] :
                    (clearRST[0] == 1'b1) ? 4'h0 :
                    instr_s1[3:0];
assign rs_addr_s1 = (clearRST[1] == 1'b1) ? 4'h0 : instr_s1[7:4];

// data forwarding
assign aluin1pre = (alu1bypass == 2'b00) ? RegOut1_s2 :
                   (alu1bypass == 2'b10) ? alu_ex_bypass :
                   (alu1bypass == 2'b01) ? alu_mem_bypass : 16'h0;

assign aluin2pre = (alu2bypass == 2'b00) ? RegOut2_s2 :
                   (alu2bypass == 2'b10) ? alu_ex_bypass :
                   (alu2bypass == 2'b01) ? alu_mem_bypass : 16'h0;

assign br_regvalue = (alu1bypass == 2'b00) ? RegOut1_s2 :
                     (alu1bypass == 2'b10) ? alu_ex_bypass :
                     (alu1bypass == 2'b01) ? alu_mem_bypass : 16'h0;

// sign extend immediate
assign imm_xtnd = {{12{imm_s2[3]}}, imm_s2[3:0]};

// shift imm for LW/SW
assign imm_valid = (mem_s2[1]|mem_s2[0]) ? imm_xtnd << 1 : imm_xtnd;

// select ALU ops
assign aluin1 = (mem_s2[1]|mem_s2[0]) ? aluin1pre & 16'hFFFE : aluin1pre;
assign aluin2 = ex_s2[2] ? imm_valid : aluin2pre; 

// mux ALUOut to support PCS/LLB/LHB
assign ex_result_s2 = (ex_s2[10:9] == 2'b00) ? pc_next_s2 :
                      (ex_s2[10:9] == 2'b01) ? ALUOut :
                      (ex_s2[10:9] == 2'b10) ? llb :
                      lhb;

// set EX bypass value
assign alu_ex_bypass = ex_result_s3;

// set MEM bypass value
assign alu_mem_bypass = DstData;

// send back ALU result or memory load
assign DstData = wb_s4[1] ? DataOut_s4 : ex_result_s4; 

// PC reg
pc_reg pcreg(
.clk(clk),
.rst_n(rst_n),
.in(pc_new),
.wen(rst_n & ~stall_s0),
.out(pc_out)
);

/*
// instruction memory
memory1c iMEM(
.data_out(instr_s0_raw),
.data_in(),
.addr(pc_out),
.enable(rst_n),
.wr(1'b0),                      // never write imem
.clk(clk),
.rst(rst_n)
);
*/

// instruction cache
// since we never need to write to icache we ignore DataIn and set write low
cacheBlockPipe icache(
.clk(clk),
.rst(rst_n),
.CacheEnable(1'b1),
.DataIn(),
.write(1'b0),
.MemAddress(pc_out),
.DataOutMainModule(instr_s0_raw),
.StallPipeline(istall),
.validReq(icache_req),
.hitOut(icache_hit)
);

// PC increment
cla_16 pc_inc(
.a(pc_out),
.b(16'h2),
.cin(1'b0),
.sum(pc_next_s0),
.cout()
);

// IF/ID register
stage0 stage0reg(
.clk(clk),
.rst(rst_n),
.we(~(stall_s0 | dstall)),
.flush_in(flush_s0),
.pc_in(pc_next_s0),
.instr_in(instr_s0),
.istall_in(istall),
.pc_out(pc_next_s1),
.instr_out(instr_s1),
.flush_out(flush_s1),
.istall_out(istall_s1)
);

//flag reg
flag_reg flags(
.clk(clk),
.rst(rst_n),
.wen(SetFlags),                 // enable writing flags
.flags_in(FlagsIn),
.flags_out(FlagsOut)
);
/*
 PC control
PC_control pc_ctl(
.C(instr_s1[11:9]),                // condition code
.I(instr_s1[8:0]),                 // branch imm
.F(FlagsOut),                   // flags
.rst_n(rst_n),                  // reset
.Branch(Branch),                // branch enable
.BranchReg(BranchReg),          // support for BR
.PC_in(pc_out),                 // current pc
.rs_in(RegOut1),                // support for BR
.PC_out(pc_next)                // pc next
);
*/

// main control
control ctl(
.opcode(instr_s1[15:12]),       // opcode
.RegDst(ex_s1_pre[10:9]),
.RegSrc2Ctl(RegSrc2Ctl),
.RegWrite(wb_s1_pre[2]),
.MemRead(mem_s1_pre[0]),
.MemWrite(mem_s1_pre[1]),
.MemToReg(wb_s1_pre[1]),
.Branch(ex_s1_pre[1]),
.BranchReg(ex_s1_pre[0]),
.ALUSrc(ex_s1_pre[2]),
.ALUOp(ex_s1_pre[5:3]),
.SetFlags(ex_s1_pre[8:6]),
.ClearRST(clearRST),
.Halt(wb_s1_pre[0])
);

// register file
RegisterFile RegFile(
.clk(clk),
.rst(rst_n),
.SrcReg1(instr_s1[7:4]),                                // Register 1 Address 'ssss'
.SrcReg2(RegSrc2Ctl ? instr_s1[11:8] : instr_s1[3:0]),  // Register 2 Address 'tttt', for SW\LLB\LHB need [11:8]
.DstReg(rd_addr_s4),                                    // Register Write Address 'dddd' 
.WriteReg(wb_s4[2]),
.DstData(DstData),
.SrcData1(RegOut1),
.SrcData2(RegOut2)
);

// ID/EX register
stage1 stage1reg(
.clk(clk),
.rst(rst_n),
.we(~dstall),
.pc_in(pc_next_s1),
.instr_in(instr_s1),
.reg1in(RegOut1),
.reg2in(RegOut2),
.imm_in(instr_s1[3:0]),
.rd_addr_in(rd_addr_s1),
.rt_addr_in(rt_addr_s1),
.rs_addr_in(rs_addr_s1),
.ex_signals_in(ex_s1),
.mem_signals_in(mem_s1),
.wb_signals_in(wb_s1),
.pc_out(pc_next_s2),
.instr_out(instr_s2),
.reg1out(RegOut1_s2),
.reg2out(RegOut2_s2),
.imm_out(imm_s2),
.rd_addr_out(rd_addr_s2),
.rt_addr_out(rt_addr_s2),
.rs_addr_out(rs_addr_s2),
.ex_signals_out(ex_s2),
.mem_signals_out(mem_s2),
.wb_signals_out(wb_s2)
);

// branch control in stage EX
branchControl branchCtl(
.C(instr_s2[11:9]),
.I(instr_s2[8:0]),
.F(flags_s3),
.rst_n(1'b1),
.Branch(ex_s2[1]),
.BranchReg(ex_s2[0]),
.PC_in(pc_next_s2),
.rs_in(br_regvalue),
.PC_out(pc_branch),
.flush(flush_s0)
);

// ALU
alu ALUblk(
.a(aluin1),
.b(aluin2),                                             // choose immediate or regfile[Addr2]
.ctl(ex_s2[5:3]),
.result(ALUOut),
.flags(flags_s2)
);

// forwarding unit
dataHazardUnit dhu(
.EXMEMRegWrite(wb_s3[2]), 
.MEMWBRegWrite(wb_s4[2]),
.EXMEMRegRd(rd_addr_s3),
.MEMWBRegRd(rd_addr_s4),
.IDEXRegRt(rt_addr_s2),
.IDEXRegRs(rs_addr_s2),
.forwardA(alu1bypass),
.forwardB(alu2bypass)
);

// EX/MEM register
stage2 stage2reg(
.clk(clk),
.rst(rst_n),
.we(~dstall),
.pc_in(pc_next_s2),
.alu_in(ex_result_s2),        // ALU result (address)
.data_in(aluin2pre),       // Reg2 result (data)
.rd_addr_in(rd_addr_s2),     // rf write address
.mem_signals_in(mem_s2), // MEM stage signals
.wb_signals_in(wb_s2),  // WB stage signals
.flags_ctl(ex_s2[8:6]),
.flags_in(flags_s2),
.pc_out(pc_next_s3),
.alu_out(ex_result_s3),
.data_out(mem_data),
.rd_addr_out(rd_addr_s3),
.mem_signals_out(mem_s3),
.wb_signals_out(wb_s3),
.flags_out(flags_s3)
);

/*
// data memory
memory1c dMEM(
.data_out(DataOut),
.data_in(mem_data),
.addr(ex_result_s3),
.enable(mem_s3[1] | mem_s3[0]),                            // must enable for both read/write
.wr(mem_s3[1]),
.clk(clk),
.rst(rst_n)
);
*/

// data cache
cacheBlockPipe dcache(
.clk(clk),
.rst(rst_n),
.CacheEnable(mem_s3[1] | mem_s3[0]),
.DataIn(mem_data),
.write(mem_s3[1]),
.MemAddress(ex_result_s3),
.DataOutMainModule(DataOut),
.StallPipeline(dstall),
.validReq(dcache_req),
.hitOut(dcache_hit)
);

// MEM/WB register
stage3 stage3reg(
.clk(clk),
.rst(rst_n),
.we(~dstall),
.alu_in(ex_result_s3),        // ALU result
.data_in(DataOut),       // dmem data
.rd_addr_in(rd_addr_s3),     // rf write address
.wb_signals_in(wb_s3),  // WB stage signals
.alu_out(ex_result_s4),
.data_out(DataOut_s4),
.rd_addr_out(rd_addr_s4),
.wb_signals_out(wb_s4)
);

// hazard detection unit
hazard unit(
.MemRead(mem_s2[0]),
.ExRegRt(rd_addr_s2),						// destination for load
.DeRegRt(rt_addr_s1),						// operand for an r-type
.DeRegRs(rs_addr_s1),						// operand for an r-type
.muxWrite(stall_s0)
);

endmodule
