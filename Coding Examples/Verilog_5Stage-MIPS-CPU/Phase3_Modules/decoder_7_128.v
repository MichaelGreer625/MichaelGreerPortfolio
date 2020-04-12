module decoder_7_128
(
    input [6:0] in,
    output [127:0] out
);

wire [127:0] t0, t1, t2, t3, t4, t5;

assign t0 = (in[0] == 1'b1) ? 16'b1 << 1 : 16'b1;
assign t1 = (in[1] == 1'b1) ? t0 << 2 : t0;
assign t2 = (in[2] == 1'b1) ? t1 << 4 : t1;
assign t3 = (in[3] == 1'b1) ? t2 << 8 : t2;
assign t4 = (in[4] == 1'b1) ? t3 << 16 : t3;
assign t5 = (in[5] == 1'b1) ? t4 << 32 : t4;
assign out = (in[6] == 1'b1) ? t5 << 64 : t5;

endmodule



