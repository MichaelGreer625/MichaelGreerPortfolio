/*
  Stage2 (EX/MEM) Pipeline register
*/

module stage2 
(
    input clk,
    input rst,
    input we,
    input [15:0] pc_in,
    input [15:0] alu_in,        // ALU result (address)
    input [15:0] data_in,       // Reg2 result (data)
    input [3:0] rd_addr_in,     // rf write address
    input [1:0] mem_signals_in, // MEM stage signals
    input [2:0] wb_signals_in,  // WB stage signals
    input [2:0 ]flags_ctl,
    input [2:0] flags_in,          // ZVN flags
    output [15:0] pc_out,
    output [15:0] alu_out,
    output [15:0] data_out,
    output [3:0] rd_addr_out,
    output [1:0] mem_signals_out,
    output [2:0] wb_signals_out,
    output [2:0] flags_out
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

dff reg16(.d(alu_in[0]), .q(alu_out[0]), .wen(we), .clk(clk), .rst(rst));
dff reg17(.d(alu_in[1]), .q(alu_out[1]), .wen(we), .clk(clk), .rst(rst));
dff reg18(.d(alu_in[2]), .q(alu_out[2]), .wen(we), .clk(clk), .rst(rst));
dff reg19(.d(alu_in[3]), .q(alu_out[3]), .wen(we), .clk(clk), .rst(rst));
dff reg20(.d(alu_in[4]), .q(alu_out[4]), .wen(we), .clk(clk), .rst(rst));
dff reg21(.d(alu_in[5]), .q(alu_out[5]), .wen(we), .clk(clk), .rst(rst));
dff reg22(.d(alu_in[6]), .q(alu_out[6]), .wen(we), .clk(clk), .rst(rst));
dff reg23(.d(alu_in[7]), .q(alu_out[7]), .wen(we), .clk(clk), .rst(rst));
dff reg24(.d(alu_in[8]), .q(alu_out[8]), .wen(we), .clk(clk), .rst(rst));
dff reg25(.d(alu_in[9]), .q(alu_out[9]), .wen(we), .clk(clk), .rst(rst));
dff reg26(.d(alu_in[10]), .q(alu_out[10]), .wen(we), .clk(clk), .rst(rst));
dff reg27(.d(alu_in[11]), .q(alu_out[11]), .wen(we), .clk(clk), .rst(rst));
dff reg28(.d(alu_in[12]), .q(alu_out[12]), .wen(we), .clk(clk), .rst(rst));
dff reg29(.d(alu_in[13]), .q(alu_out[13]), .wen(we), .clk(clk), .rst(rst));
dff reg30(.d(alu_in[14]), .q(alu_out[14]), .wen(we), .clk(clk), .rst(rst));
dff reg31(.d(alu_in[15]), .q(alu_out[15]), .wen(we), .clk(clk), .rst(rst));

dff reg32(.d(data_in[0]), .q(data_out[0]), .wen(we), .clk(clk), .rst(rst));
dff reg33(.d(data_in[1]), .q(data_out[1]), .wen(we), .clk(clk), .rst(rst));
dff reg34(.d(data_in[2]), .q(data_out[2]), .wen(we), .clk(clk), .rst(rst));
dff reg35(.d(data_in[3]), .q(data_out[3]), .wen(we), .clk(clk), .rst(rst));
dff reg36(.d(data_in[4]), .q(data_out[4]), .wen(we), .clk(clk), .rst(rst));
dff reg37(.d(data_in[5]), .q(data_out[5]), .wen(we), .clk(clk), .rst(rst));
dff reg38(.d(data_in[6]), .q(data_out[6]), .wen(we), .clk(clk), .rst(rst));
dff reg39(.d(data_in[7]), .q(data_out[7]), .wen(we), .clk(clk), .rst(rst));
dff reg40(.d(data_in[8]), .q(data_out[8]), .wen(we), .clk(clk), .rst(rst));
dff reg41(.d(data_in[9]), .q(data_out[9]), .wen(we), .clk(clk), .rst(rst));
dff reg42(.d(data_in[10]), .q(data_out[10]), .wen(we), .clk(clk), .rst(rst));
dff reg43(.d(data_in[11]), .q(data_out[11]), .wen(we), .clk(clk), .rst(rst));
dff reg44(.d(data_in[12]), .q(data_out[12]), .wen(we), .clk(clk), .rst(rst));
dff reg45(.d(data_in[13]), .q(data_out[13]), .wen(we), .clk(clk), .rst(rst));
dff reg46(.d(data_in[14]), .q(data_out[14]), .wen(we), .clk(clk), .rst(rst));
dff reg47(.d(data_in[15]), .q(data_out[15]), .wen(we), .clk(clk), .rst(rst));

dff reg48(.d(rd_addr_in[0]), .q(rd_addr_out[0]), .wen(we), .clk(clk), .rst(rst));
dff reg49(.d(rd_addr_in[1]), .q(rd_addr_out[1]), .wen(we), .clk(clk), .rst(rst));
dff reg50(.d(rd_addr_in[2]), .q(rd_addr_out[2]), .wen(we), .clk(clk), .rst(rst));
dff reg51(.d(rd_addr_in[3]), .q(rd_addr_out[3]), .wen(we), .clk(clk), .rst(rst));

dff reg52(.d(mem_signals_in[0]), .q(mem_signals_out[0]), .wen(we), .clk(clk), .rst(rst));
dff reg53(.d(mem_signals_in[1]), .q(mem_signals_out[1]), .wen(we), .clk(clk), .rst(rst));

dff reg54(.d(wb_signals_in[0]), .q(wb_signals_out[0]), .wen(we), .clk(clk), .rst(rst));
dff reg55(.d(wb_signals_in[1]), .q(wb_signals_out[1]), .wen(we), .clk(clk), .rst(rst));
dff reg56(.d(wb_signals_in[2]), .q(wb_signals_out[2]), .wen(we), .clk(clk), .rst(rst));

dff reg57(.d(flags_in[0]), .q(flags_out[0]), .wen(flags_ctl[0]), .clk(clk), .rst(rst));
dff reg58(.d(flags_in[1]), .q(flags_out[1]), .wen(flags_ctl[1]), .clk(clk), .rst(rst));
dff reg59(.d(flags_in[2]), .q(flags_out[2]), .wen(flags_ctl[2]), .clk(clk), .rst(rst));

endmodule
