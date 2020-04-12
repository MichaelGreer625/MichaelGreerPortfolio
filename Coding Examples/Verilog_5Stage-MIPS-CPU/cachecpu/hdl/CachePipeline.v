
module cacheBlockPipe(
input clk, rst,
input CacheEnable,
input [15:0] DataIn,
input write,
input [15:0] MemAddress,
output [15:0] DataOutMainModule,
output StallPipeline,
output validReq,
output hitOut 
);
//these wires need to be declaired here for the compiler, but will be commented out below.
wire [15:0] RequestingMemAddress;
wire [15:0] MemorysOutputtingData;
wire WriteTagFromController, WriteDataFromController;
wire EnableTheRead;

wire [1:0] FSMState;
//At first we will not have a stall, so we will access the cache blocks in parallel with the logic
//that is checking if we need to stall the pipeline. If we need to stall the pipeline we will recieve
//the stall and switch over to the memory address that is coming out of the controller at the 
//next clock cycle, with will be the start of the interating through the 8 2 byte chunks.
wire [15:0] AddressToDecode;
assign AddressToDecode = (StallPipeline) ? RequestingMemAddress : MemAddress;

        wire idleOut;

	wire [15:0] SavedAddress, SavedAddress1, SavedAddress2, SavedAddress3 ,AddressToUse;
	reg_address reginst(.clk(clk), .rst(rst), .wen(1), .in(RequestingMemAddress), .out(SavedAddress));
	reg_address reginst1(.clk(clk), .rst(rst), .wen(1), .in(SavedAddress), .out(SavedAddress1));
	reg_address reginst2(.clk(clk), .rst(rst), .wen(1), .in(SavedAddress1), .out(SavedAddress2));
	reg_address reginst3(.clk(clk), .rst(rst), .wen(1), .in(SavedAddress2), .out(SavedAddress3));


	assign AddressToUse = ((FSMState == 2'b10) | (FSMState == 2'b01)) ? SavedAddress3 : MemAddress;


//---------------DECODER FOR INDEXING CACHE BLOCKS BELOW---------------------------------
	//the block index bits from the address line will go into to decoder to one hot an output 0-127, this chooses the block in the dataArrays.
	wire [127:0] TheBlockEnable;
	decoder128 theDecoder(
	//input below
		.binary_in(AddressToUse[10:4]), 
	//output below
		.decoder_out(TheBlockEnable)
	);
//---------------DECODER FOR INDEXING BYTES WITHIN CACHE BLOCKS BELOW---------------------------------
	//the block index bits from the address line will go into to decoder to one hot an output 0-127, this chooses the block in the dataArrays.
	wire [7:0] TheWordEnable;
	decoder8 theDecoder2(
	//input below
		.binary_in(AddressToUse[3:1]), 
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
        assign hitOut = CacheEnable & idleOut & ~CacheMiss;
        assign validReq = CacheEnable & idleOut;
//---------------MAIN MEMORY BELOW---------------------------------
	wire MemIsNowValid;
	//wire [15:0] MemorysOutputtingData;
	wire WhenToWriteToMemory;
	wire WhenToEnable;
	assign WhenToWriteToMemory = StallPipeline ? 0 : write;
	assign WhenToEnable = StallPipeline ? EnableTheRead : write;


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
		.enable(WhenToEnable)
	);
//---------------CACHE CONTROLLER BELOW---------------------------------
	//wire WriteTagFromController, WriteDataFromController;
	//wire [15:0] RequestingMemAddress;
	//wire EnableTheRead;
	
	cacheControler TheController(
	//inputs below
		.clk(clk), 
		.rst_n(rst),
                .CacheEnable(CacheEnable),
		.miss_detected(CacheMiss),
		.miss_address(MemAddress),
								//	input  [16:0] .memory_data(),
		.memory_data_valid(MemIsNowValid),
	//outputs below
		.fsm_busy(StallPipeline),
		.write_data_array(WriteDataFromController),
		.write_tag_array(WriteTagFromController),
		.memory_address(RequestingMemAddress),
                .idleOut(idleOut),
		.EnableRead(EnableTheRead),
		.TheState(FSMState)
	);

endmodule





