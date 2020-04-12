module inert_intf(clk,rst_n,SS_n,SCLK,MOSI,MISO,INT,strt_cal,vld,cal_done,ptch,roll,yaw);

input clk, rst_n;

input MISO, INT, strt_cal;
output SS_n, SCLK, MOSI, cal_done;
output logic vld;
output [15:0] ptch, roll, yaw;

//control signals
logic C_P_H, C_P_L, C_R_H, C_R_L, C_Y_H, C_Y_L, C_AX_H, C_AX_L, C_AY_H, C_AY_L;
logic [15:0] timer;
logic INT_FF1, INT_FF2;

//instantiation connects
wire done;
logic wrt;
wire [15:0] rd_data;
logic [15:0] cmd;
wire [15:0] ptch_rt, roll_rt, yaw_rt, ax, ay;

// Instantiations
SPI_mstr16 SPI(.clk(clk), .rst_n(rst_n), .cmd(cmd), .wrt(wrt), .MISO(MISO), .MOSI(MOSI),
		.rd_data(rd_data), .done(done), .SS_n(SS_n), .SCLK(SCLK));

// parameter to 11 for actual run
inertial_integrator #(3) integrator(.clk(clk), .rst_n(rst_n), .strt_cal(strt_cal), .cal_done(cal_done),
				.vld(vld), .ptch_rt(ptch_rt), .roll_rt(roll_rt), .yaw_rt(yaw_rt),
				.ax(ax), .ay(ay), .ptch(ptch), .roll(roll), .yaw(yaw));


logic [7:0] ptch_H, ptch_L, roll_H, roll_L, yaw_H, yaw_L; //high and low bytes of gyro stuff
logic [7:0] ax_H, ax_L, ay_H, ay_L; //high and low bytes of accels

//state instantiations
typedef enum logic [4:0] {INIT1,INIT2,INIT3,INIT4,WAIT,LOOP,PTCHL,PTCHH,ROLLL,ROLLH,YAWL,YAWH,AXL,AXH,AYL,AYH,LOOPBACK} state_t;
state_t state, nxt_state;

//assign the hold registers to the integrator inputs
assign ptch_rt = {ptch_H,ptch_L};
assign roll_rt = {roll_H,roll_L};
assign yaw_rt = {yaw_H,yaw_L};
assign ax = {ax_H,ax_L};
assign ay = {ay_H,ay_L};

//double flop INT
always_ff @(posedge clk) begin
	INT_FF1 <= INT;
	INT_FF2 <= INT_FF1;
end

//////////////////////////////////////////////////
////////////// Holding Registers /////////////////
//////////////////////////////////////////////////
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		ptch_H <= 8'h00;
	else if(C_P_H)
		ptch_H <= rd_data[7:0];
end

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		ptch_L <= 8'h00;
	else if(C_P_L)
		ptch_L <= rd_data[7:0];
end

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		roll_H <= 8'h00;
	else if(C_R_H)
		roll_H <= rd_data[7:0];
end

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		roll_L <= 8'h00;
	else if(C_R_L)
		roll_L <= rd_data[7:0];
end

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		yaw_H <= 8'h00;
	else if(C_Y_H)
		yaw_H <= rd_data[7:0];
end

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		yaw_L <= 8'h00;
	else if(C_Y_L)
		yaw_L <= rd_data[7:0];
end

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		ax_H <= 8'h00;
	else if(C_AX_H)
		ax_H <= rd_data[7:0];
end

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		ax_L <= 8'h00;
	else if(C_AX_L)
		ax_L <= rd_data[7:0];
end

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		ay_H <= 8'h00;
	else if(C_AY_H)
		ay_H <= rd_data[7:0];
end

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		ay_L <= 8'h00;
	else if(C_AY_L)
		ay_L <= rd_data[7:0];
end

//////////////////////////////////////////////////
//////////////// State Machine ///////////////////
//////////////////////////////////////////////////
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		timer <= 16'h0000;
	else
		timer <= timer + 1;
