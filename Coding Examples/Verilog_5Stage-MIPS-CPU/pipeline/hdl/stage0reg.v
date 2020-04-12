/*
  Stage0 (IF/ID) Pipeline register
*/

module stage0 
(
    input clk,
    input rst,
    input we,
    input flush_in,     // flush the instr in s0 during s1
    input [15:0] pc_in,
    input [15:0] instr_in,
    output [15:0] pc_out,
    output [15:0] instr_out,
    output flush_out
);

/* next PC (PC+2) */
dff reg0(.d(pc_in[0]), .q(pc_out[0]), .wen(we), .clk(clk), .rst(rst));
dff reg1(.d(pc_in[1]), .q(pc_out[1]), .wen(we), .clk(clk), .rst(rst));
dff reg2(.d(pc_in[2]), .q(pc_out[2]), .wen(we), .clk(clk), .rst(rst));
dff reg3(.d(pc_in[3]), .q(pc_out[3]), .wen(we), .clk(clk), .rst(rst));
dff reg4(.d(pc_in[4]), .q(pc_out[4]), .wen(we), .clk(clk), .rst(rst));
dff reg5(.d(pc_in[5]), .q(pc_out[5]), .wen(we), .clk(clk), .rst(rst));
dff reg6(.d(pc_in[6]), .q(pc_out[6]), .wen(we), .clk(clk), .rst(rst));
dff reg7(.d(pc_in[7]), .q(pc_out[7]), .wen(we), .clk(clk), .rst(rst));
dff reg8(.d(pc_in[8]), .q(pc_out[8]), .wen(we), .clk(clk), .rst(rst));
dff reg9(.d(pc_in[9]), .q(pc_out[9]), .wen(we), .clk(clk), .rst(rst));
dff reg10(.d(pc_in[10]), .q(pc_out[10]), .wen(we), .clk(clk), .rst(rst));
dff reg11(.d(pc_in[11]), .q(pc_out[11]), .wen(we), .clk(clk), .rst(rst));
dff reg12(.d(pc_in[12]), .q(pc_out[12]), .wen(we), .clk(clk), .rst(rst));
dff reg13(.d(pc_in[13]), .q(pc_out[13]), .wen(we), .clk(clk), .rst(rst));
dff reg14(.d(pc_in[14]), .q(pc_out[14]), .wen(we), .clk(clk), .rst(rst));
dff reg15(.d(pc_in[15]), .q(pc_out[15]), .wen(we), .clk(clk), .rst(rst));

/* instruction */
dff reg16(.d(instr_in[0]), .q(instr_out[0]), .wen(we), .clk(clk), .rst(rst));
dff reg17(.d(instr_in[1]), .q(instr_out[1]), .wen(we), .clk(clk), .rst(rst));
dff reg18(.d(instr_in[2]), .q(instr_out[2]), .wen(we), .clk(clk), .rst(rst));
dff reg19(.d(instr_in[3]), .q(instr_out[3]), .wen(we), .clk(clk), .rst(rst));
dff reg20(.d(instr_in[4]), .q(instr_out[4]), .wen(we), .clk(clk), .rst(rst));
dff reg21(.d(instr_in[5]), .q(instr_out[5]), .wen(we), .clk(clk), .rst(rst));
dff reg22(.d(instr_in[6]), .q(instr_out[6]), .wen(we), .clk(clk), .rst(rst));
dff reg23(.d(instr_in[7]), .q(instr_out[7]), .wen(we), .clk(clk), .rst(rst));
dff reg24(.d(instr_in[8]), .q(instr_out[8]), .wen(we), .clk(clk), .rst(rst));
dff reg25(.d(instr_in[9]), .q(instr_out[9]), .wen(we), .clk(clk), .rst(rst));
dff reg26(.d(instr_in[10]), .q(instr_out[10]), .wen(we), .clk(clk), .rst(rst));
dff reg27(.d(instr_in[11]), .q(instr_out[11]), .wen(we), .clk(clk), .rst(rst));
dff reg28(.d(instr_in[12]), .q(instr_out[12]), .wen(we), .clk(clk), .rst(rst));
dff reg29(.d(instr_in[13]), .q(instr_out[13]), .wen(we), .clk(clk), .rst(rst));
dff reg30(.d(instr_in[14]), .q(instr_out[14]), .wen(we), .clk(clk), .rst(rst));
dff reg31(.d(instr_in[15]), .q(instr_out[15]), .wen(we), .clk(clk), .rst(rst));

dff reg32(.d(flush_in), .q(flush_out), .wen(we), .clk(clk), .rst(rst));

endmodule
