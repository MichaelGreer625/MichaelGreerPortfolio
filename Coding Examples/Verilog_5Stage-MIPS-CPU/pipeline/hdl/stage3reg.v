/*
  Stage3 (MEM/WB) Pipeline register
*/

module stage3 
(
    input clk,
    input rst,
    input [15:0] alu_in,        // ALU result
    input [15:0] data_in,       // dmem data
    input [3:0] rd_addr_in,     // rf write address
    input [2:0] wb_signals_in,  // WB stage signals
    output [15:0] alu_out,
    output [15:0] data_out,
    output [3:0] rd_addr_out,
    output [2:0] wb_signals_out
);

dff reg0(.d(alu_in[0]), .q(alu_out[0]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg1(.d(alu_in[1]), .q(alu_out[1]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg2(.d(alu_in[2]), .q(alu_out[2]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg3(.d(alu_in[3]), .q(alu_out[3]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg4(.d(alu_in[4]), .q(alu_out[4]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg5(.d(alu_in[5]), .q(alu_out[5]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg6(.d(alu_in[6]), .q(alu_out[6]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg7(.d(alu_in[7]), .q(alu_out[7]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg8(.d(alu_in[8]), .q(alu_out[8]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg9(.d(alu_in[9]), .q(alu_out[9]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg10(.d(alu_in[10]), .q(alu_out[10]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg11(.d(alu_in[11]), .q(alu_out[11]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg12(.d(alu_in[12]), .q(alu_out[12]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg13(.d(alu_in[13]), .q(alu_out[13]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg14(.d(alu_in[14]), .q(alu_out[14]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg15(.d(alu_in[15]), .q(alu_out[15]), .wen(1'b1), .clk(clk), .rst(rst));

dff reg16(.d(data_in[0]), .q(data_out[0]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg17(.d(data_in[1]), .q(data_out[1]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg18(.d(data_in[2]), .q(data_out[2]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg19(.d(data_in[3]), .q(data_out[3]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg20(.d(data_in[4]), .q(data_out[4]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg21(.d(data_in[5]), .q(data_out[5]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg22(.d(data_in[6]), .q(data_out[6]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg23(.d(data_in[7]), .q(data_out[7]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg24(.d(data_in[8]), .q(data_out[8]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg25(.d(data_in[9]), .q(data_out[9]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg26(.d(data_in[10]), .q(data_out[10]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg27(.d(data_in[11]), .q(data_out[11]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg28(.d(data_in[12]), .q(data_out[12]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg29(.d(data_in[13]), .q(data_out[13]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg30(.d(data_in[14]), .q(data_out[14]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg31(.d(data_in[15]), .q(data_out[15]), .wen(1'b1), .clk(clk), .rst(rst));

dff reg32(.d(rd_addr_in[0]), .q(rd_addr_out[0]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg33(.d(rd_addr_in[1]), .q(rd_addr_out[1]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg34(.d(rd_addr_in[2]), .q(rd_addr_out[2]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg35(.d(rd_addr_in[3]), .q(rd_addr_out[3]), .wen(1'b1), .clk(clk), .rst(rst));

dff reg36(.d(wb_signals_in[0]), .q(wb_signals_out[0]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg37(.d(wb_signals_in[1]), .q(wb_signals_out[1]), .wen(1'b1), .clk(clk), .rst(rst));
dff reg38(.d(wb_signals_in[2]), .q(wb_signals_out[2]), .wen(1'b1), .clk(clk), .rst(rst));

endmodule
