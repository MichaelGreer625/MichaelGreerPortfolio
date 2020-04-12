module adder5bit(
input [4:0] a,
input [4:0] b,
output [4:0] sum
);

wire c0, c1, c2, c3, c4;

fa1bit fa0(.a(a[0]), .b(b[0]), .cin(0), .sum(sum[0]), .cout(c0));
fa1bit fa1(.a(a[1]), .b(b[1]), .cin(c0), .sum(sum[1]), .cout(c1));
fa1bit fa2(.a(a[2]), .b(b[2]), .cin(c1), .sum(sum[2]), .cout(c2));
fa1bit fa3(.a(a[3]), .b(b[3]), .cin(c2), .sum(sum[3]), .cout(c3));
fa1bit fa4(.a(a[4]), .b(b[4]), .cin(c3), .sum(sum[4]), .cout(c4));

endmodule
