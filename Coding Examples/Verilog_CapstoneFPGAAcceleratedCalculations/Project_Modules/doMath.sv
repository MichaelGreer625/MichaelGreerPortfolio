module doMath(
input CLK,
input RST,

input trippedone,
input trippedtwo,

/*
input [31:0] theCount1,
input [31:0] theCount2,
*/
input startSequence,
//just make sure this start bit goes down when you want to start the sequence. 




output complete,

output reg signed [31:0] X,
output reg signed [15:0] Y
);

localparam Scale = 1000;
localparam clockspeed = 31250000;

wire signed [31:0] theCount1, theCount2;
wire signed [31:0] theCount11;
wire signed [31:0] theCount22;
assign theCount1 = (theCount11 << 5)/2833;//THIS HERE GETS CHANGED
assign theCount2 = (theCount22 << 5)/2833;//THIS HERE GETS CHANGED



//theCount22 * ((353*1000)/(clockspeed))0.126;

wire hasTripped;
logic startSQR, startGet;
reg signed [31:0] Xreg, beforeSQRReg;

wire signed [31:0] Xregwire, beforeSQR; //, theCount1, theCount2
assign Xregwire = ((theCount1*theCount1)+(Scale*Scale)-(theCount2*theCount2))/(2 * Scale);
assign beforeSQR = (theCount1*theCount1)-(Xreg*Xreg);

wire signed [31:0] toSqrRoot;
assign toSqrRoot =(beforeSQRReg<0) ? -beforeSQRReg : beforeSQRReg;


assign X = Xreg;
sqrt32 root(.CLK(CLK), .rdy(complete), .RST(startSQR), .x(toSqrRoot), .y(Y));



getCycles getthem(
.CLK(CLK),
.RST(RST),

.trippedone(trippedone),
.trippedtwo(trippedtwo),
.startSequence(startGet),
//just make sure this start bit goes down when you want to start the sequence. 


.hasTripped(hasTripped),

.theCount1(theCount11),
.theCount2(theCount22)
);


  always @(posedge CLK or posedge RST) begin
  
	if(RST)begin
		Xreg <= 0;
		beforeSQRReg <= 0;
	end
	else begin
		Xreg <= Xregwire;
		beforeSQRReg <= beforeSQR;
	end
		
  end





typedef enum reg[4:0] {IDLE, WAIT, FINDX, FINDBEFORE, FINDY} STATE;
STATE state, nextstate;

  always @(posedge CLK or posedge RST) begin
  
	if(RST)
		state <= IDLE;
	else
		state <= nextstate;
		
  end

always@(*) begin
  //asynchronous reset
  nextstate = IDLE;
  startSQR = 1;
  startGet = 0;
case(state)
    IDLE: begin	
		if(startSequence)begin
			nextstate = WAIT;// CHANGE THIS BACK TO WAIT
			startGet = 1;
		end
    end
    WAIT: begin

		nextstate = WAIT;
		if(hasTripped)begin
			nextstate = FINDX;
		end

	
    end
    FINDX: begin
		nextstate = FINDBEFORE;
    end
    FINDBEFORE: begin
		nextstate = FINDY;
    end
    FINDY: begin	
		startSQR = 0;
		nextstate = FINDY;
		if(complete)begin
			nextstate = IDLE;
		end
    end	
	
  endcase
end

endmodule


/*
typedef enum logic[2:0] {IDLE, WAIT, CHECK} STATE;
STATE state, nextstate;

  always @(posedge clk or posedge reset) begin
  
	if(reset)
		state <= IDLE;
	else
		state <= nextstate;
		
  end

always_ff @(posedge bus.clk or posedge bus.reset) begin
  //asynchronous reset

case(nextstate)
	IDLE: begin

    end
    WAIT: begin
	
    end
    CHECK: begin
	
    end
	
	
  endcase
end
*/