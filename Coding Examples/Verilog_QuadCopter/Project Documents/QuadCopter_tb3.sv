module QuadCopter_tb3();
			
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
logic [15:0] frnt_i, back_i, left_i, right_i;

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
// TESTS SETTING PITCH, ROLL, YAW, THRUST, and EMERGENCY LAND
Initialize();
// Motors off and Calibrate
SendCmd(16'h0420, 8'h08);
SendCmd(16'hF0F0, 8'h06);
// test speeds
SendCmd(16'h0020, 8'h02); // sets PITCH as a signed 16 bit number
CheckPitch();
SendCmd(9'h04F, 8'h05); // sets THRUST as an UNsigned 9 bit number
CheckThrust();
SendCmd(16'h0040, 8'h03); // sets ROLL as a signed 16 bit number
SendCmd(16'h0060, 8'h04); // sets YAW as a signed 16 bit number
CheckSpeeds();
SendCmd(16'h0000, 8'h07);
EmergencyLand();
$display("Test Complete");
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
@(posedge iDUT.cmd_rdy) // once command is into the DUT
$display("Command: %h sent", iDUT.cmd);
if(cmd_input == 8'h05)begin
frnt_i = iDUT.frnt_spd;
back_i = iDUT.bck_spd;
left_i = iDUT.lft_spd;
right_i = iDUT.rght_spd;
end
CheckResponse();
endtask

task CheckResponse;
@(posedge resp_rdy)
$display("response: %h", resp);
endtask

task CheckPitch; // check the effect of one command
@(posedge clk) @(posedge clk)
if (iDUT.d_ptch == 16'h0fff)
$display("Desired Pitch Correct");
// wait 100 cycles and check that the actual approaches expected (within error bounds)
repeat (100) begin
@(posedge frnt_ESC); // pick any ESC to wait on
end
// check actual pitch internal to CycloneIV, with respect to desired pitch
if (iDUT.ptch > 16'h001b && iDUT.ptch < 16'h0025) // window for error
	$display("Pitch is close enough.");
endtask

task CheckSpeeds; // speeds all varying now, since all commands hit
repeat (100) begin
@(posedge frnt_ESC); // pick any ESC to wait on
end
// check actual pitch internal to CycloneIV, with respect to desired pitch
if (iDUT.ptch > 16'h0010 && iDUT.ptch < 16'h002F) // window for error
	$display("Pitch is close enough.");
if (iDUT.roll > 16'h0030 && iDUT.roll < 16'h004F) // window for error
	$display("Roll is close enough.");
if (iDUT.yaw > 16'h0050 && iDUT.yaw < 16'h006F) // window for error
	$display("Yaw is close enough.");
endtask

task EmergencyLand; // speeds should be going towards min
@(posedge clk) @(posedge clk)
if (iDUT.d_ptch == 0 && iDUT.d_roll == 0 && iDUT.d_yaw == 0 && iDUT.thrst == 0)
$display("Emergency Land desired as expected");
repeat (100) begin
@(posedge frnt_ESC); // pick any ESC to wait on
end
// check actual pitch internal to CycloneIV, with respect to desired pitch
if (iDUT.ptch > 16'hFFF0 || iDUT.ptch < 16'h000F) // window for error
	$display("Pitch is close enough.");
if (iDUT.roll > 16'hFFF0 || iDUT.roll < 16'h000F) // window for error
	$display("Roll is close enough.");
if (iDUT.yaw > 16'hFFF0 || iDUT.yaw < 16'h000F) // window for error
	$display("Yaw is close enough.");
endtask

task CheckThrust;
if (frnt_i + 9'h04F + 8 > iDUT.frnt_spd && frnt_i + 9'h04F - 8 < iDUT.frnt_spd)
	$display("Front Thrust Test Passed");
if (back_i + 9'h04F + 8 > iDUT.bck_spd && back_i + 9'h04F - 8 < iDUT.bck_spd)
	$display("Back Thrust Test Passed");
if (left_i + 9'h04F + 8 > iDUT.lft_spd && left_i + 9'h04F - 8 < iDUT.lft_spd)
	$display("Left Thrust Test Passed");
if (right_i + 9'h04F + 8 > iDUT.rght_spd && right_i + 9'h04F - 8 < iDUT.rght_spd)
	$display("Right Thrust Test Passed");
$display("Thrust test complete");
endtask
endmodule	
