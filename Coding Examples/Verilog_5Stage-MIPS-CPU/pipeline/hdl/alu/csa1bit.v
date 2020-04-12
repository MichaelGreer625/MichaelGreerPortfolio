module csa1bit(
input x, y, z,
output cout,
output sum);

fa_1 fa(.a(x), .b(y), .cin(z), .sum(sum), .cout(cout));

endmodule
