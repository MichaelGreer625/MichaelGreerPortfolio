module flght_cntrl(clk,rst_n,vld,inertial_cal,d_ptch,d_roll,d_yaw,ptch,
					roll,yaw,thrst,frnt_spd,bck_spd,lft_spd,rght_spd);
				
parameter D_QUEUE_DEPTH = 14;		// delay for derivative term
				
input clk,rst_n;
input vld;									// tells when a new valid inertial reading ready
											// only update D_QUEUE on vld readings
input inertial_cal;							// need to run motors at CAL_SPEED during inertial calibration
input signed [15:0] d_ptch,d_roll,d_yaw;	// desired pitch roll and yaw (from cmd_cfg)
input signed [15:0] ptch,roll,yaw;			// actual pitch roll and yaw (from inertial interface)
input [8:0] thrst;							// thrust level from slider
output [10:0] frnt_spd;						// 11-bit unsigned speed at which to run front motor
output [10:0] bck_spd;						// 11-bit unsigned speed at which to back front motor
output [10:0] lft_spd;						// 11-bit unsigned speed at which to left front motor
output [10:0] rght_spd;						// 11-bit unsigned speed at which to right front motor

///////////////////////////////////////////////////
// Need integer for loop used to create D_QUEUE //
/////////////////////////////////////////////////
integer x;
//////////////////////////////
// Define needed registers //
////////////////////////////								
reg signed [9:0] prev_ptch_err[0:D_QUEUE_DEPTH-1];
reg signed [9:0] prev_roll_err[0:D_QUEUE_DEPTH-1];
reg signed [9:0] prev_yaw_err[0:D_QUEUE_DEPTH-1];	// need previous error terms for D of PD

//////////////////////////////////////////////////////
// You will need a bunch of interal wires declared //
// for intermediate math results...do that here   //
///////////////////////////////////////////////////
reg signed [12:0] thrst_ext, ptch_pterm_ext, ptch_dterm_ext, yaw_pterm_ext, yaw_dterm_ext, roll_pterm_ext, roll_dterm_ext, frnt_spd_ext, lft_spd_ext, rght_spd_ext, bck_spd_ext;
reg [10:0] frnt_spd_calc, lft_spd_calc, rght_spd_calc, bck_spd_calc;

///////////////////////////////////////////////////////////////
// some Parameters to keep things more generic and flexible //
/////////////////////////////////////////////////////////////
  
  localparam CAL_SPEED = 11'h1B0;		// speed to run motors at during inertial calibration
  localparam MIN_RUN_SPEED = 13'h200;	// minimum speed while running  
  localparam D_COEFF = 6'b00111;			// D coefficient in PID control = +7
  
  
/// OK...rest is up to you...good luck! ///

//////////////////////////////////////////
// Creating the p and d term for pitch //
////////////////////////////////////////
wire [16:0]ptch_err;
wire [11:0]ptch_dterm;
wire [9:0]ptch_err_sat,ptch_pterm,ptch_D_diff;
wire [5:0]ptch_D_diff_sat;

assign ptch_err = $signed(ptch) - $signed(d_ptch); //creating the error term

assign ptch_err_sat = (~ptch_err[16] && |ptch_err[15:9]) ? 10'h1FF : // sat pos
					  (ptch_err[16] && ~&ptch_err[15:9]) ? 10'h200 : // sat neg
					   ptch_err[9:0]; // in range

assign ptch_pterm = {ptch_err_sat[9],ptch_err_sat[9:1]} + // 1/2 +
					{{3{ptch_err_sat[9]}},ptch_err_sat[9:3]}; // 1/8 = 5/8

always_ff @(posedge clk, negedge rst_n) begin //the queue of flops for derivation
	if(!rst_n)begin
		for(x = D_QUEUE_DEPTH-1; x > 0; x=x-1) begin
			prev_ptch_err[x] <= 0;
		end
	end
	else if(vld) begin
			for(x = D_QUEUE_DEPTH-1; x > 0; x=x-1) begin
				prev_ptch_err[x] <= prev_ptch_err[x-1];
			end
				prev_ptch_err[0] <= ptch_err_sat;
		 end
end

assign ptch_D_diff = $signed(ptch_err_sat) - $signed(prev_ptch_err[D_QUEUE_DEPTH-1]); //making the derivative term

assign ptch_D_diff_sat = (~ptch_D_diff[9] && |ptch_D_diff[8:5]) ? 6'h1F : // sat pos
						 (ptch_D_diff[9] && ~&ptch_D_diff[8:5]) ? 6'h20 : // sat neg
						  ptch_D_diff[5:0]; // in range
						  
assign ptch_dterm = $signed(ptch_D_diff_sat) * $signed(D_COEFF); //making dterm 

/////////////////////////////////////////
// Creating the p and d term for roll //
///////////////////////////////////////
wire [16:0]roll_err;
wire [11:0]roll_dterm;
wire [9:0]roll_err_sat,roll_pterm,roll_D_diff;
wire [5:0]roll_D_diff_sat;

assign roll_err = $signed(roll) - $signed(d_roll); //creating the error term

assign roll_err_sat = (~roll_err[16] && |roll_err[15:9]) ? 10'h1FF : // sat pos
					  (roll_err[16] && ~&roll_err[15:9]) ? 10'h200 : // sat neg
					   roll_err[9:0]; // in range

assign roll_pterm = {roll_err_sat[9],roll_err_sat[9:1]} + // 1/2 +
					{{3{roll_err_sat[9]}},roll_err_sat[9:3]}; // 1/8 = 5/8

