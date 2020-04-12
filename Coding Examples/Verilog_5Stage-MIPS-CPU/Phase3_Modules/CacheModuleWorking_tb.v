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
//outputs
.DataOutMainModule(DataOutMainModule),
.StallPipeline(StallPipeline)
);

//WHEN TESTING THIS CHECK THE WAVE FORMS AND YOU WILL SEE PROPER OPERATION.

initial begin
clk = 0;
rst = 0;
write = 0;
//MemAddress = 16'h0000;
//DataIn = 16'h0000;

/*
//this here is a write miss, reissueing the command, then reading the value.
//this also tests the read hit, write hit
@(posedge clk)
rst = 1;
write = 1;
MemAddress = 16'h0002;
DataIn = 16'hffff;
@(negedge StallPipeline)
rst = 1;
write = 1;
MemAddress = 16'h0002;
DataIn = 16'hffff;
@(posedge clk)
rst = 1;
write = 0;
MemAddress = 16'h0002;
DataIn = 16'hffff;
@(negedge clk)//this is the data out in the same clock cycle
$display("write miss, reissueing the command, then reading the value: %h", DataOutMainModule) ;
*/

//read miss, reissue the read. //NOTE THE VALUE READ AT THAT ADDRESS IS XXXX, THERE IS NOTHING IN THE MODULE.
//LOAD A .img FILE INTO THE MEMORY MODULE THAT HAS MEMORY AT ALL LOCATIONS IF YOUD LIKE.
@(posedge clk)
rst = 1;
write = 0;
MemAddress = 16'h0000;
DataIn = 16'hffff;
@(negedge StallPipeline)
$display("read 0x0 miss, reissue the read: %h", DataOutMainModule);
rst = 1;
write = 0;
MemAddress = 16'h0000;
DataIn = 16'hffff;
@(negedge clk)//this is the data out in the same clock cycle
$display("read 0x0 : %h", DataOutMainModule);

@(posedge clk)
rst = 1;
write = 0;
MemAddress = 16'h0002;
DataIn = 16'hffff;
@(negedge clk)
$display("read 0x2 : %h", DataOutMainModule);

@(posedge clk)
rst = 1;
write = 0;
MemAddress = 16'h0004;
DataIn = 16'hffff;
@(negedge clk)
$display("read 0x4 : %h", DataOutMainModule);

@(posedge clk)
rst = 1;
write = 0;
MemAddress = 16'h0006;
DataIn = 16'hffff;
@(negedge clk)
$display("read 0x6 : %h", DataOutMainModule);

@(posedge clk)
rst = 1;
write = 0;
MemAddress = 16'h0008;
DataIn = 16'hffff;
@(negedge clk)
$display("read 0x8 : %h", DataOutMainModule);

@(posedge clk)
rst = 1;
write = 0;
MemAddress = 16'h000a;
DataIn = 16'hffff;
@(negedge clk)
$display("read 0xa : %h", DataOutMainModule);

@(posedge clk)
rst = 1;
write = 0;
MemAddress = 16'h000c;
DataIn = 16'hffff;
@(negedge clk)
$display("read 0xc : %h", DataOutMainModule);

@(posedge clk)
rst = 1;
write = 0;
MemAddress = 16'h000e;
DataIn = 16'hffff;
@(negedge clk)
$display("read 0xe : %h", DataOutMainModule);

@(posedge clk)
rst = 1;
write = 0;
MemAddress = 16'h0010;
DataIn = 16'hffff;
@(negedge StallPipeline)
$display("read 0x10 miss, reissue the read: %h", DataOutMainModule);
rst = 1;
write = 0;
MemAddress = 16'h0010;
DataIn = 16'hffff;
@(negedge clk)
$display("read 0x10 : %h", DataOutMainModule);

@(posedge clk)
rst = 1;
write = 0;
MemAddress = 16'h0012;
DataIn = 16'hffff;
@(negedge clk)
$display("read 0x12 : %h", DataOutMainModule);

$stop;

end
always #5 clk = !clk;
endmodule
