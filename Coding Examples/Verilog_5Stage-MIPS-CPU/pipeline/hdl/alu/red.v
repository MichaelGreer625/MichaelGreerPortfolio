//tree of 4 bit CLAs -> computes R bits 3:0
//first level:  carries not propagated
//second level:  2 CLAs
//third level:  1 CLA

//Wallace tree of CSAs -> computes R bits 6:4
//R bits computed from sum of carries from 7 CLAs in reduction tree

module red
(
    input signed [15:0] psum,
    input [3:0] carry1, //4 carry bits from adder
    output signed [15:0] result
);

wire cx, cy, cz;
wire [3:0] s5, s6, carryin;
wire sum1, sum2, sum3, sum4;
wire cout1, cout2, cout3, cout4;

//tree of 4 bit CLAs, not including first level
cla_4 cla0(.a(psum[15:12]), .b(psum[11:8]), .cin(1'b0), .sum(s5), .cout(cx), .gen(), .prop());
cla_4 cla1(.a(psum[7:4]), .b(psum[3:0]), .cin(1'b0), .sum(s6), .cout(cy), .gen(), .prop());
cla_4 cla2(.a(s5), .b(s6), .cin(1'b0), .sum(result[3:0]), .cout(cz), .gen(), .prop());

assign carryin[3] = ~carry1[3];
assign carryin[2] = ~carry1[2];
assign carryin[1] = ~carry1[1];
assign carryin[0] = ~carry1[0];

//Wallace tree for sum of 7 carry bits
csa1bit csa1(.x(carryin[3]), .y(carryin[2]), .z(carryin[1]), .cout(cout1), .sum(sum1));
csa1bit csa2(.x(carryin[0]), .y(cx), .z(cy), .cout(cout2), .sum(sum2));
csa1bit csa3(.x(sum1), .y(cz), .z(sum2), .cout(cout3), .sum(sum3));
csa1bit csa4(.x(cout1), .y(cout2), .z(cout3), .cout(cout4), .sum(sum4));

assign result[4] = sum3;
assign result[5] = sum4;
assign result[6] = cout4 ^ 1'b1;
assign result[15:7] = {10{result[6]}};

endmodule
