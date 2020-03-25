module HasTripped(
input CLK,
input RST,

input DATA_IN,
input startSequence,
//just make sure this start bit goes down when you want to start the sequence. 


output logic hasTripped,
output ADC_CS,
output ADC_CLK
);
//wire [9:0] theByte;


//OUTPUTS OF THE STATE MACHINE.
logic startComm;
// wire hasTripped     This is the output of this module.



//INPUTS OF THE STATE MACHINE.
wire isValid;
wire tripped;    //we have to construct this input to the state machine.
//input startSequence

wire [9:0] theByte;

assign tripped = (theByte >= 500); //THIS RANDOM NUMBER IS THE THRESHOLD!!! CHANGE IT!!!


//THIS IS THE DEVICE THAT SIMPLY GETS A 10 BIT VALUE FROM THE ADC IC.
ADC_Comm CommDevice(
//inputs
.CLK(CLK),
.RST(RST),
.DATA_IN(DATA_IN),
.Start_Comm(startComm),


//outputs
.ADC_CLK(ADC_CLK),
.ADC_CS(ADC_CS),
.Valid_Byte(isValid),
.BYTE_OUT(theByte)
);



  
typedef enum reg[2:0] {IDLE, WAIT, WAITCYCLE} STATE;
STATE state, nextstate;

  always @(posedge CLK or posedge RST) begin
  
	if(RST)
		state <= IDLE;
	else
		state <= nextstate;
		
  end

  
  
  
  
always@(*) begin

startComm = 0;
hasTripped = 0;
nextstate = IDLE;


case(state)
    IDLE: begin
		if(startSequence) begin
			nextstate = WAIT;
			startComm = 1;
		end
    end
    WAIT: begin
		if(isValid & tripped)begin
			nextstate = IDLE;
			hasTripped = 1;
		end else if (isValid & ~tripped)begin
			nextstate = WAITCYCLE;
		end else begin
			nextstate = WAIT;
		end
    end
    WAITCYCLE: begin
	nextstate = WAIT;
	startComm = 1;
    end
	
  endcase
end








endmodule