end

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		state <= INIT1;
	else
		state <= nxt_state;
end



always_comb begin
cmd = 0;
wrt = 0;
vld = 0;
C_P_H = 0;
C_P_L = 0;
C_R_H = 0;
C_R_L = 0;
C_Y_H = 0;
C_Y_L = 0;
C_AX_H = 0;
C_AX_L = 0;
C_AY_H = 0;
C_AY_L = 0;
nxt_state = LOOP;

case(state)
	INIT1:begin
		cmd = 16'h0d02;
		if(!(&timer))	
			nxt_state = INIT1;
		else begin
			nxt_state = INIT2;
			wrt = 1;
		end
	end

	INIT2:begin
		cmd = 16'h1062;
		if(!done)	
			nxt_state = INIT2;
		else begin
			nxt_state = INIT3;
			wrt = 1;
		end
	end

	INIT3:begin
		cmd = 16'h1162;
		if(!done)	
			nxt_state = INIT3;
		else begin
			nxt_state = INIT4;
			wrt = 1;
		end
	end

	INIT4:begin
		cmd = 16'h1460;
		if(!done)	
			nxt_state = INIT4;
		else begin
			nxt_state = WAIT;
			wrt = 1;
		end
	end

	WAIT:begin
		if(!done)	
			nxt_state = WAIT;
		else begin
			nxt_state = LOOP;
		end
	end

	LOOP:begin
		cmd = 16'ha200;
		if(!INT_FF2)	
			nxt_state = LOOP;
		else begin
			nxt_state = PTCHL;
			wrt = 1;
		end
	end

	PTCHL:begin
		cmd = 16'ha300;
		if(!done)	
			nxt_state = PTCHL;
		else begin
			nxt_state = PTCHH;
			wrt = 1;
			C_P_L = 1;
		end
	end

	PTCHH:begin
		cmd = 16'ha400;
		if(!done)	
			nxt_state = PTCHH;
		else begin
			nxt_state = ROLLL;
			wrt = 1;
			C_P_H = 1;
		end
	end

	ROLLL:begin
		cmd = 16'ha500;
		if(!done)	
			nxt_state = ROLLL;
		else begin
			nxt_state = ROLLH;
			wrt = 1;
			C_R_L = 1;
		end
	end

	ROLLH:begin
		cmd = 16'ha600;
		if(!done)	
			nxt_state = ROLLH;
		else begin
			nxt_state = YAWL;
			wrt = 1;
			C_R_H = 1;
		end
	end

	YAWL:begin
		cmd = 16'ha700;
		if(!done)	
			nxt_state = YAWL;
		else begin
			nxt_state = YAWH;
			wrt = 1;
			C_Y_L = 1;
		end
	end

	YAWH:begin
		cmd = 16'ha800;
		if(!done)	
			nxt_state = YAWH;
		else begin
			nxt_state = AXL;
			wrt = 1;
			C_Y_H = 1;
		end
	end

	AXL:begin
		cmd = 16'ha900;
		if(!done)	
			nxt_state = AXL;
		else begin
			nxt_state = AXH;
			wrt = 1;
			C_AX_L = 1;
		end
	end

	AXH:begin
		cmd = 16'haA00;
		if(!done)	
			nxt_state = AXH;
		else begin
			nxt_state = AYL;
			wrt = 1;
			C_AX_H = 1;
		end
	end


	AYL:begin
		cmd = 16'haB00;
		if(!done)	
			nxt_state = AYL;
		else begin
			nxt_state = AYH;
			wrt = 1;
			C_AY_L = 1;
		end
	end

	AYH:begin
		if(!done)	
			nxt_state = AYH;
		else begin
			nxt_state = LOOPBACK;
			C_AY_H = 1;
		end
	end

	LOOPBACK:begin
		nxt_state = LOOP;
		vld = 1;
	end






endcase


end


endmodule
