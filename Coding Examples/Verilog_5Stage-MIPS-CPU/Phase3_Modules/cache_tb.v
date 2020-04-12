module cache_tb();

reg clk, rst;
reg [15:0] DataIn;
reg write;
reg [15:0] MemAddress;
wire [15:0] DataOutMainModule;
wire StallPipeline;


cacheBlock Thecache(
.clk(clk), .rst(rst),
.DataIn(DataIn),
.write(write),
.MemAddress(MemAddress),
.DataOutMainModule(DataOutMainModule),
.StallPipeline(StallPipeline)
);

always #5 clk = !clk;

initial begin
clk = 0;
rst = 1;
write = 0;
MemAddress = 16'h0000;
DataIn = 16'h0000;

@negedge clk 
rst = 0;
write = 1;
MemAddress = 16'h0001;
DataIn = 16'h0055;

@negedge clk
write = 0;
MemAddress = 16'h0001;







end

endmodule
