module ADC_Comm(
input CLK,
input RST,
input DATA_IN,

//just make sure this start bit goes down when you want to start the sequence. 
input Start_Comm,



output reg ADC_CLK,
output logic ADC_CS,
output logic Valid_Byte,
output [9:0] BYTE_OUT
);

// signal definitions

//shift register signals
reg [12:0] bitShiftReg; 
reg signed [31:0] ticks;
reg [4:0] clockCounter;
wire reset;




typedef enum logic[1:0] {IDLE, SHIFT} STATE;
STATE state, nextstate;

  always @(posedge CLK or posedge RST) begin
  
	if(RST)
		state <= IDLE;
	else
		state <= nextstate;
		
  end


assign count13 = (clockCounter == 13);

logic resetClock;
always_ff @(posedge CLK or posedge RST) begin
  //asynchronous reset
  nextstate = IDLE;
  ADC_CS = 1;
  Valid_Byte = 0;
  resetClock = 0;
//  startSQR = 1;
case(state)
    IDLE: begin	
		if(Start_Comm)begin
			nextstate = SHIFT;// CHANGE THIS BACK TO WAIT
			resetClock = 1;
		end
    end
    SHIFT: begin
		ADC_CS = 0;
		if(count13)begin
			nextstate = IDLE;
			Valid_Byte = 1;
		end
	
    end
  endcase
end

assign BYTE_OUT = bitShiftReg[9:0];

always @(posedge ADC_CLK or posedge resetClock)
begin
		if(resetClock)begin
			bitShiftReg <= 0;
			clockCounter <= 0;
		end else begin
		//bit shift register
			bitShiftReg <= {bitShiftReg[11:0],DATA_IN};
			clockCounter <= clockCounter + 1;
		end

end

  always @(CLK) begin
	if (resetClock == 1)begin
		ADC_CLK <= 0;
		ticks <= 32'h00000000;
	end else if ((ticks == 0) && (state == SHIFT)) begin //THIS HERE IS THE FREQUENCY WE WANT 
		ticks <= 32'h00000000;
		ADC_CLK <= ~ADC_CLK;
	end
	else if(state == SHIFT)begin
            ticks <= ticks + 1;
        end else begin
	    ticks <= 0;
	end
   end





endmodule



