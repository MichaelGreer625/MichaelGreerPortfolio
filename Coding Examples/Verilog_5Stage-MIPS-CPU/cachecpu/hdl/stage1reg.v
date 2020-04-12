/*
  Stage1 (ID/EX) Pipeline register
*/

module stage1 
(
    input clk,
    input rst,
    input we,
    input [15:0] pc_in,
    input [15:0] instr_in,
    input [15:0] reg1in,        // rf port 1 data
    input [15:0] reg2in,        // rf port 2 data
    input [3:0] imm_in,         // immediate value
    input [3:0] rd_addr_in,     // rf write address
    input [3:0] rt_addr_in,     // rf source address
    input [3:0] rs_addr_in,     // rf source2? address
    input [10:0] ex_signals_in, // EX stage signals
    input [1:0] mem_signals_in, // MEM stage signals
    input [2:0] wb_signals_in,  // WB stage signals
    output [15:0] pc_out,
    output [15:0] instr_out,
    output [15:0] reg1out,
    output [15:0] reg2out,
    output [3:0] imm_out,
    output [3:0] rd_addr_out,
    output [3:0] rt_addr_out,
    output [3:0] rs_addr_out,
    output [10:0] ex_signals_out,
    output [1:0] mem_signals_out,
    output [2:0] wb_signals_out
);

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

dff reg16(.d(reg1in[0]), .q(reg1out[0]), .wen(we), .clk(clk), .rst(rst));
dff reg17(.d(reg1in[1]), .q(reg1out[1]), .wen(we), .clk(clk), .rst(rst));
dff reg18(.d(reg1in[2]), .q(reg1out[2]), .wen(we), .clk(clk), .rst(rst));
dff reg19(.d(reg1in[3]), .q(reg1out[3]), .wen(we), .clk(clk), .rst(rst));
dff reg20(.d(reg1in[4]), .q(reg1out[4]), .wen(we), .clk(clk), .rst(rst));
dff reg21(.d(reg1in[5]), .q(reg1out[5]), .wen(we), .clk(clk), .rst(rst));
dff reg22(.d(reg1in[6]), .q(reg1out[6]), .wen(we), .clk(clk), .rst(rst));
dff reg23(.d(reg1in[7]), .q(reg1out[7]), .wen(we), .clk(clk), .rst(rst));
dff reg24(.d(reg1in[8]), .q(reg1out[8]), .wen(we), .clk(clk), .rst(rst));
dff reg25(.d(reg1in[9]), .q(reg1out[9]), .wen(we), .clk(clk), .rst(rst));
dff reg26(.d(reg1in[10]), .q(reg1out[10]), .wen(we), .clk(clk), .rst(rst));
dff reg27(.d(reg1in[11]), .q(reg1out[11]), .wen(we), .clk(clk), .rst(rst));
dff reg28(.d(reg1in[12]), .q(reg1out[12]), .wen(we), .clk(clk), .rst(rst));
dff reg29(.d(reg1in[13]), .q(reg1out[13]), .wen(we), .clk(clk), .rst(rst));
dff reg30(.d(reg1in[14]), .q(reg1out[14]), .wen(we), .clk(clk), .rst(rst));
dff reg31(.d(reg1in[15]), .q(reg1out[15]), .wen(we), .clk(clk), .rst(rst));

