/**********************************************************************;
* Project           : Coding Project for a ARP response module.
*
* Program name      : ARP_Module_tb.v
*
* Author            : Michael Greer (mgreer625@gmail.com)
*
* Date created      : 04/16/2020
*
* Purpose           : Test bench to test ARP responce block.
*
*
* Revision History  :
*
* Date        Author      Ref    Revision 
* 04/16/2020    MGreer      1    Created. 
*
|**********************************************************************/


`timescale 1ns / 1ns

module ARP_Module_tb;



reg [47:0] 	MY_MAC_TB; //Lets declare the test bench a MAC and IP address
reg [31:0] 	MY_IPV4_TB;//Lets declare the test bench a MAC and IP address



//-----------------------------------------------------------
//----Declare the inputs and outputs to DUT(ARP_module)-------
//-----------------------------------------------------------

//Inputs:
reg		CLK;
reg 		CLK_RX;
reg 		CLK_TX;
reg 		ARESET;

reg [47:0] 	MY_MAC; //DUT MAC Address
reg [31:0] 	MY_IPV4; // DUT IP Address

reg 		DATA_VALID_RX;
reg [7:0] 	DATA_RX;
reg  		DATA_ACK_TX;


//Outputs:
wire 	 	DATA_VALID_TX;
wire [7:0] 	DATA_TX;






//-----------------------------------------------------------
//Create the inputs and outputs of the state machine that 
//transmits the data to the DUT. Also declare associated 
//hardware the state machine controls.
//-----------------------------------------------------------

//Inputs:
reg start;

//Outputs:
reg shift_tx_array;
reg reset_41_counter;
reg increment_41;
reg done_transmitting; 
reg data_valid_tx;

//Assosiated hardware declarations:
integer counter_41;//Counter
wire counted_41;//Counter Check
reg [7:0] tx_byte_shift_array [0:41];//Shift register






//-----------------------------------------------------------
//Create the inputs and outputs of the state machine that 
//recieves the data from the DUT. Also declare associated 
//hardware the state machine controls.
//-----------------------------------------------------------

//Inputs:
//reg DATA_VALID_TX;  Already declared as ouput of DUT
reg enable_recieve_from_dut;

//Outputs:
reg shift_rx_array;
//reg DATA_ACK_TX;   Already delared as input to DUT
reg done_recieving;

//Assosiated hardware declarations:
reg [7:0] rx_byte_shift_array [0:41]; // Shift register






//----------------------------------------------------
//----------------Instatiate the DUT------------------
//----------------------------------------------------
ARP_Module DUT(
		.CLK(CLK),//
		.CLK_TX(CLK_TX),// 
		.CLK_RX(CLK_RX),//
		.ARESET(ARESET),//
		.MY_MAC(MY_MAC),//
		.MY_IPV4(MY_IPV4),//

		.DATA_VALID_RX(DATA_VALID_RX),
		.DATA_RX(DATA_RX),


		.DATA_VALID_TX(DATA_VALID_TX),
		.DATA_TX(DATA_TX),
		.DATA_ACK_TX(DATA_ACK_TX)
		);


//----------------------------------------------------------
//---------------Create the three clocks--------------------
//----------------------------------------------------------
always #2 CLK = ~CLK; 
always #10 CLK_RX = ~CLK_RX; 
always #10 CLK_TX = ~CLK_TX;



//This is to count how many items are in the fifo.
integer fifo_count_expected_in_device;



//----------------------------------------------------------
//----------------Begin the test----------------------------
//----------------------------------------------------------
localparam REQUEST = 1;
localparam REPLY = 2;

initial begin
CLK = 0;
CLK_RX = 0;
CLK_TX = 0;
enable_recieve_from_dut = 1;
fifo_count_expected_in_device = 0;

ARESET = 0;

MY_MAC = 48'h000223010203;
MY_IPV4 = 32'hc0a80102;

MY_MAC_TB = 48'h000142005f68;
MY_IPV4_TB = 32'hc0a80101;

#10
ARESET = 1;
#10
ARESET = 0;



//Lets disable the recieve funtion from the DUT to 
//fill up our fifo on our DUT
@(posedge CLK_TX)
enable_recieve_from_dut = 0;
@(posedge CLK_TX)

send_and_check_arp_request(MY_IPV4,REQUEST);
send_and_check_arp_request(MY_IPV4,REQUEST);
send_and_check_arp_request(MY_IPV4,REPLY);//This is an example of the wrong op code
send_and_check_arp_request(32'hdddddddd,REQUEST);//This is an example of wrong target IP
send_and_check_arp_request(MY_IPV4,REQUEST);



//NOTE THAT THE NUMBER OF ITEMS IN THE DEVICE IS EQUAL TO 
//THE NUMBER OF ITEMS IN THE FIFO PLUS THE ITEM IN THE SHIFT 
//REGISTER: FIFO(X) + SHIFTREG(1). 
//EXAMPLE:IF YOU CALL THREE PACKETS THAT GET BACKED UP IN THE DEVICE
//THEN TWO ARE IN THE FIFO AND ONE IS IN THE SHIFT REGISTER.

//fifo_count_expected_in_device is artificially created value
//DUT.counter_8 is equal to the count in the fifo
//Minus one because one of the items is in the shift register.
if(DUT.counter_8 == fifo_count_expected_in_device - 1)
	$display("Correct number of items in fifo: \nActual:%d  \nExpected:%d", DUT.counter_8, fifo_count_expected_in_device - 1);
else
	$display("There is not the correct amout of items in the fifo: \nActual:%d  \nExpected:%d", DUT.counter_8, fifo_count_expected_in_device - 1);

//Now we are going to release a packet from the fifo

release_packet;
release_packet;
release_packet;


//Now lets enable the reciever from the testbench so that
//we are recieving packets as fast as we can, there will 
//be no packets that enter the fifo
@(posedge CLK_TX)
enable_recieve_from_dut = 1;

send_and_check_arp_request(MY_IPV4,REQUEST);
@(posedge done_recieving)

send_and_check_arp_request(MY_IPV4,REQUEST);
@(posedge done_recieving)

send_and_check_arp_request(MY_IPV4,REQUEST);
@(posedge done_recieving);


$stop;

end


//----------------------------------------------------------
//This always block will moniter whenever a packet is done 
//recieving from the DUT. It will display the packets source
//IP and MAC address and it will also display the contents of 
//the packet as well as display a check on the number of remaining
//items in the fifo in the DUT compared with the expected number of 
//items left in the fifo.
//----------------------------------------------------------

always begin
@(posedge done_recieving)
$display("Recieved packet from: \n\tIP: %d.%d.%d.%d\n\tMAC: %d.%d.%d.%d.%d.%d",
	rx_byte_shift_array[28],rx_byte_shift_array[29],rx_byte_shift_array[30],
	rx_byte_shift_array[31],rx_byte_shift_array[22],rx_byte_shift_array[23],
	rx_byte_shift_array[24],rx_byte_shift_array[25],rx_byte_shift_array[26],
	rx_byte_shift_array[27]);

$display("The contents of the packet are:");
  foreach(rx_byte_shift_array[i])
	if(i == 16 || i == 32)
		$write("\n%h ",rx_byte_shift_array[i]);  
	else
		$write("%h ",rx_byte_shift_array[i]); 
$write("\n");

//Not minus one because this is one clock cycle before the first
//item of the fifo gets loaded into the shift register and removed
//from the fifo. So right now there is no packet in the shift register
if(DUT.counter_8 == fifo_count_expected_in_device)
	$display("**Correct number** of items in fifo: \nActual:%d  \nExpected:%d", DUT.counter_8, fifo_count_expected_in_device);
else
	$display("There is **NOT** the correct amout of items in the fifo: \nActual:%d  \nExpected:%d", DUT.counter_8, fifo_count_expected_in_device);


end



//-----------------------------------------------------------------------
//Purpose: Releases one of the packets that are backed up in the fifo
//	   by enabling the meley state machine trasition to assert the
//	   acknoledge wire in the recieve state machine in the testbench. 
//         Acknowledging starts the state machine in the DUT
//
//------------------------------------------------------------------------

task release_packet;
begin

//This is to keep count of our expected fifo count.


fifo_count_expected_in_device = fifo_count_expected_in_device - 1;


$display("*******RELEASING A PACKET FROM THE FIFO**********");
@(posedge CLK_TX)
enable_recieve_from_dut = 1;
@(posedge CLK_TX)
enable_recieve_from_dut = 0;
@(posedge done_recieving)
@(posedge CLK_TX);

end

endtask








//-----------------------------------------------------------------------
//Purpose: Send an ARP request to the target IP address. It checks 
//	   from within the DUT to see if the packet was picked up
//         or if it was dropped.
//
//Inputs: 
//	input [31:0] target_ip;  Target Ip Address of the request.
//------------------------------------------------------------------------
task send_and_check_arp_request;
input [31:0] target_ip;
input [15:0] op_code;

begin

//From the input, if everything adds up to it being place in the fifo 
//then increment an expected fifo count
if((op_code == REQUEST) && (target_ip == MY_IPV4))
	if(enable_recieve_from_dut == 0) //if recieve from DUT enabled then increment expected count
		fifo_count_expected_in_device = fifo_count_expected_in_device + 1;



@(posedge CLK_RX)
load_transmit_shift_reg_for_request(target_ip, op_code);
start = 1; //This is an input to the transmit state machine

@(posedge CLK_RX)
start = 0;

@(posedge DUT.place or posedge DUT.dropped)
if(DUT.place) begin
	$display("PACKET WAS PICKED UP");
end else if(DUT.request)
	$display("Packet was dropped because target IP did not match.");
else 
	$display("Packet was dropped because it was not an ARP request");


@(posedge CLK_RX);

end


endtask 




//-----------------------------------------------------------------------
//Purpose: Task to load the test bench transmitting shift register with
// 	   a request from the test bench MAC and IP to the target IP
//
//Inputs: 
//	input [31:0] target_ip;  Target Ip Address of the request.
//------------------------------------------------------------------------
task load_transmit_shift_reg_for_request;
input [31:0] target_ip;
input [15:0] op_code;

begin
		//Destination MAC = Source MAC from ARP payload	
		for(integer i = 0; i < 6; i = i + 1)begin
			tx_byte_shift_array[i] = 8'hff;
		end
		//Source MAC = MY_MAC;
		for(integer i = 6, integer j = 0; i < 12; i = i + 1, j = j + 1)begin
			tx_byte_shift_array[i] = MY_MAC_TB[47 - (8 * j) -: 8];
		end
		//Type = 16'h0806	
		{tx_byte_shift_array[12], tx_byte_shift_array[13]} = 16'h0806;

		//Hardware Type = 16'h0001
		{tx_byte_shift_array[14], tx_byte_shift_array[15]} = 16'h0001;

		//Protocol Type = 16'h0800
		{tx_byte_shift_array[16], tx_byte_shift_array[17]} = 16'h0800;

		//Hardware address length = 8'h06
		tx_byte_shift_array[18] = 8'h06;

		//Protocol address length = 8'h04
		tx_byte_shift_array[19] = 8'h04;

		//Operation code = 16'h0002 (request)
		{tx_byte_shift_array[20], tx_byte_shift_array[21]} = op_code;

		//Source MAC address = MY_MAC
		for(integer i = 22, integer j = 0; i < 28; i = i + 1, j = j + 1)begin
			tx_byte_shift_array[i] = MY_MAC_TB[47 - (8 * j) -: 8];
		end
		
		//Source protocol address = MY_IPV4
		for(integer i = 28, integer j = 0; i < 32; i = i + 1, j = j + 1)begin
			tx_byte_shift_array[i] = MY_IPV4_TB[31 - (8 * j) -: 8];
		end

		//Target MAC address = Source MAC from ARP payload
		for(integer i = 32, integer j = 0; i < 38; i = i + 1, j = j + 1)begin
			tx_byte_shift_array[i] = 8'b00;
		end
		
		//Target protocol address = Source protocol from ARP payload
		for(integer i = 38, integer j = 0; i < 42; i = i + 1, j = j + 1)begin
			tx_byte_shift_array[i] = target_ip[31 - (8 * j) -: 8];
		end




end
endtask








//-----------------------------------------------------------------------------
//------------THIS IS A HARDWARE TO *****RECIEVE*** THE DATA BYTES------------
//-----------------------------------------------------------------------------

//----------------Shift register------------------------------
always @(posedge CLK_TX or posedge ARESET)begin
	if(ARESET)
		for(integer i = 0; i < 42; i = i + 1) begin
			rx_byte_shift_array[i] <= 0;
		end
	else if(shift_rx_array)begin
		for(integer i = 0; i < 41; i = i + 1) begin
			rx_byte_shift_array[i] <= rx_byte_shift_array[i + 1];
		end
		rx_byte_shift_array[41] <= DATA_TX;
	end 
end

//---------------State machine-------------------------
typedef enum reg {IDLE_RX, RECIEVE_PACKET} STATE_RX;
STATE_RX state_rx, next_state_rx;

always @(posedge CLK_TX or posedge ARESET) begin
	if(ARESET)
		state_rx <= IDLE_RX;
	else
		state_rx <= next_state_rx;
end

always @(*)begin
next_state_rx = IDLE_RX;
shift_rx_array = 0;
DATA_ACK_TX = 0;
done_recieving = 0;

case(state_rx)
	IDLE_RX: begin
		if(DATA_VALID_TX & enable_recieve_from_dut) begin
			next_state_rx = RECIEVE_PACKET;
			shift_rx_array = 1;
			DATA_ACK_TX = 1;
			
		end
	end 
	RECIEVE_PACKET: begin
		if(~DATA_VALID_TX) begin
			next_state_rx = IDLE_RX;
			done_recieving = 1;
		end else begin
			next_state_rx = RECIEVE_PACKET;
			shift_rx_array = 1;
		end
	end
endcase
end








//-----------------------------------------------------------------------------
//------------THIS IS HARDWARE TO *****TRANSMIT*** THE DATA BYTES------------
//-----------------------------------------------------------------------------


//--------------------Counter--------------------------
always @(posedge CLK_RX or posedge ARESET) begin
	if(ARESET)
		counter_41 <= 0;
	else if(reset_41_counter)
		counter_41 <= 0;
	else if(increment_41)
		counter_41 <= counter_41 + 1;

end
assign counted_41 = counter_41 >= 41;


//-----------------Shift Register------------------------
always @(posedge CLK_RX or posedge ARESET)begin
	if(ARESET)
		for(integer i = 0; i < 42; i = i + 1) begin
			tx_byte_shift_array[i] <= 0;
		end
	else if(shift_tx_array)begin
		for(integer i = 0; i < 41; i = i + 1) begin
			tx_byte_shift_array[i] <= tx_byte_shift_array[i + 1];
		end
		tx_byte_shift_array[41] <= 0;
	end 
end
assign DATA_RX = tx_byte_shift_array[0];


//--------------------------State machine-------------------------------------
typedef enum reg {IDLE_TX, TRANSMIT_PACKET} STATE_TX;
STATE_TX state_tx, next_state_tx;

always @(posedge CLK_RX or posedge ARESET) begin
	if(ARESET)
		state_tx <= IDLE_TX;
	else
		state_tx <= next_state_tx;
end
assign DATA_VALID_RX = data_valid_tx;
always @(*)begin
next_state_tx = IDLE_TX;
shift_tx_array = 0;
reset_41_counter = 0;
increment_41 = 0;
data_valid_tx = 0;
done_transmitting = 0;

case(state_tx)
	IDLE_TX: begin
		if(start) begin
			next_state_tx = TRANSMIT_PACKET;
			shift_tx_array = 1;
			reset_41_counter = 1;
			data_valid_tx = 1;
			
		end
	end 
	RECIEVE_PACKET: begin
		if(counted_41) begin
			next_state_tx = IDLE_TX;
			done_transmitting = 1;
		end else begin
			next_state_tx = TRANSMIT_PACKET;
			shift_tx_array = 1;
			increment_41 = 1;
			data_valid_tx = 1;
		end
	end
endcase
end


endmodule 