module cpu_test();

reg clk, rst;

reg en, wr;
reg [15:0] data_in, addr;

wire hlt;
wire [15:0] pc;

// it actually just tests the memory load right now

memory1c mem(.data_out(pc), .data_in(data_in), .addr(addr), .enable(en), .wr(wr), .clk(clk), .rst(rst));

initial begin
rst = 0;
data_in = 10;
en = 0;
wr = 0;
clk = 1;
#201;
rst = 1;
#199;
en = 1;
#1000;
$stop;
end

always #50 begin
clk = ~clk;
end

endmodule
