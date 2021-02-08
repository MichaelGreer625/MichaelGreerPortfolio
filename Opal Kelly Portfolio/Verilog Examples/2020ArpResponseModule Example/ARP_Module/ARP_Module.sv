/**********************************************************************;
* Project           : Coding Project for a ARP response module.
*
* Program name      : ARP_Module.v
*
* Author            : Michael Greer (mgreer625@gmail.com)
*
* Date created      : 04/14/2020
*
* Purpose           : ARP responce block.
*
*
* Revision History  :
*
* Date        Author      Ref    Revision 
* 04/14/2020    MGreer      1    Created. 
*
|**********************************************************************/


module ARP_Module(
input		CLK,
input 		ARESET,
input [47:0] 	MY_MAC,
input [31:0] 	MY_IPV4,
input 		CLK_RX,
input 		DATA_VALID_RX,
input [7:0] 	DATA_RX,
input 		CLK_TX, 

output logic 	DATA_VALID_TX,
output [7:0] 	DATA_TX,
input  logic	DATA_ACK_TX
);
//-------------------------------------------------------------------------------
//--------------------------Declarations of variables----------------------------
//-------------------------------------------------------------------------------
//These REGs are to remember the old values of inputs to impliment edge detectors
reg old_place;
reg old_remove;

wire positive_edge_place;
wire negative_edge_remove;


//---------These are the byte arrays for the byte shift registers---
reg [7:0] rx_byte_shift_array [0:41];
reg [7:0] tx_byte_shift_array [0:41];

//---------This is the array of byte arrays for the FIFO-----------------
reg [7:0] transmit_fifo [0:41][0:7];

//----------------These are the regs for the counters--------------------
integer counter_41;
integer counter_8;

wire counted_41;
wire data_in_fifo;

//This is the wire asserted when there is a match or request
wire match;
wire request;

//------------------Outputs of the state machine---------------------
logic dropped;
logic place;
logic remove;
logic shift_tx_array;
logic shift_rx_array;
logic reset_41_counter;
logic increment_41;
logic load;

//-------------------------------------------------------------------------------
//--------------------------Assorted Hardware -----------------------------------
//-------------------------------------------------------------------------------


//--------------------These are the pos edge detectors---------------------

always @(posedge CLK) begin
	old_place <= place;
	old_remove <= remove;
end
assign positive_edge_place = ~old_place & place;
assign negative_edge_remove = old_remove & ~remove;





//-----------------------These are the two counters---------------------

always @(posedge CLK_TX or posedge ARESET) begin
	if(ARESET)
		counter_41 <= 0;
	else if(reset_41_counter)
		counter_41 <= 0;
	else if(increment_41)
		counter_41 <= counter_41 + 1;

end
assign counted_41 = counter_41 >= 41;

always @(posedge CLK or posedge ARESET) begin
	if(ARESET)
		counter_8 <= 0;
	else if(counter_8 >= 8)
		counter_8 = counter_8;
	else if(positive_edge_place & negative_edge_remove)
		counter_8 <= counter_8;
	else if(positive_edge_place)
		counter_8 <= counter_8 + 1;
	else if(negative_edge_remove)
		counter_8 <= counter_8 - 1;

end
assign data_in_fifo = counter_8 > 0;



//--------------------Do the matching combinational logic------------------------------

assign match = MY_IPV4 == {rx_byte_shift_array[38], rx_byte_shift_array[39], rx_byte_shift_array[40], 
			    rx_byte_shift_array[41]};

assign request = {rx_byte_shift_array[20], rx_byte_shift_array[21]} == 1;






//--------------------This is the byte array shift register.-----------------------------------


always @(posedge CLK_RX or posedge ARESET)begin
	if(ARESET)
		for(integer i = 0; i < 42; i = i + 1) begin
			rx_byte_shift_array[i] <= 0;
		end
	else if(shift_rx_array)begin
		for(integer i = 0; i < 41; i = i + 1) begin
			rx_byte_shift_array[i] <= rx_byte_shift_array[i + 1];
		end
		rx_byte_shift_array[41] <= DATA_RX;
	end 
end

always @(posedge CLK_TX or posedge ARESET)begin
	if(ARESET)
		for(integer i = 0; i < 42; i = i + 1) begin
			tx_byte_shift_array[i] <= 0;
		end
	else if(load) begin
		for(integer i = 0; i < 42; i = i + 1)begin
			tx_byte_shift_array[i] <= transmit_fifo[i][0];
		end
	end else if(shift_tx_array)begin
		for(integer i = 0; i < 41; i = i + 1)begin
			tx_byte_shift_array[i] <= tx_byte_shift_array[i + 1];
		end
		tx_byte_shift_array[41] = 0;
	end

end
assign DATA_TX = tx_byte_shift_array[0];








//-------------------------------This is the fifo------------------------------------------

