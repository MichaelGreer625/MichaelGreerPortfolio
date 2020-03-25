module getCycles(
input CLK,
input RST,

input trippedone,
input trippedtwo,
input startSequence,
//just make sure this start bit goes down when you want to start the sequence. 


output hasTripped,

output reg [31:0] theCount1,
output reg [31:0] theCount2
);


reg [31:0] runningcount1, runningcount2, savedcount1, savedcount2;
reg state, hadTripped1, hadTripped2;

always @(posedge CLK)//startsequence
begin
	if(startSequence) begin
		runningcount1 <= 0;
		savedcount1 <= 0;
		hadTripped1 <= 0;
	end
	else if(trippedone)begin
		theCount1 <= runningcount1;
		hadTripped1 <= 1;
	end
	else begin
		runningcount1 <= runningcount1 + 1;
	end

end

always @(posedge CLK)//or posedge startsequence
begin
	if(startSequence) begin
		runningcount2 <= 0;
		savedcount2 <= 0;
		hadTripped2 <= 0;
	end
	else if(trippedtwo)begin
		theCount2 <= runningcount2;
		hadTripped2 <= 1;
	end
	else begin
		runningcount2 <= runningcount2 + 1;
	end

end

assign hasTripped = hadTripped1 & hadTripped2;


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