dff reg32(.d(reg2in[0]), .q(reg2out[0]), .wen(we), .clk(clk), .rst(rst));
dff reg33(.d(reg2in[1]), .q(reg2out[1]), .wen(we), .clk(clk), .rst(rst));
dff reg34(.d(reg2in[2]), .q(reg2out[2]), .wen(we), .clk(clk), .rst(rst));
dff reg35(.d(reg2in[3]), .q(reg2out[3]), .wen(we), .clk(clk), .rst(rst));
dff reg36(.d(reg2in[4]), .q(reg2out[4]), .wen(we), .clk(clk), .rst(rst));
dff reg37(.d(reg2in[5]), .q(reg2out[5]), .wen(we), .clk(clk), .rst(rst));
dff reg38(.d(reg2in[6]), .q(reg2out[6]), .wen(we), .clk(clk), .rst(rst));
dff reg39(.d(reg2in[7]), .q(reg2out[7]), .wen(we), .clk(clk), .rst(rst));
dff reg40(.d(reg2in[8]), .q(reg2out[8]), .wen(we), .clk(clk), .rst(rst));
dff reg41(.d(reg2in[9]), .q(reg2out[9]), .wen(we), .clk(clk), .rst(rst));
dff reg42(.d(reg2in[10]), .q(reg2out[10]), .wen(we), .clk(clk), .rst(rst));
dff reg43(.d(reg2in[11]), .q(reg2out[11]), .wen(we), .clk(clk), .rst(rst));
dff reg44(.d(reg2in[12]), .q(reg2out[12]), .wen(we), .clk(clk), .rst(rst));
dff reg45(.d(reg2in[13]), .q(reg2out[13]), .wen(we), .clk(clk), .rst(rst));
dff reg46(.d(reg2in[14]), .q(reg2out[14]), .wen(we), .clk(clk), .rst(rst));
dff reg47(.d(reg2in[15]), .q(reg2out[15]), .wen(we), .clk(clk), .rst(rst));

dff reg48(.d(imm_in[0]), .q(imm_out[0]), .wen(we), .clk(clk), .rst(rst));
dff reg49(.d(imm_in[1]), .q(imm_out[1]), .wen(we), .clk(clk), .rst(rst));
dff reg50(.d(imm_in[2]), .q(imm_out[2]), .wen(we), .clk(clk), .rst(rst));
dff reg51(.d(imm_in[3]), .q(imm_out[3]), .wen(we), .clk(clk), .rst(rst));

dff reg52(.d(rd_addr_in[0]), .q(rd_addr_out[0]), .wen(we), .clk(clk), .rst(rst));
dff reg53(.d(rd_addr_in[1]), .q(rd_addr_out[1]), .wen(we), .clk(clk), .rst(rst));
dff reg54(.d(rd_addr_in[2]), .q(rd_addr_out[2]), .wen(we), .clk(clk), .rst(rst));
dff reg55(.d(rd_addr_in[3]), .q(rd_addr_out[3]), .wen(we), .clk(clk), .rst(rst));

dff reg56(.d(rt_addr_in[0]), .q(rt_addr_out[0]), .wen(we), .clk(clk), .rst(rst));
dff reg57(.d(rt_addr_in[1]), .q(rt_addr_out[1]), .wen(we), .clk(clk), .rst(rst));
dff reg58(.d(rt_addr_in[2]), .q(rt_addr_out[2]), .wen(we), .clk(clk), .rst(rst));
dff reg59(.d(rt_addr_in[3]), .q(rt_addr_out[3]), .wen(we), .clk(clk), .rst(rst));

dff reg60(.d(rs_addr_in[0]), .q(rs_addr_out[0]), .wen(we), .clk(clk), .rst(rst));
dff reg61(.d(rs_addr_in[1]), .q(rs_addr_out[1]), .wen(we), .clk(clk), .rst(rst));
dff reg62(.d(rs_addr_in[2]), .q(rs_addr_out[2]), .wen(we), .clk(clk), .rst(rst));
dff reg63(.d(rs_addr_in[3]), .q(rs_addr_out[3]), .wen(we), .clk(clk), .rst(rst));

