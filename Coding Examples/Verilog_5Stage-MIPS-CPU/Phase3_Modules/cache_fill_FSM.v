/*
data/address = 16 bits
cache = 2KB
memory = 64KB
cache/memory block size = 2 byte words
*/
module cache_fill_FSM(clk, rst_n, miss_detected, miss_address, fsm_busy, write_data_array, write_tag_array,memory_address, memory_data, memory_data_valid);
input clk, rst_n;
input miss_detected; // active high when tag match logic detects a miss
input [15:0] miss_address; // address that missed the cache
output fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
output write_data_array; // write enable to cache data array to signal when filling with memory_data
output write_tag_array; // write enable to cache tag array to write tag and valid bit once all words are filled in to data array
output [15:0] memory_address; // address to read from memory
input [15:0] memory_data; // data returned by memory (after  delay)
input memory_data_valid; // active high indicates valid data returning on memory bus

wire state, next_state, en_count, rst_count;
wire [4:0] count, next_count;
wire [15:0] addr, next_addr, next_addrInc;

//dff module posted on course page
dff ff(.q(state), .d(next_state), .wen(1'b1), .clk(clk), .rst(rst_n));

assign next_state = ((state == 0) & (miss_detected)) ? 1'b1: 
		((count == 5'b11111) & (state == 1)) ? 1'b0 :
		(state == 1) ? 1'b1 : 1'b0;

assign next_addr = ((state == 0) & (next_state == 1)) ? miss_address : next_addrInc;

assign fsm_busy = (((state == 0) & (next_state == 1)) | ((state == 0) & (next_state == 0))) ? 1'b1 : 1'b0;

assign write_data_array = (count[0] & count[1] & memory_data_valid) ? 1'b1 : 1'b0;

assign write_tag_array = ((state == 1) & (next_state == 0)) ? 1'b1 : 1'b0;

assign rst_count = ((state == 0) & (next_state == 1)) ? 1'b1 : 1'b0;

//5-bit adder to update count
adder5bit counter(.a(count), .b(1'b1), .sum(next_count));

//16-bit adder to add 2 to current address every 4th clock cycle
adder16bit incAddr(.a(addr), .b(2'b10), .sum(next_addrInc));

//register to hold count through states
reg_count rc(.clk(clk), .rst(rst_n | rst_count), .wen(fsm_busy), .in(next_count), .out(count));

//register to hold address through states
reg_address address(.clk(clk), .rst(rst_n), .wen(write_data_array | rst_count), .in(next_addr), .out(addr));

endmodule

module reg_count(
input clk,
input rst,
input wen,
input [4:0] in,
output [4:0] out
);

dff ff1(.q(out[0]), .d(in[0]), .wen(wen), .clk(clk), .rst(rst));
dff ff2(.q(out[1]), .d(in[1]), .wen(wen), .clk(clk), .rst(rst));
dff ff3(.q(out[2]), .d(in[2]), .wen(wen), .clk(clk), .rst(rst));
dff ff4(.q(out[3]), .d(in[3]), .wen(wen), .clk(clk), .rst(rst));
dff ff5(.q(out[4]), .d(in[4]), .wen(wen), .clk(clk), .rst(rst));

endmodule

module reg_address(
input clk,
input rst,
input wen,
input [15:0] in,
output [15:0] out
);

dff ff1(.q(out[0]), .d(in[0]), .wen(wen), .clk(clk), .rst(rst));
dff ff2(.q(out[1]), .d(in[1]), .wen(wen), .clk(clk), .rst(rst));
dff ff3(.q(out[2]), .d(in[2]), .wen(wen), .clk(clk), .rst(rst));
dff ff4(.q(out[3]), .d(in[3]), .wen(wen), .clk(clk), .rst(rst));
dff ff5(.q(out[4]), .d(in[4]), .wen(wen), .clk(clk), .rst(rst));
dff ff6(.q(out[5]), .d(in[5]), .wen(wen), .clk(clk), .rst(rst));
dff ff7(.q(out[6]), .d(in[6]), .wen(wen), .clk(clk), .rst(rst));
dff ff8(.q(out[7]), .d(in[7]), .wen(wen), .clk(clk), .rst(rst));
dff ff9(.q(out[8]), .d(in[8]), .wen(wen), .clk(clk), .rst(rst));
dff ff10(.q(out[9]), .d(in[9]), .wen(wen), .clk(clk), .rst(rst));
dff ff11(.q(out[10]), .d(in[10]), .wen(wen), .clk(clk), .rst(rst));
dff ff12(.q(out[11]), .d(in[11]), .wen(wen), .clk(clk), .rst(rst));
dff ff13(.q(out[12]), .d(in[12]), .wen(wen), .clk(clk), .rst(rst));
dff ff14(.q(out[13]), .d(in[13]), .wen(wen), .clk(clk), .rst(rst));
dff ff15(.q(out[14]), .d(in[14]), .wen(wen), .clk(clk), .rst(rst));
dff ff16(.q(out[15]), .d(in[15]), .wen(wen), .clk(clk), .rst(rst));

endmodule

