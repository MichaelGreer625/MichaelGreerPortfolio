module QuadCopter_tb();
			
//// Interconnects to DUT/support defined as type wire /////
wire SS_n,SCLK,MOSI,MISO,INT;
wire SS_A2D_n,SCLK_A2D,MOSI_A2D,MISO_A2D;
wire RX,TX;
wire [7:0] resp;				// response from DUT
wire cmd_sent,resp_rdy;
wire frnt_ESC, back_ESC, left_ESC, rght_ESC;

////// Stimulus is declared as type reg ///////
reg clk, RST_n;
reg [7:0] cmd_to_copter;		// command to Copter via wireless link
reg [15:0] data;				// data associated with command
reg send_cmd;					// asserted to initiate sending of command (to your CommMaster)
reg clr_resp_rdy;				// asserted to knock down resp_rdy

/////// declare any localparams here /////


////////////////////////////////////////////////////////////////
// Instantiate Physical Model of Copter with Inertial sensor //
//////////////////////////////////////////////////////////////	
CycloneIV iQuad(.SS_n(SS_n),.SCLK(SCLK),.MISO(MISO),.MOSI(MOSI),.INT(INT),
                .frnt_ESC(frnt_ESC),.back_ESC(back_ESC),.left_ESC(left_ESC),
				.rght_ESC(rght_ESC));				  

///////////////////////////////////////////////////
// Instantiate Model of A2D for battery voltage //
/////////////////////////////////////////////////
ADC128S iA2D(.clk(clk),.rst_n(RST_n),.SS_n(SS_A2D_n),.SCLK(SCLK_A2D),
             .MISO(MISO_A2D),.MOSI(MOSI_A2D));			
	 
////// Instantiate DUT ////////
QuadCopter iDUT(.clk(clk),.RST_n(RST_n),.SS_n(SS_n),.SCLK(SCLK),.MOSI(MOSI),.MISO(MISO),
                .INT(INT),.RX(RX),.TX(TX),.LED(),.FRNT(frnt_ESC),.BCK(back_ESC),
				.LFT(left_ESC),.RGHT(rght_ESC),.SS_A2D_n(SS_A2D_n),.SCLK_A2D(SCLK_A2D),
				.MOSI_A2D(MOSI_A2D),.MISO_A2D(MISO_A2D));


//// Instantiate Master UART (used to send commands to Copter) //////
CommMaster iMSTR(.clk(clk), .rst_n(RST_n), .RX(TX), .TX(RX),
                 .cmd(cmd_to_copter), .data(data), .send_cmd(send_cmd),
			     .cmd_sent(cmd_sent), .resp_rdy(resp_rdy),
				 .resp(resp), .clr_resp_rdy(clr_resp_rdy));

initial begin
// THIS TESTS THE ABILITY TO SEND A COMMAND (TESTS FULL BATTERY COMMAND)
Initialize();
SendCmd(16'h0101, 8'h01);
@(posedge iDUT.cmd_rdy) // once command is into the DUT
$display("command sent");
if (iDUT.cmd == 8'h01 && iDUT.data == 16'h0101) // check command is correct
$display("Transmission correctly recieved.");
// now command gets processed, check it finishes
@(posedge iDUT.cnv_cmplt) // same time as send_resp
//$display("conversion completed, battery level: %h", iDUT.resp);
// can manually see what the conversion answer was
// now look at when commMaster gets response.
@(posedge iDUT.iUART.snd_resp) // response starts sending
@(posedge clk) $display("conversion completed, battery level: %h", iDUT.resp);
@(posedge resp_rdy) // response is recieved (same as iMSTR.UART.rx_rdy)
// @(posedge iDUT.iUART.resp_sent) origin of below signal..?
@(posedge iDUT.resp_sent) // response has finished sending (wouldn't have to wait all this long)
$display("response sent");
// make sure response was sent properly
$display("response: %h", resp); // check response is same as above 
// check clearing response
clr_resp_rdy = 1;
@(posedge clk)
clr_resp_rdy = 0;
@(posedge clk)
if (resp_rdy != 1)
$display("response has been used and cleared.");
$display("Command Complete.");
$stop();
end

always
  #10 clk = ~clk;

task Initialize;
clr_resp_rdy = 0;
clk = 1;
RST_n = 0;
@(posedge clk)
@(posedge clk)
RST_n = 1;
@(posedge clk);
$display("Initialized");
endtask

task SendCmd;
input [15:0] data_input;
input [7:0] cmd_input;
cmd_to_copter = cmd_input;
data = data_input;
@(negedge clk)
send_cmd = 1'h1;
@(negedge clk)
send_cmd = 1'h0;
endtask

endmodule	
