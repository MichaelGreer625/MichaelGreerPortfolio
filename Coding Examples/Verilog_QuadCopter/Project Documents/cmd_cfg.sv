module cmd_cfg(clk, rst_n, cmd_rdy, cmd, data, clr_cmd_rdy, batt, cal_done, cnv_cmplt, resp, send_resp, d_ptch, d_roll, d_yaw, thrst, strt_cal, inertial_cal, motors_off, strt_cnv);

parameter WIDTH = 9; // set to 26 bits for actual

///////////////////////////////////////////////////////////////
///////////THESE ARE ALL THE STATE MACHINE INPUTS/////////////
///////////////////////////////////////////////////////////////
input logic clk, rst_n, cmd_rdy, cal_done, cnv_cmplt;
input logic[7:0] cmd, batt;
logic tmr_full;

///////////////////////////////////////////////////////////////
///////////THESE ARE ALL THE STATE MACHINE OUTPUTS/////////////
///////////////////////////////////////////////////////////////
output logic [7:0] resp;
output logic clr_cmd_rdy, send_resp, strt_cal, inertial_cal, strt_cnv;
logic clr_tmr;
logic [WIDTH - 1: 0] count;
logic wptch, wroll, wyaw, wthrst;
logic mtrs_off, en_mtrs;

///////////////////////////////////////////////////////////////
///////////OTHER ASSORTED WIRES AND REGISTERS/////////////////
///////////////////////////////////////////////////////////////
output reg [15:0] d_ptch, d_roll, d_yaw;
output reg [8:0] thrst;
input [15:0] data;
output reg motors_off;

typedef enum logic [1:0] {IDLE, WAITCONV, MOTOR, CAL} state_t;
state_t state, nextState;

//typedef enum logic [3:0] {REQ_BATT = 1, SET_PTCH = 2, SET_ROLL = 3, SET_YAW = 4, SET_THRST = 5, CALIBRATE = 6, EMER_LAND = 7, MTRS_OFF = 8} cmd_states;
//cmd_states cmd_state;

reg[3:0] REQ_BATT = 8'h01;
reg[3:0] SET_PTCH = 8'h02;
reg[3:0] SET_ROLL = 8'h03;
reg[3:0] SET_YAW = 8'h04;
reg[3:0] SET_THRST = 8'h05;
reg[3:0] CALIBRATE = 8'h06;
reg[3:0] EMER_LAND = 8'h07;
reg[3:0] MTRS_OFF = 8'h08;

///////////////////////////////////////////////////////////////
///////////BELOW INSTATIATES ASSORTED REGISTERS/////////////////
///////////////////////////////////////////////////////////////
always @(posedge clk, negedge rst_n)begin
	if(!rst_n)
		d_ptch <= 0;
	else if(wptch)
		d_ptch <= data;
end
always @(posedge clk, negedge rst_n)begin
	if(!rst_n)
		d_roll <= 0;
	else if(wroll)
		d_roll <= data;
end
always @(posedge clk, negedge rst_n)begin
	if(!rst_n)
		d_yaw <= 0;
	else if(wyaw)
		d_yaw <= data;
end
always @(posedge clk, negedge rst_n)begin
	if(!rst_n)
		thrst <= 0;
	else if(wthrst)
		thrst <= data[8:0];
end
///////////////////////////////////////////////////////////////
////BELOW IS THE COUNTER FOR CALIBRATION(1.32 SECONDS)/////////
///////////////////////////////////////////////////////////////
always @(posedge clk, negedge rst_n)begin
	if(!rst_n)
		count <= 0;
	else if(clr_tmr)
		count <= 0;
	else
		count <= count + 1;

end
///////////////////////////////////////////////////////////////
////BELOW CHECKS IF COUNT IS FULL(IF ALL BITS EQUAL 1)/////////
///////////////////////////////////////////////////////////////
assign tmr_full = &count;

///////////////////////////////////////////////////////////////////////////
////BELOW IS THE LOGIC FOR LOGIC FOR CLOUDY PARTY AND MOTORS_REGISTER//////
///NEXT TO THE STATE MACHINE IN THE CMD_CFG DIAGRAM IN PROBLEM 2 HW////////
///////////////////////////////////////////////////////////////////////////
always @(posedge clk, negedge rst_n)begin
	if(!rst_n)
		motors_off <= 1;
	else if(en_mtrs)
		motors_off <= 0;
	else if(mtrs_off)
		motors_off <= 1;

end


///////////////////////////////////////////////////////////////////////////
/////////////THIS IS THE START OF THE STATE MACHINE LOGIC /////////////////
///////////////////////////////////////////////////////////////////////////
always@(posedge clk, negedge rst_n)begin
if(!rst_n)
	state <= IDLE;
else
	state <= nextState;
end


// just need to code FSM
// IDLE, WAITCONV, MOTOR, CAL

always_comb begin
	wptch = 0;
	wroll = 0;
	wyaw = 0;
	wthrst = 0;
	send_resp = 0;
	strt_cnv = 0;
	inertial_cal = 0;
	mtrs_off = 0; // Will Calibrate always be the command immediately following a Mtrs_off?
	en_mtrs = 0;
	clr_cmd_rdy = 0;
	strt_cal = 0;
	clr_tmr = 0;
	nextState = IDLE;
	case(state)
		IDLE: begin
			if (cmd_rdy == 1) begin
				if (cmd == REQ_BATT) begin
					strt_cnv = 1;
					nextState = WAITCONV;
				end
				else if(cmd == SET_PTCH) begin
					wptch = 1;
					nextState = IDLE;
					resp = 8'hA5;
					send_resp = 1;
					clr_cmd_rdy = 1;
				end
				else if (cmd == SET_ROLL) begin
					wroll = 1;
					nextState = IDLE;
					resp = 8'hA5;
					send_resp = 1;
					clr_cmd_rdy = 1;
				end
				else if (cmd == SET_YAW) begin
					wyaw = 1;
					nextState = IDLE;
					resp = 8'hA5;
					send_resp = 1;
					clr_cmd_rdy = 1;
				end
				else if (cmd == SET_THRST) begin
					wthrst = 1;
					nextState = IDLE;
					resp = 8'hA5;
					send_resp = 1;
					clr_cmd_rdy = 1;
				end
				else if (cmd == EMER_LAND) begin
					wthrst = 1;
					wroll = 1;
					wyaw = 1;
					wptch = 1;
					nextState = IDLE;
					resp = 8'hA5;
					send_resp = 1;
					clr_cmd_rdy = 1;
				end
				else if (cmd == MTRS_OFF) begin
					mtrs_off = 1; // assert until calibrate command
					nextState = IDLE;
					resp = 8'hA5;
					send_resp = 1;
					clr_cmd_rdy = 1;
				end
				else if (cmd == CALIBRATE) begin
					nextState = MOTOR;
					clr_tmr = 1;
					en_mtrs = 1; // for only one clk?
				end
			end
			else
				nextState = IDLE;
		end
		WAITCONV: begin
			if (cnv_cmplt) begin
				nextState = IDLE;
				resp = batt;
				send_resp = 1;
				clr_cmd_rdy = 1;
			end
			else
				nextState = WAITCONV;
		end
		MOTOR: begin
			if (tmr_full) begin
				nextState = CAL;
				strt_cal = 1;
			end
			else
				nextState = MOTOR;
		end
		//CAL
		default: begin
			if (cal_done) begin
				resp = 8'hA5;
				send_resp = 1;
				clr_cmd_rdy = 1;
				nextState = IDLE;
			end
			else begin
				nextState = CAL;
				inertial_cal = 1;

			end
		end
	endcase
end

endmodule