always_ff @(posedge clk, negedge rst_n) begin //the queue of flops for derivation
	if(!rst_n)begin
		for(x = D_QUEUE_DEPTH-1; x > 0; x=x-1) begin
			prev_roll_err[x] <= 0;
		end
	end
	else if(vld) begin
			for(x = D_QUEUE_DEPTH-1; x > 0; x=x-1) begin
				prev_roll_err[x] <= prev_roll_err[x-1];
			end
				prev_roll_err[0] <= roll_err_sat;
		 end
end

assign roll_D_diff = $signed(roll_err_sat) - $signed(prev_roll_err[D_QUEUE_DEPTH-1]); //making the derivative term

assign roll_D_diff_sat = (~roll_D_diff[9] && |roll_D_diff[8:5]) ? 6'h1F : // sat pos
						 (roll_D_diff[9] && ~&roll_D_diff[8:5]) ? 6'h20 : // sat neg
						  roll_D_diff[5:0]; // in range
						  
assign roll_dterm = $signed(roll_D_diff_sat) * $signed(D_COEFF); //making dterm 

////////////////////////////////////////
// Creating the p and d term for yaw //
//////////////////////////////////////
wire [16:0]yaw_err;
wire [11:0]yaw_dterm;
wire [9:0]yaw_err_sat,yaw_pterm,yaw_D_diff;
wire [5:0]yaw_D_diff_sat;

assign yaw_err = $signed(yaw) - $signed(d_yaw); //creating the error term

assign yaw_err_sat = (~yaw_err[16] && |yaw_err[15:9]) ? 10'h1FF : // sat pos
					 (yaw_err[16] && ~&yaw_err[15:9]) ? 10'h200 : // sat neg
					  yaw_err[9:0]; // in range

assign yaw_pterm = {yaw_err_sat[9],yaw_err_sat[9:1]} + // 1/2 +
				   {{3{yaw_err_sat[9]}},yaw_err_sat[9:3]}; // 1/8 = 5/8

always_ff @(posedge clk, negedge rst_n) begin //the queue of flops for derivation
	if(!rst_n)begin
		for(x = D_QUEUE_DEPTH-1; x > 0; x=x-1) begin
			prev_yaw_err[x] <= 0;
		end
	end
	else if(vld) begin
			for(x = D_QUEUE_DEPTH-1; x > 0; x=x-1) begin
				prev_yaw_err[x] <= prev_yaw_err[x-1];
			end
				prev_yaw_err[0] <= yaw_err_sat;
		 end
end

assign  yaw_D_diff = $signed(yaw_err_sat) - $signed(prev_yaw_err[D_QUEUE_DEPTH-1]); //making the derivative term

assign yaw_D_diff_sat = (~yaw_D_diff[9] && |yaw_D_diff[8:5]) ? 6'h1F : // sat pos
						(yaw_D_diff[9] && ~&yaw_D_diff[8:5]) ? 6'h20 : // sat neg
						 yaw_D_diff[5:0]; // in range
						  
assign yaw_dterm = $signed(yaw_D_diff_sat) * $signed(D_COEFF); //making dterm 


// sign extend inputs to adder
assign thrst_ext = {{4{1'b0}}, thrst}; // except thrust, which is unsigned.
assign ptch_pterm_ext = {{3{ptch_pterm[9]}}, ptch_pterm};
assign ptch_dterm_ext = {ptch_dterm[11], ptch_dterm};
assign yaw_pterm_ext = {{3{yaw_pterm[9]}}, yaw_pterm};
assign yaw_dterm_ext = {yaw_dterm[11], yaw_dterm};
assign roll_pterm_ext = {{3{roll_pterm[9]}}, roll_pterm};
assign roll_dterm_ext = {roll_dterm[11], roll_dterm};

//set motor speed based on some combination of these terms summed or subtracted, based off the project spec
assign frnt_spd_ext = MIN_RUN_SPEED + thrst_ext - ptch_pterm_ext - ptch_dterm_ext - yaw_pterm_ext - yaw_dterm_ext;
assign lft_spd_ext = MIN_RUN_SPEED + thrst_ext - roll_pterm_ext - roll_dterm_ext + yaw_pterm_ext + yaw_dterm_ext;
assign rght_spd_ext = MIN_RUN_SPEED + thrst_ext + roll_pterm_ext + roll_dterm_ext + yaw_pterm_ext + yaw_dterm_ext;
assign bck_spd_ext = MIN_RUN_SPEED + thrst_ext + ptch_pterm_ext + ptch_dterm_ext - yaw_pterm_ext - yaw_dterm_ext;

// calculate saturated speed, so check for being negative or larger than the saturated version
assign frnt_spd_calc = (frnt_spd_ext[12]) ? (11'h000) :
			(~frnt_spd_ext[12] && frnt_spd_ext[11]) ? (11'h7FF) :
				(frnt_spd_ext[10:0]);
assign lft_spd_calc = (lft_spd_ext[12]) ? (11'h000) :
			(~lft_spd_ext[12] && lft_spd_ext[11]) ? (11'h7FF) :
				(lft_spd_ext[10:0]);
assign rght_spd_calc = (rght_spd_ext[12]) ? (11'h000) :
			(~rght_spd_ext[12] && rght_spd_ext[11]) ? (11'h7FF) :
				(rght_spd_ext[10:0]);
assign bck_spd_calc = (bck_spd_ext[12]) ? (11'h000) :
			(~bck_spd_ext[12] && bck_spd_ext[11]) ? (11'h7FF) :
				(bck_spd_ext[10:0]);

// finally, set each of the output signals
assign frnt_spd = (inertial_cal) ? CAL_SPEED : frnt_spd_calc;
assign lft_spd = (inertial_cal) ? CAL_SPEED : lft_spd_calc;
assign rght_spd = (inertial_cal) ? CAL_SPEED : rght_spd_calc;
assign bck_spd = (inertial_cal) ? CAL_SPEED : bck_spd_calc;

endmodule 
