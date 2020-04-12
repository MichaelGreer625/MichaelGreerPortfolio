/*
 16bit register w/ enable to store PC value
*/

module pc_reg
(
    input clk,
    input rst_n,
    input [15:0] in,
    input wen,
    output [15:0] out
);

dff pc0(.d(in[0]), .q(out[0]), .wen(wen), .clk(clk), .rst(rst_n));
dff pc1(.d(in[1]), .q(out[1]), .wen(wen), .clk(clk), .rst(rst_n));
dff pc2(.d(in[2]), .q(out[2]), .wen(wen), .clk(clk), .rst(rst_n));
dff pc3(.d(in[3]), .q(out[3]), .wen(wen), .clk(clk), .rst(rst_n));
dff pc4(.d(in[4]), .q(out[4]), .wen(wen), .clk(clk), .rst(rst_n));
dff pc5(.d(in[5]), .q(out[5]), .wen(wen), .clk(clk), .rst(rst_n));
dff pc6(.d(in[6]), .q(out[6]), .wen(wen), .clk(clk), .rst(rst_n));
dff pc7(.d(in[7]), .q(out[7]), .wen(wen), .clk(clk), .rst(rst_n));
dff pc8(.d(in[8]), .q(out[8]), .wen(wen), .clk(clk), .rst(rst_n));
dff pc9(.d(in[9]), .q(out[9]), .wen(wen), .clk(clk), .rst(rst_n));
dff pc10(.d(in[10]), .q(out[10]), .wen(wen), .clk(clk), .rst(rst_n));
dff pc11(.d(in[11]), .q(out[11]), .wen(wen), .clk(clk), .rst(rst_n));
dff pc12(.d(in[12]), .q(out[12]), .wen(wen), .clk(clk), .rst(rst_n));
dff pc13(.d(in[13]), .q(out[13]), .wen(wen), .clk(clk), .rst(rst_n));
dff pc14(.d(in[14]), .q(out[14]), .wen(wen), .clk(clk), .rst(rst_n));
dff pc15(.d(in[15]), .q(out[15]), .wen(wen), .clk(clk), .rst(rst_n));

endmodule
