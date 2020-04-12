module cache(
input [15:0] dataIn, address, 
input wen, rst, clk,
output [15:0] dataOut
);

cache_fill_FSM cf(.clk(clk), .rst_n(rst), .miss_detected(), .miss_address(), .memory_data(), .memory_data_valid());
 
endmodule

