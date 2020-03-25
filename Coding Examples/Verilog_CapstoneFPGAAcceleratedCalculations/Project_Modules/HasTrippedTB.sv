

module hasTrippedTB;

   reg clk, rst;
   reg DATA_IN;
   reg startSequence;
   wire ADC_CLK, ADC_CS, hasTripped; 
   wire [9:0] BYTE_OUT;   
	
   reg [12:0] toshift;
   reg [9:0] toPut;

   HasTripped HasTrippedtho(.CLK(clk), .RST(rst), .DATA_IN(toshift[12]), 
		.startSequence(startSequence), .ADC_CLK(ADC_CLK), .ADC_CS(ADC_CS), .hasTripped(hasTripped), .theByte(BYTE_OUT));

   always #5 clk = ~clk;
	


   always @(posedge ADC_CLK or posedge rst or posedge ADC_CS)
   begin
	if(rst | ADC_CS)begin
		toshift <= {3'b000, toPut};
	end else begin
		//bit shift register
		toshift <= {toshift[11:0],1'b0};

	end
   end



   always @(posedge hasTripped) begin
      $display("Byte in %d --> Byte out %d)", toPut, BYTE_OUT);
      $finish;
   end


   initial begin
      clk = 0;
      rst = 0;
	toPut = 200;
	startSequence = 0;
      //$monitor($time,,"X, Y = %d, %d", doit.Xreg, doit.beforeSQRReg);
      @(posedge clk);
	rst = 1;
	@(posedge clk);
	rst = 0;
 
	@(posedge clk);
	startSequence = 1;
	@(posedge clk);
	startSequence = 0;
	@(posedge HasTrippedtho.ADC_CS);
	toPut = 300;

	@(posedge HasTrippedtho.ADC_CS);
	toPut = 400;

	@(posedge HasTrippedtho.ADC_CS);
	toPut = 500;

   end
endmodule


/*
module ADC_Comm(
input CLK,
input RST,
input DATA_IN,

//just make sure this start bit goes down when you want to start the sequence. 
input Start_Comm



output reg ADC_CLK
output reg ADC_CS
output Valid_Byte
output [9:0] BYTE_OUT
);
*/