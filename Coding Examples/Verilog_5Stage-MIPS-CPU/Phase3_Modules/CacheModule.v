
module cacheBlock(
input clk, rst,
input [15:0] DataIn,
input write,
input [15:0] MemAddress,
output [15:0] DataOutMainModule,
output StallPipeline
);
//these wires need to be declaired here for the compiler, but will be commented out below.
wire [15:0] RequestingMemAddress;
wire [15:0] MemorysOutputtingData;
wire WriteTagFromController, WriteDataFromController;
wire EnableTheRead;
//At first we will not have a stall, so we will access the cache blocks in parallel with the logic
//that is checking if we need to stall the pipeline. If we need to stall the pipeline we will recieve
//the stall and switch over to the memory address that is coming out of the controller at the 
//next clock cycle, with will be the start of the interating through the 8 2 byte chunks.
wire [15:0] AddressToDecode;
assign AddressToDecode = (StallPipeline) ? RequestingMemAddress : MemAddress;

//---------------DECODER FOR INDEXING CACHE BLOCKS BELOW---------------------------------
	//the block index bits from the address line will go into to decoder to one hot an output 0-127, this chooses the block in the dataArrays.
	wire [127:0] TheBlockEnable;
	decoder_7_128 theDecoder(
	//input below
		.binaryin(AddressToDecode[10:4]), 
	//output below
		.decoder_out(TheBlockEnable)
	);
//---------------DECODER FOR INDEXING BYTES WITHIN CACHE BLOCKS BELOW---------------------------------
	//the block index bits from the address line will go into to decoder to one hot an output 0-127, this chooses the block in the dataArrays.
	wire [7:0] TheWordEnable;
	decoder_3_8 theDecoder2(
	//input below
		.binaryin(AddressToDecode[3:1]), 
	//output below
		.decoder_out(TheWordEnable)
	);
//---------------CACHEBLOCK DATA ARRAY BELOW---------------------------------
	//below we connect the assorted wires to the dataArray specifically the decoded one hot block enable from above.
	wire [15:0] DataToWriteToCache;
	wire WhenToWrite;
	//below if we have a stall then we are writing memorys data, if not stall, then writing data coming into the module.
	assign DataToWriteToCache = StallPipeline ? MemorysOutputtingData : DataIn;
	assign WhenToWrite = StallPipeline ? WriteDataFromController : write;
	DataArray theData(
	//inputs below
		.clk(clk), 
		.rst(rst), 
 
		.DataIn(DataToWriteToCache), 
		.Write(WhenToWrite), 
			//select below 
		.BlockEnable(TheBlockEnable),  
		.WordEnable(TheWordEnable),  


	//output below
		.DataOut(DataOutMainModule)
	);
