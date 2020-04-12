module cla_16_test ();

reg signed [15:0] a, b;
reg [1:0] mode;

reg signed [19:0] atst, btst;

wire signed [15:0] addr, subr, paddr, red;

wire [15:12] pa1, pa2, pa3, pa4;
wire signed [15:0] sum;
wire gen, ov, prop;
wire [3:0] cout, p1, p2, p3, p4;

assign atst = {{4{a[15]}}, a};
assign btst = {{4{b[15]}}, b};

assign pa1 = a[15:12] + b[15:12];
assign pa2 = a[11:8] + b[11:8];
assign pa3 = a[7:4] + b[7:4];
assign pa4 = a[3:0] + b[3:0];

assign addr = (atst + btst > 32767) ? 32767 : ((atst + btst < -32768) ? -32768 : a + b);
assign subr = (atst - btst > 32767) ? 32767 : ((atst - btst < -32768) ? -32768 : a - b);
assign p1 = (~a[15] & ~b[15] & pa1[3]) ? 7 : ((a[15] & b[15] & ~pa1[3]) ? -8 : pa1);
assign p2 = (~a[11] & ~b[11] & pa2[3]) ? 7 : ((a[11] & b[11] & ~pa2[3]) ? -8 : pa2);
assign p3 = (~a[7] & ~b[7] & pa3[3]) ? 7 : ((a[7] & b[7] & ~pa3[3]) ? -8 : pa3);
assign p4 = (~a[3] & ~b[3] & pa4[3]) ? 7 : ((a[3] & b[3] & ~pa4[3]) ? -8 : pa4);

assign red = {pa1, pa2, pa3, pa4};
assign paddr = {p1, p2, p3, p4};

adder16 idut(.a(a[15:0]), .b(b[15:0]), .mode(mode), .sum(sum), .c(cout), .ov(ov));

initial begin
forever begin
#1;
    a = $random;
    b = $random;
    mode = $random;
#1;
    $display("a %d, b %d, mode %h, sum %d, cout %h, ov %b", a, b, mode, sum, cout, ov);
    if (mode == 2'b11 && paddr != sum) begin
        $display("paddr not equal to sum");
    end else if (mode == 2'b10 && red != sum) begin
        $display("red not equal to sum or we");
    end else if (mode == 2'b00 && addr != sum) begin
        $display("addr not equal sum");
    end else if (mode == 2'b01 && subr != sum) begin
        $display("subr not equal sum");
    end
end
end

initial begin

#300;
$stop;
end

endmodule