dff reg64(.d(ex_signals_in[0]), .q(ex_signals_out[0]), .wen(we), .clk(clk), .rst(rst));
dff reg65(.d(ex_signals_in[1]), .q(ex_signals_out[1]), .wen(we), .clk(clk), .rst(rst));
dff reg66(.d(ex_signals_in[2]), .q(ex_signals_out[2]), .wen(we), .clk(clk), .rst(rst));
dff reg67(.d(ex_signals_in[3]), .q(ex_signals_out[3]), .wen(we), .clk(clk), .rst(rst));
dff reg68(.d(ex_signals_in[4]), .q(ex_signals_out[4]), .wen(we), .clk(clk), .rst(rst));
dff reg69(.d(ex_signals_in[5]), .q(ex_signals_out[5]), .wen(we), .clk(clk), .rst(rst));
dff reg70(.d(ex_signals_in[6]), .q(ex_signals_out[6]), .wen(we), .clk(clk), .rst(rst));
dff reg71(.d(ex_signals_in[7]), .q(ex_signals_out[7]), .wen(we), .clk(clk), .rst(rst));
dff reg72(.d(ex_signals_in[8]), .q(ex_signals_out[8]), .wen(we), .clk(clk), .rst(rst));
dff reg73(.d(ex_signals_in[9]), .q(ex_signals_out[9]), .wen(we), .clk(clk), .rst(rst));
dff reg74(.d(ex_signals_in[10]), .q(ex_signals_out[10]), .wen(we), .clk(clk), .rst(rst));

dff reg75(.d(mem_signals_in[0]), .q(mem_signals_out[0]), .wen(we), .clk(clk), .rst(rst));
dff reg76(.d(mem_signals_in[1]), .q(mem_signals_out[1]), .wen(we), .clk(clk), .rst(rst));

dff reg77(.d(wb_signals_in[0]), .q(wb_signals_out[0]), .wen(we), .clk(clk), .rst(rst));
dff reg78(.d(wb_signals_in[1]), .q(wb_signals_out[1]), .wen(we), .clk(clk), .rst(rst));
dff reg79(.d(wb_signals_in[2]), .q(wb_signals_out[2]), .wen(we), .clk(clk), .rst(rst));

dff reg80(.d(instr_in[0]), .q(instr_out[0]), .wen(we), .clk(clk), .rst(rst));
dff reg81(.d(instr_in[1]), .q(instr_out[1]), .wen(we), .clk(clk), .rst(rst));
dff reg82(.d(instr_in[2]), .q(instr_out[2]), .wen(we), .clk(clk), .rst(rst));
dff reg83(.d(instr_in[3]), .q(instr_out[3]), .wen(we), .clk(clk), .rst(rst));
dff reg84(.d(instr_in[4]), .q(instr_out[4]), .wen(we), .clk(clk), .rst(rst));
dff reg85(.d(instr_in[5]), .q(instr_out[5]), .wen(we), .clk(clk), .rst(rst));
dff reg86(.d(instr_in[6]), .q(instr_out[6]), .wen(we), .clk(clk), .rst(rst));
dff reg87(.d(instr_in[7]), .q(instr_out[7]), .wen(we), .clk(clk), .rst(rst));
dff reg88(.d(instr_in[8]), .q(instr_out[8]), .wen(we), .clk(clk), .rst(rst));
dff reg89(.d(instr_in[9]), .q(instr_out[9]), .wen(we), .clk(clk), .rst(rst));
dff reg90(.d(instr_in[10]), .q(instr_out[10]), .wen(we), .clk(clk), .rst(rst));
dff reg91(.d(instr_in[11]), .q(instr_out[11]), .wen(we), .clk(clk), .rst(rst));
dff reg92(.d(instr_in[12]), .q(instr_out[12]), .wen(we), .clk(clk), .rst(rst));
dff reg93(.d(instr_in[13]), .q(instr_out[13]), .wen(we), .clk(clk), .rst(rst));
dff reg94(.d(instr_in[14]), .q(instr_out[14]), .wen(we), .clk(clk), .rst(rst));
dff reg95(.d(instr_in[15]), .q(instr_out[15]), .wen(we), .clk(clk), .rst(rst));

endmodule