//---------------CACHEBLOCK META!DATA ARRAY BELOW---------------------------------
	//below is setting up wires for the meta data array.
	wire [7:0] DataInM;
	wire [7:0] DataOutM;
	wire WriteM;
	MetaDataArray theMetaData(
	//inputs below
		.clk(clk),
		.rst(rst),  

		.DataIn({3'b100, MemAddress[15:11]}), //the 3 MSB's are up for us to do whatever with, MSB is the valid bit. //Memaddress will stay same because of stall
		.Write(WriteTagFromController),  
			//select below
		.BlockEnable(TheBlockEnable),
	//outputs below  
		.DataOut(DataOutM)
	);
	//lets say the MSB of the meta data is the valid bit.
	//below we are checking if its valid, and if the tag bits are equal to the tag bits of the memAddress. cache miss if not.
	assign CacheMiss = ~(DataOutM[7] & (DataOutM[4:0] == MemAddress[15:11]));
//---------------MAIN MEMORY BELOW---------------------------------
	wire MemIsNowValid;
	//wire [15:0] MemorysOutputtingData;
	wire WhenToWriteToMemory;
	assign WhenToWriteToMemory = StallPipeline ? 0 : write;
	memory4c theMainMemory(
	//outputs below
		.data_out(MemorysOutputtingData), 
		.data_valid(MemIsNowValid), 


	//inputs below
		.clk(clk), 
		.rst(~rst),  
             
		.addr(AddressToDecode),      //addresstodecode is the master address thats muxed through at top, used for decoding and will also use here.
		.data_in(DataIn),

		.wr(WhenToWriteToMemory),  
		.enable(EnableTheRead)
	);
//---------------CACHE CONTROLLER BELOW---------------------------------
	//wire WriteTagFromController, WriteDataFromController;
	//wire [15:0] RequestingMemAddress;
	//wire EnableTheRead;
	
	cacheController TheController(
	//inputs below
		.clk(clk), 
		.rst_n(rst),
		.miss_detected(CacheMiss),
		.miss_address(MemAddress),
								//	input  [16:0] .memory_data(),
		.memory_data_valid(MemIsNowValid),
	//outputs below
		.fsm_busy(StallPipeline),
		.write_data_array(WriteDataFromController),
		.write_tag_array(WriteTagFromController),
		.memory_address(RequestingMemAddress),
		.EnableRead(EnableTheRead)
	);

endmodule





module cacheController(
	input clk, rst_n,
	input miss_detected,
	input [15:0] miss_address,
	//input  [15:0] memory_data,
	input memory_data_valid,
	output reg fsm_busy,
	output reg write_data_array,
	output reg write_tag_array,
	output reg EnableRead,
	output reg [15:0] memory_address
	);
	
	localparam IDLE = 1'b0; 
	localparam WAIT = 1'b1;
	
        wire [2:0] toaddwire;
        wire addonewire;

	reg nextstate;// is the state going into the state flip flop
	wire state;//is the state coming out of the state flip flop
	reg [2:0] toadd; //is the output of the 3bit adder and the input to the 3bit flipflop memory
	wire [2:0] toaddout;//is the output of the 3bit flip flop memory and the input to A of the adder
	reg addone; // this is the input B of the adder, is either 1 or 0 designating an iterate of one or not.
	
	wire finished;//the finished calculation is as fallows. If the toaddout(output of the adder) is all ones
			//then bitwise anding it with itself will produce a 1. this signifies the last memory access
			//and then we must wait for the last memory_data_valid to assert and then we know we are FINISHED.
	assign finished = ((toaddout == 3'b111)&memory_data_valid);
	
        assign addonewire = addone;
        assign toaddwire = toadd;	
	
	dff state_t(.q(state), .d(nextstate), .wen(1'b1), .clk(clk), .rst(rst_n)); //This is the state flip flop
	
	
	//3bit counter var that is added to the end of the memory address section memaddress[15:3] 
	//this iterates through all the memory in the cache block. 
	dff counter1(.q(toaddout[0]), .d(toadd[0]), .wen(1'b1), .clk(clk), .rst(rst_n));
	dff counter2(.q(toaddout[1]), .d(toadd[1]), .wen(1'b1), .clk(clk), .rst(rst_n));
	dff counter3(.q(toaddout[2]), .d(toadd[2]), .wen(1'b1), .clk(clk), .rst(rst_n));
	
	//Below is a simple 3 bit adder. Ripple carry.
	rippleadder3bit inst(.Sum(toaddwire), .Cout(Cout), .A(toaddout) ,.B(addonewire) ,.Cin(1'b0));
	
	assign finished = ((toaddout == 3'b000)&memory_data_valid); //3'b000 because we want the 3'b111 to go through, and then the value will roll over to 3'b000
	
	
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
				EnableRead = miss_detected ? 1 : 0;
				memory_address = {miss_address[15:4], 3'b000, 1'b0};

				fsm_busy = miss_detected ? 1 : 0;
				nextstate = miss_detected ? WAIT : IDLE;

				write_data_array = 0;
				write_tag_array = 0;
				toadd = 1;
				addone = 0;
			end
			WAIT: begin
				//do below if all done with all memory access. Check what finished is above.
				fsm_busy = finished ? 0 : 1;
				nextstate = finished ? IDLE : WAIT;
				write_tag_array = finished ? 1 : 0;
				//below is what we do when waiting for and recieving the memory_data_valid.
				memory_address = {miss_address[15:4], toadd[2:0], 1'b0};
				EnableRead = memory_data_valid ? 1 : 0;
				write_data_array = (memory_data_valid) ? 1 : 0;

				addone = (memory_data_valid) ? 1 : 0;
	
	
			end
		endcase
	end
endmodule




//Data Array of 128 cache blocks
//Each block will have 8 words
//BlockEnable and WordEnable are one-hot
//WriteEnable is one on writes and zero on reads

module DataArray(input clk, input rst, input [15:0] DataIn, input Write, input [127:0] BlockEnable, input [7:0] WordEnable, output [15:0] DataOut);
	Block blk[127:0]( .clk(clk), .rst(rst), .Din(DataIn), .WriteEnable(Write), .Enable(BlockEnable), .WordEnable(WordEnable), .Dout(DataOut));
endmodule

//64 byte (8 word) cache block
module Block( input clk,  input rst, input [15:0] Din, input WriteEnable, input Enable, input [7:0] WordEnable, output [15:0] Dout);
	wire [7:0] WordEnable_real;
	assign WordEnable_real = {8{Enable}} & WordEnable; //Only for the enabled cache block, you enable the specific word
	DWord dw[7:0]( .clk(clk), .rst(rst), .Din(Din), .WriteEnable(WriteEnable), .Enable(WordEnable_real), .Dout(Dout));
endmodule

//Each word has 16 bits
module DWord( input clk,  input rst, input [15:0] Din, input WriteEnable, input Enable, output [15:0] Dout);
	DCell dc[15:0]( .clk(clk), .rst(rst), .Din(Din[15:0]), .WriteEnable(WriteEnable), .Enable(Enable), .Dout(Dout[15:0]));
endmodule


module DCell( input clk,  input rst, input Din, input WriteEnable, input Enable, output Dout);
	wire q;
	assign Dout = (Enable & ~WriteEnable) ? q:'bz;
	dff dffd(.q(q), .d(Din), .wen(Enable & WriteEnable), .clk(clk), .rst(rst));
endmodule
//Tag Array of 128  blocks
//Each block will have 1 byte
//BlockEnable is one-hot
//WriteEnable is one on writes and zero on reads

module MetaDataArray(input clk, input rst, input [7:0] DataIn, input Write, input [127:0] BlockEnable, output [7:0] DataOut);
	MBlock Mblk[127:0]( .clk(clk), .rst(rst), .Din(DataIn), .WriteEnable(Write), .Enable(BlockEnable), .Dout(DataOut));
endmodule

module MBlock( input clk,  input rst, input [7:0] Din, input WriteEnable, input Enable, output [7:0] Dout);
	MCell mc[7:0]( .clk(clk), .rst(rst), .Din(Din[7:0]), .WriteEnable(WriteEnable), .Enable(Enable), .Dout(Dout[7:0]));
endmodule

module MCell( input clk,  input rst, input Din, input WriteEnable, input Enable, output Dout);
	wire q;
	assign Dout = (Enable & ~WriteEnable) ? q:'bz;
	dff dffm(.q(q), .d(Din), .wen(Enable & WriteEnable), .clk(clk), .rst(rst));
endmodule


//////////////////////////////////////
//
// Memory -- single cycle write, multi-cycle read
//
// written for CS/ECE 552, Spring '18
// Gokul Ravi, 9 Apr 2018
//
// This is a byte-addressable,
// 16-bit wide memory
// Note: The last bit of the address has to be 0.
//
// On reset, memory loads from file "loadfile_all.img".
// (You may change the name of the file in
// the $readmemh statement below.)
// File format:
//     @0
//     <hex data 0>
//     <hex data 1>
//     ...etc
//
//
//////////////////////////////////////

module memory4c (data_out, data_in, addr, enable, wr, clk, rst, data_valid);

   parameter ADDR_WIDTH = 16;
   output  reg [15:0] data_out;
   output reg data_valid;
   input [15:0]   data_in;
   input [ADDR_WIDTH-1 :0]   addr;
   input          enable;
   input          wr;
   input          clk;
   input          rst;
   wire [15:0]    data_out_4;
   reg [15:0]    data_out_3, data_out_2, data_out_1;
   wire    data_valid_4;
   reg     data_valid_3, data_valid_2, data_valid_1;


   reg [15:0]      mem [0:2**ADDR_WIDTH-1];
   reg            loaded;

   assign         data_out_4 = (enable & (~wr))? {mem[addr[ADDR_WIDTH-1 :1]]}: 0; //Read
   assign	     data_valid_4 = (enable & (~wr));
   initial begin
      loaded = 0;
   end
   always @(posedge clk) begin
      if (rst) begin
         //load loadfile_all.img
         if (!loaded) begin
            $readmemh("loadfile_all.img", mem);
            loaded = 1;
         end

      end
      else begin
         if (enable & wr) begin
                mem[addr[ADDR_WIDTH-1 :1]] = data_in[15:0];       // The actual write
         end
      end
   end

  always @(posedge clk) begin
        if (rst) begin
                data_out_3 <= 0;
                data_out_2 <= 0;
                data_out_1 <= 0;
                data_out <= 0;

                data_valid_3 <= 0;
                data_valid_2 <= 0;
                data_valid_1 <= 0;
                data_valid <= 0;
        end
        else begin
                data_out_3 <= data_out_4;
                data_out_2 <= data_out_3;
                data_out_1 <= data_out_2;
                data_out <= data_out_1;

                data_valid_3 <= data_valid_4;
                data_valid_2 <= data_valid_3;
                data_valid_1 <= data_valid_2;
                data_valid <= data_valid_1;

        end
  end


endmodule
                         

	

module decoder_7_128
(
    input [6:0] binaryin,
    output [127:0] decoder_out
);

wire [127:0] t0, t1, t2, t3, t4, t5;

assign t0 = (binaryin[0] == 1'b1) ? 128'b1 << 1 : 128'b1;
assign t1 = (binaryin[1] == 1'b1) ? t0 << 2 : t0;
assign t2 = (binaryin[2] == 1'b1) ? t1 << 4 : t1;
assign t3 = (binaryin[3] == 1'b1) ? t2 << 8 : t2;
assign t4 = (binaryin[4] == 1'b1) ? t3 << 16 : t3;
assign t5 = (binaryin[5] == 1'b1) ? t4 << 32 : t4;
assign decoder_out = (binaryin[6] == 1'b1) ? t5 << 64 : t5;

endmodule


module decoder_3_8 (
    input [2:0] binaryin,
    output [7:0] decoder_out
);

wire [7:0] t0, t1;

assign t0 = (binaryin[0] == 1'b1) ? 8'b1 << 1 : 8'b1;
assign t1 = (binaryin[1] == 1'b1) ? t0 << 2 : t0;
assign decoder_out = (binaryin[2] == 1'b1) ? t1 << 4 : t1;

endmodule

module rippleadder3bit
(
    output [2:0] Sum,
    output Cout,
    input [2:0] A,
    input B,
    input Cin
);

wire c0, c1;

fa_1bit fa0(.a(A[0]), .b(B), .cin(Cin), .sum(Sum[0]), .cout(c0));
fa_1bit fa1(.a(A[1]), .b(1'b0), .cin(c0), .sum(Sum[1]), .cout(c1));
fa_1bit fa2(.a(A[2]), .b(1'b0), .cin(c1), .sum(Sum[2]), .cout(Cout));

endmodule
 
// Basic full adder
module fa_1bit
(
    input a,
    input b,
    input cin,
    output sum,
    output cout
);

assign sum = a ^ b ^ cin;
assign cout = (a & b) | (cin & (a ^ b));

endmodule
