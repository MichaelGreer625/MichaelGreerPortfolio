/*
  plain 16bit CLA
*/

module cla_16
(
    input [15:0] a,
    input [15:0] b,
    input cin,
    output [15:0] sum,
    output cout
);

wire c1, c2, c3;
wire g0, g1, g2, g3;
wire p0, p1, p2, p3;

// carry gen
assign c1 = g0 | p0 & cin;
assign c2 = g1 | p1 & c1;
assign c3 = g2 | p2 & c2;
assign cout = g3 | p3 & c3;

cla_4 cla0(.a(a[3:0]), .b(b[3:0]), .cin(cin), .sum(sum[3:0]), .cout(), .gen(g0), .prop(p0));
cla_4 cla1(.a(a[7:4]), .b(b[7:4]), .cin(c1), .sum(sum[7:4]), .cout(), .gen(g1), .prop(p1));
cla_4 cla2(.a(a[11:8]), .b(b[11:8]), .cin(c2), .sum(sum[11:8]), .cout(), .gen(g2), .prop(p2));
cla_4 cla3(.a(a[15:12]), .b(b[15:12]), .cin(c3), .sum(sum[15:12]), .cout(), .gen(g3), .prop(p3));

endmodule
