module cla16testreal();

reg [15:0] a, b;

wire cout;
wire [15:0] sum, addchk;

assign addchk = a + b;

cla_16 iDUT(.a(a), .b(b), .cin(1'b0), .sum(sum), .cout(cout));

initial begin
forever begin
#1;
a = $random;
b = $random;
#1;
if (addchk != sum)
    $display("error i guess");
end
end

initial begin
#300;
$stop;
end

endmodule