always @(posedge CLK or posedge ARESET) begin
	if(ARESET)
		for(integer i = 0; i < 8; i = i + 1)begin
			for(integer j = 0; j < 42; j = j + 1)begin
				transmit_fifo[j][i] <= 0;
			end	
		end	
	else if(positive_edge_place & negative_edge_remove)
		for(integer i = 0; i < 42; i = i + 1)begin
			transmit_fifo[i][0] <= rx_byte_shift_array[i];
		end	
	else if(positive_edge_place) begin
		for(integer i = 7; i > 0; i = i - 1)begin
			for(integer j = 0; j < 42; j = j + 1)begin
				transmit_fifo[j][i] <= transmit_fifo[j][i-1];
			end	
		end

		//Here we assemble the transmitting packet

		//Destination MAC = Source MAC from ARP payload	
		for(integer i = 0; i < 6; i = i + 1)begin
			transmit_fifo[i][0] <= rx_byte_shift_array[22 + i];
		end
		//Source MAC = MY_MAC;
		for(integer i = 6, integer j = 0; i < 12; i = i + 1, j = j + 1)begin
			transmit_fifo[i][0] <= MY_MAC[47 - (8 * j) -: 8];
		end
		//Type = 16'h0806	
		{transmit_fifo[12][0], transmit_fifo[13][0]} = 16'h0806;

		//Hardware Type = 16'h0001
		{transmit_fifo[14][0], transmit_fifo[15][0]} = 16'h0001;

		//Protocol Type = 16'h0800
		{transmit_fifo[16][0], transmit_fifo[17][0]} = 16'h0800;

		//Hardware address length = 8'h06
		transmit_fifo[18][0] = 8'h06;

		//Protocol address length = 8'h04
		transmit_fifo[19][0] = 8'h04;

		//Operation code = 16'h0002 (reply)
		{transmit_fifo[20][0], transmit_fifo[21][0]} = 16'h0002;

		//Source MAC address = MY_MAC
		for(integer i = 22, integer j = 0; i < 28; i = i + 1, j = j + 1)begin
			transmit_fifo[i][0] <= MY_MAC[47 - (8 * j) -: 8];
		end
		
		//Source protocol address = MY_IPV4
		for(integer i = 28, integer j = 0; i < 32; i = i + 1, j = j + 1)begin
			transmit_fifo[i][0] <= MY_IPV4[31 - (8 * j) -: 8];
		end

		//Target MAC address = Source MAC from ARP payload
		for(integer i = 32, integer j = 0; i < 38; i = i + 1, j = j + 1)begin
			transmit_fifo[i][0] <= rx_byte_shift_array[22 + j];
		end
		
		//Target protocol address = Source protocol from ARP payload
		for(integer i = 38, integer j = 0; i < 42; i = i + 1, j = j + 1)begin
			transmit_fifo[i][0] <= rx_byte_shift_array[28 + j];
		end
		





	end else if(negative_edge_remove) begin
		for(integer i = 0; i < 7; i = i + 1)begin
			for(integer j = 0; j < 42; j = j + 1)begin
				transmit_fifo[j][i] <= transmit_fifo[j][i+1];
			end	
		end	
		for(integer i = 0; i < 42; i = i + 1)begin
			transmit_fifo[i][7] <= 0;
		end
	end
end

//-------------------------------------------------------------------------------
//--------------------------State machines for RX and TX-------------------------
//-------------------------------------------------------------------------------


//---------------This is the state machine for Rx-----------------

typedef enum reg {IDLE_RX, RECIEVE_PACKET} STATE_RX;
STATE_RX state_rx, next_state_rx;

always @(posedge CLK_RX or posedge ARESET) begin
	if(ARESET)
		state_rx <= IDLE_RX;
	else
		state_rx <= next_state_rx;
end

always @(*)begin
next_state_rx = IDLE_RX;
shift_rx_array = 0;
place = 0;
dropped = 0;

case(state_rx)
	IDLE_RX: begin
		if(DATA_VALID_RX) begin
			next_state_rx = RECIEVE_PACKET;
			shift_rx_array = 1;
			
		end
	end 
	RECIEVE_PACKET: begin
		if(~DATA_VALID_RX) begin
			next_state_rx = IDLE_RX;
			if(match & request) begin
				place = 1;
			end else
				dropped = 1;
		end else begin
			next_state_rx = RECIEVE_PACKET;
			shift_rx_array = 1;
		end
	end
endcase
end












//----------------------This is the state machine for TX-----------------------
typedef enum reg [2:0] {IDLE_TX, WAIT_ACK, SEND_RESPONSE} STATE_TX;
STATE_TX state_tx, next_state_tx;

always @(posedge CLK_TX or posedge ARESET) begin
	if(ARESET)
		state_tx <= IDLE_TX;
	else
		state_tx <= next_state_tx;

end

always @(*) begin
next_state_tx = IDLE_TX;
remove = 0;
load = 0;
shift_tx_array = 0;
reset_41_counter = 0;
increment_41 = 0;
DATA_VALID_TX = 0;

case(state_tx)
	IDLE_TX: begin
		if(data_in_fifo) begin
			next_state_tx = WAIT_ACK;
			load = 1;
			remove = 1;
		end
	end
	
	WAIT_ACK: begin
		if(DATA_ACK_TX) begin
			next_state_tx = SEND_RESPONSE;
			shift_tx_array = 1;
			reset_41_counter = 1;
			DATA_VALID_TX = 1;
		end else
			next_state_tx = WAIT_ACK;
			DATA_VALID_TX = 1;
	end
	
	SEND_RESPONSE: begin
		if(counted_41) begin
			next_state_tx = IDLE_TX;
		end else begin
			next_state_tx = SEND_RESPONSE;
			increment_41 = 1;
			shift_tx_array = 1;
			DATA_VALID_TX = 1;
		end
	end
endcase

end


endmodule 