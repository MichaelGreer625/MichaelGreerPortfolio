module csa1test();

reg x, y, z;
wire cout, sum;
wire [1:0] total;

csa1bit idut(x, y, z, cout, sum);

assign total = x + y + z;

initial begin
forever begin
#1;
    x = $random;
    y = $random;
    z = $random;
#1;
    if ((cout != total[1]) && (sum!= total[0])) begin
        $display("carry-save output incorrect.");
	$display("x %b, y %b, z %b, cout %b, sum %b", x, y, z, cout, sum);
    end
end
end

initial begin

#300;
$stop;
end

endmodule