module cacheControler(
	input clk, rst_n,
        input CacheEnable,
	input miss_detected,
	input [15:0] miss_address,
	//input  [15:0] memory_data,
	input memory_data_valid,
	output reg fsm_busy,
	output reg write_data_array,
	output reg write_tag_array,
	output reg EnableRead,
        output reg idleOut,
	output reg [15:0] memory_address,
	output [1:0] TheState
	);
	
	localparam IDLE = 2'b00; 
	localparam WAIT = 2'b01;
	localparam FINISH = 2'b10;

	reg [1:0] nextstate;// is the state going into the state flip flop
	wire [1:0] state;//is the state coming out of the state flip flop
	

	//this is the counter for memory concatnation.
	reg [2:0] toadd; //is the output of the 3bit adder and the input to the 3bit flipflop memory
	wire [2:0] toaddout;//is the output of the 3bit flip flop memory and the input to A of the adder
	reg addone; // this is the input B of the adder, is either 1 or 0 designating an iterate of one or not.
	wire [2:0] adderout;
 
	//this is for counting how many blocks we have recieved.
	reg [2:0] toadd2; //is the output of the 3bit adder and the input to the 3bit flipflop memory
	wire [2:0] toaddout2;//is the output of the 3bit flip flop memory and the input to A of the adder
	reg addone2; // this is the input B of the adder, is either 1 or 0 designating an iterate of one or not.
	wire [2:0] adderout2;


	wire gotofinish;//the finished calculation is as fallows. If the toaddout(output of the adder) is all ones
			//then bitwise anding it with itself will produce a 1. this signifies the last memory access
			//and then we must wait for the last memory_data_valid to assert and then we know we are FINISHED.
	wire finished; // this wire says that we have recieved 8 blocks.

	assign TheState = state;
	
	dff state_t(.q(state[0]), .d(nextstate[0]), .wen(1'b1), .clk(clk), .rst(rst_n)); //This is the state flip flop.
	dff state_t2(.q(state[1]), .d(nextstate[1]), .wen(1'b1), .clk(clk), .rst(rst_n));
	
	//3bit counter var that is added to the end of the memory address section memaddress[15:3] 
	//this iterates through all the memory in the cache block. 
	dff counter1(.q(toaddout[0]), .d(toadd[0]), .wen(1'b1), .clk(clk), .rst(rst_n));
	dff counter2(.q(toaddout[1]), .d(toadd[1]), .wen(1'b1), .clk(clk), .rst(rst_n));
	dff counter3(.q(toaddout[2]), .d(toadd[2]), .wen(1'b1), .clk(clk), .rst(rst_n));
	
	//below is a counter to count how many blocks we have recieved.
	dff counter11(.q(toaddout2[0]), .d(toadd2[0]), .wen(1'b1), .clk(clk), .rst(rst_n));
	dff counter22(.q(toaddout2[1]), .d(toadd2[1]), .wen(1'b1), .clk(clk), .rst(rst_n));
	dff counter33(.q(toaddout2[2]), .d(toadd2[2]), .wen(1'b1), .clk(clk), .rst(rst_n));



	//Below is a simple 3 bit adder. Ripple carry. This is for the memory concatnation
	rippleadder3bit inst(.Sum(adderout), .Cout(Cout), .A(toaddout) ,.B({2'b00, addone}) ,.Cin(1'b0));

	//Below is a simple 3 bit adder. Ripple carry. this is for block addition
	rippleadder3bit inst2(.Sum(adderout2), .Cout(Cout2), .A(toaddout2) ,.B({2'b00, addone2}) ,.Cin(1'b0));
	
	assign gotofinish = ((toadd == 3'b111)&memory_data_valid);  //3'b000 because we want the 3'b111 to go through, and then the value will roll over to 3'b000
	assign finished = ((toadd2 == 3'b111)&memory_data_valid);
	
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
	reg StartBitIn;
	wire StartBitOut, StartBitIn2;
	assign StartBitIn2 = StartBitIn;
	dff startbit(.q(StartBitOut), .d(StartBitIn2), .wen(1'b1), .clk(clk), .rst(rst_n));
	always @(*) begin 
	
		case(state)
			IDLE: begin
				EnableRead = 0;
				memory_address = {miss_address[15:4], 3'b000, 1'b0};

				fsm_busy = (miss_detected & CacheEnable) ? 1 : 0;
				nextstate = (miss_detected & CacheEnable) ? WAIT : IDLE;

                                idleOut = 1'b1; 

				write_data_array = 0;
				write_tag_array = 0;
				toadd = 0;
				toadd2 = 3'b111;
				addone = 0;
				addone2 = 0;
				StartBitIn = 1;
			end
			WAIT: begin
				StartBitIn = 0;
				toadd = adderout; //this could be brought out of FSM
				toadd2 = adderout2;
				//do below if all done with all memory access. Check what finished is above.
				fsm_busy = 1;
				nextstate = gotofinish ? FINISH : WAIT;
				write_tag_array = 0;
				//below is what we do when waiting for and recieving the memory_data_valid.
				memory_address = {miss_address[15:4], toadd[2:0], 1'b0};
				EnableRead = 1;
				write_data_array = (memory_data_valid) ? 1 : 0;

                                idleOut = 1'b0;

				addone = (StartBitOut) ? 0 : 1;
				addone2 = (memory_data_valid) ? 1 : 0;
			end
			FINISH: begin
				toadd = adderout; //this could be brought out of FSM
				addone = 0;
				fsm_busy = 1;
				toadd2 = adderout2;
				memory_address = {miss_address[15:4], toadd2[2:0], 1'b0};
				addone2 = (memory_data_valid) ? 1 : 0;
				nextstate = finished ? IDLE : FINISH;
				write_tag_array = finished ? 1 : 0;
				EnableRead = 0;
				write_data_array = (memory_data_valid) ? 1 : 0;
                                idleOut = 1'b0;

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
            $readmemh("test1.img", mem);
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
                         

	

module decoder128 (
input [6:0] binary_in   , //  7 bit binary input
output [127:0]decoder_out //  128-bit out 
//enable        //  Enable for the decoder
);

        

	assign decoder_out = (1 << binary_in);

endmodule

module decoder8 (
input [2:0] binary_in   , //  3 bit binary input
output [7:0]decoder_out //  8-bit out 
//enable        //  Enable for the decoder
);

        

	assign decoder_out = (1 << binary_in);

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

 module rippleadder3bit(
    output [2:0] Sum,
    output Cout,
    input [2:0] A,B,
    input Cin
    );
 wire c1,c2;
 full_adder FA1(Sum[0],c1,A[0],B[0],Cin),
    FA2(Sum[1],c2,A[1],B[1],c1),
    FA3(Sum[2],Cout,A[2],B[2],c2);

endmodule


module full_adder(
    output S,Cout,
    input A,B,Cin
    );
 wire s1,c1,c2;
 half_adder HA1(s1,c1,A,B);
 half_adder HA2(S,c2,s1,Cin);
 or OG1(Cout,c1,c2);

endmodule

module half_adder(
  output S,C,
  input A,B
);
 xor(S,A,B);
 and(C,A,B);
 
endmodule
