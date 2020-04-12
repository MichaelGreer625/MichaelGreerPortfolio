module cacheControler(
input clk, rst_n,
input miss_detected,
input [16:0] miss_address,
input  [16:0] memory_data,
input memory_data_valid,
output reg fsm_busy,
output reg write_data_array,
output reg write_tag_array,
output reg [15:0] memory_address
);

localparam IDLE = 1'b0; 
localparam WAIT = 1'b1;

reg nextstate;// is the state going into the state flip flop
wire state;//is the state coming out of the state flip flop
reg [2:0] toadd; //is the output of the 3bit adder and the input to the 3bit flipflop memory
wire [2:0] toaddout;//is the output of the 3bit flip flop memory and the input to A of the adder
reg addone; // this is the input B of the adder, is either 1 or 0 designating an iterate of one or not.

wire finished;//the finished calculation is as fallows. If the toaddout(output of the adder) is all ones
		//then bitwise anding it with itself will produce a 1. this signifies the last memory access
		//and then we must wait for the last memory_data_valid to assert and then we know we are FINISHED.
assign finished = ((toaddout&toaddout)&memory_data_valid);



dff state_t(.q(state), .d(nextstate), .wen(1), .clk(clk), .rst(~rst_n)); //This is the state flip flop.


//3bit counter var that is added to the end of the memory address section memaddress[15:3] 
//this iterates through all the memory in the cache block. 
dff counter1(.q(toaddout[0]), .d(toadd[0]), .wen(1), .clk(clk), .rst(~rst_n));
dff counter2(.q(toaddout[1]), .d(toadd[1]), .wen(1), .clk(clk), .rst(~rst_n));
dff counter3(.q(toaddout[2]), .d(toadd[2]), .wen(1), .clk(clk), .rst(~rst_n));

//Below is a simple 3 bit adder. Ripple carry.
rippleadder3bit inst(.Sum(toadd), .Cout(Cout), .A(toaddout) ,.B(addone) ,.Cin(0));

assign finished = ((toaddout&toaddout)&memory_data_valid);


//The biggest thing to note with the opperation of this state machine is that 
//we concatinate the value of the three bit adder to the base address(aka bits 15:4)
//of the memory address. That way we iterate over all the blocks of a cache block,
//bringing those blocks into the cache sequentially.
//for example, showing only bits 7:0 of the memory address. We will access these 
//memory blocks in order, waiting for the Memory_data_valid wire to assert before we 
//iterate the counter, and then in turn interate the next memory address


//Again the memory access will happen in this order:
//(Memory base adr)(add)(2byteoffset)
//(--------16 total bits---)
//1100101011001010 (000)  0
//1100101011001010 (001)  0
//1100101011001010 (010)  0
//1100101011001010 (011)  0
//1100101011001010 (100)  0
//1100101011001010 (101)  0
//1100101011001010 (110)  0
//1100101011001010 (111)  0
always @(*) begin 

	case(state)
		IDLE: begin
			memory_address = {miss_address[15:4], 3'b000, 1'b0};
			fsm_busy = miss_detected ? 1 : 0;
			nextstate = miss_detected ? WAIT : IDLE;
			write_data_array = 0;
			write_tag_array = 0;
			toadd = 0;
			addone = 0;
		end
		WAIT: begin
			//do below if all done with all memory access. Check what finished is above.
			fsm_busy = finished ? 0 : 1;
			nextstate = finished ? IDLE : WAIT;
			write_tag_array = finished ? 1 : 0;
			//below is what we do when waiting for and recieving the memory_data_valid.
			addone = (memory_data_valid) ? 1 : 0;
			write_data_array = (memory_data_valid) ? 1 : 0;
			toadd = (memory_data_valid) ? toadd : toaddout;
			memory_address = {miss_address[15:4], toadd[2:0], 1'b0};


		end
	endcase
end











endmodule
