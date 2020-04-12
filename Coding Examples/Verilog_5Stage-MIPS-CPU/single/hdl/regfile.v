// ReadDecoder (just wraps general 4->16 decoder)
module ReadDecoder_4_16
(
    input [3:0] RegId,
    output [15:0] Wordline
);

decoder_4_16 decoder(RegId, Wordline);

endmodule

// WriteDecoder (general 4->16 with 'enable' on outputs)
module WriteDecoder_4_16
(
    input [3:0] RegId,
    input WriteReg,
    output [15:0] Wordline
);

wire [15:0] line;

assign Wordline = line & {16{WriteReg}};

decoder_4_16 decoder(RegId, line);

endmodule

// general 4->16 decoder for use above
module decoder_4_16
(
    input [3:0] in,
    output [15:0] out
);

wire [15:0] t0, t1, t2;

assign t0 = (in[0] == 1'b1) ? 16'b1 << 1 : 16'b1;
assign t1 = (in[1] == 1'b1) ? t0 << 2 : t0;
assign t2 = (in[2] == 1'b1) ? t1 << 4 : t1;
assign out = (in[3] == 1'b1) ? t2 << 8 : t2;

endmodule

// Single storage cell
module BitCell
(
    input clk,
    input rst,
    input D,
    input WriteEnable,
    input ReadEnable1,
    input ReadEnable2,
    inout Bitline1,
    inout Bitline2
);

wire out;

// tristates
assign Bitline1 = ReadEnable1 ? out : 1'bz;
assign Bitline2 = ReadEnable2 ? out : 1'bz;

// dff cell
dff cellDFF(.d(D), .q(out), .wen(WriteEnable), .clk(clk), .rst(rst));

endmodule

// Single 16bit register
module Register
(
    input clk,
    input rst,
    input [15:0] D,
    input WriteEnable,
    input ReadEnable1,
    input ReadEnable2,
    inout [15:0] Bitline1,
    inout [15:0] Bitline2
);


// 16 cells for reg storage
BitCell cell0(clk, rst, D[0], WriteEnable, ReadEnable1, ReadEnable2, Bitline1[0], Bitline2[0]);
BitCell cell1(clk, rst, D[1], WriteEnable, ReadEnable1, ReadEnable2, Bitline1[1], Bitline2[1]);
BitCell cell2(clk, rst, D[2], WriteEnable, ReadEnable1, ReadEnable2, Bitline1[2], Bitline2[2]);
BitCell cell3(clk, rst, D[3], WriteEnable, ReadEnable1, ReadEnable2, Bitline1[3], Bitline2[3]);
BitCell cell4(clk, rst, D[4], WriteEnable, ReadEnable1, ReadEnable2, Bitline1[4], Bitline2[4]);
BitCell cell5(clk, rst, D[5], WriteEnable, ReadEnable1, ReadEnable2, Bitline1[5], Bitline2[5]);
BitCell cell6(clk, rst, D[6], WriteEnable, ReadEnable1, ReadEnable2, Bitline1[6], Bitline2[6]);
BitCell cell7(clk, rst, D[7], WriteEnable, ReadEnable1, ReadEnable2, Bitline1[7], Bitline2[7]);
BitCell cell8(clk, rst, D[8], WriteEnable, ReadEnable1, ReadEnable2, Bitline1[8], Bitline2[8]);
BitCell cell9(clk, rst, D[9], WriteEnable, ReadEnable1, ReadEnable2, Bitline1[9], Bitline2[9]);
BitCell cell10(clk, rst, D[10], WriteEnable, ReadEnable1, ReadEnable2, Bitline1[10], Bitline2[10]);
BitCell cell11(clk, rst, D[11], WriteEnable, ReadEnable1, ReadEnable2, Bitline1[11], Bitline2[11]);
BitCell cell12(clk, rst, D[12], WriteEnable, ReadEnable1, ReadEnable2, Bitline1[12], Bitline2[12]);
BitCell cell13(clk, rst, D[13], WriteEnable, ReadEnable1, ReadEnable2, Bitline1[13], Bitline2[13]);
BitCell cell14(clk, rst, D[14], WriteEnable, ReadEnable1, ReadEnable2, Bitline1[14], Bitline2[14]);
BitCell cell15(clk, rst, D[15], WriteEnable, ReadEnable1, ReadEnable2, Bitline1[15], Bitline2[15]);

endmodule

// 16 registers with decode logic and bypass if SrcReg1 or SrcReg2 == DstReg
module RegisterFile
(
    input clk,
    input rst,
    input [3:0] SrcReg1,
    input [3:0] SrcReg2,
    input [3:0] DstReg,
    input WriteReg,
    input [15:0] DstData,
    inout [15:0] SrcData1,
    inout [15:0] SrcData2
);

wire [15:0] SrcReg1Dec, SrcReg2Dec, DstRegDec, regOut1, regOut2;

assign SrcData1 = (SrcReg1 == 4'h0) ? 16'h0 : regOut1;
assign SrcData2 = (SrcReg2 == 4'h0) ? 16'h0 : regOut2;

ReadDecoder_4_16 readDecoder1(SrcReg1, SrcReg1Dec);
ReadDecoder_4_16 readDecoder2(SrcReg2, SrcReg2Dec);
WriteDecoder_4_16 writeDecoder(DstReg, WriteReg, DstRegDec);

Register reg0(clk, rst, DstData, DstRegDec[0], SrcReg1Dec[0], SrcReg2Dec[0], regOut1, regOut2);
Register reg1(clk, rst, DstData, DstRegDec[1], SrcReg1Dec[1], SrcReg2Dec[1], regOut1, regOut2);
Register reg2(clk, rst, DstData, DstRegDec[2], SrcReg1Dec[2], SrcReg2Dec[2], regOut1, regOut2);
Register reg3(clk, rst, DstData, DstRegDec[3], SrcReg1Dec[3], SrcReg2Dec[3], regOut1, regOut2);
Register reg4(clk, rst, DstData, DstRegDec[4], SrcReg1Dec[4], SrcReg2Dec[4], regOut1, regOut2);
Register reg5(clk, rst, DstData, DstRegDec[5], SrcReg1Dec[5], SrcReg2Dec[5], regOut1, regOut2);
Register reg6(clk, rst, DstData, DstRegDec[6], SrcReg1Dec[6], SrcReg2Dec[6], regOut1, regOut2);
Register reg7(clk, rst, DstData, DstRegDec[7], SrcReg1Dec[7], SrcReg2Dec[7], regOut1, regOut2);
Register reg8(clk, rst, DstData, DstRegDec[8], SrcReg1Dec[8], SrcReg2Dec[8], regOut1, regOut2);
Register reg9(clk, rst, DstData, DstRegDec[9], SrcReg1Dec[9], SrcReg2Dec[9], regOut1, regOut2);
Register reg10(clk, rst, DstData, DstRegDec[10], SrcReg1Dec[10], SrcReg2Dec[10], regOut1, regOut2);
Register reg11(clk, rst, DstData, DstRegDec[11], SrcReg1Dec[11], SrcReg2Dec[11], regOut1, regOut2);
Register reg12(clk, rst, DstData, DstRegDec[12], SrcReg1Dec[12], SrcReg2Dec[12], regOut1, regOut2);
Register reg13(clk, rst, DstData, DstRegDec[13], SrcReg1Dec[13], SrcReg2Dec[13], regOut1, regOut2);
Register reg14(clk, rst, DstData, DstRegDec[14], SrcReg1Dec[14], SrcReg2Dec[14], regOut1, regOut2);
Register reg15(clk, rst, DstData, DstRegDec[15], SrcReg1Dec[15], SrcReg2Dec[15], regOut1, regOut2);

endmodule
