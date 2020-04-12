module QuadCopter_tb2();
			
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
//localparam MOTOR_MIN_CAL_SPD = 

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
// TESTS MOTORS OFF AND CALIBRATE COMMANDS
Initialize();
// test motors off
SendCmd(16'h0420, 8'h08);
CheckMotorsOff();
CheckResponse();
SendCmd(16'hF0F0, 8'h06);
CheckCalibrate();
CheckResponse();
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
endtask

task CheckMotorsOff;
// once Motors Off command is in, we should see motors_off held until calibrate command
@(posedge clk)
if (iDUT.motors_off == 1)
$display("Motors OFF");
else
$display("Motors not OFF'ed (Check results)");
//@(negedge iDUT.motors_off) // so when motors_off is deasserted.. (CALIBRATE should be going)
endtask

task CheckCalibrate;
@(negedge iDUT.motors_off) // turn motors on, then wait 1.34 seconds, then..
// assume wait works (internal to cmd_cfg, should be fine)
@(posedge iDUT.strt_cal)
@(posedge clk) @(posedge clk)
if (iDUT.inertial_cal != 1)
$display("inertial_cal not held during entire calibration (Check results)");
@(posedge iDUT.cal_done)
@(posedge iDUT.cal_done) // repeated due to glitching
@(posedge clk) @(posedge clk)
if (iDUT.inertial_cal != 0)
$display("inertial_cal not dropped after calibration (Check results)");
$display("intertial_cal testing complete");
endtask

task CheckResponse;
@(posedge resp_rdy)
$display("response: %h", resp);
endtask

endmodule	
