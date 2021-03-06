
module ADC_CommTB;

   reg clk, rst;
   reg DATA_IN;
   reg Start_Comm;
   wire ADC_CLK, ADC_CS, Valid_Byte; 
   wire [9:0] BYTE_OUT;   
	
   reg [12:0] toshift;
   reg [9:0] toPut;

   ADC_Comm ADC_Commtho(.CLK(clk), .RST(rst), .DATA_IN(toshift[12]), 
		.Start_Comm(Start_Comm), .ADC_CLK(ADC_CLK), .ADC_CS(ADC_CS), .Valid_Byte(Valid_Byte), .BYTE_OUT(BYTE_OUT));

   always #5 clk = ~clk;
	


   always @(negedge ADC_CLK or posedge rst)
   begin
	if(rst)begin
		toshift <= {3'b000, toPut};
	end else begin
		//bit shift register
		toshift <= {toshift[11:0],1'b0};

	end
   end



   always @(posedge Valid_Byte) begin
      $display("Byte in %d --> Byte out %d)", toPut, BYTE_OUT);
      $finish;
   end


   initial begin
      clk = 0;
      rst = 0;
	toPut = 50;
	Start_Comm = 0;
      //$monitor($time,,"X, Y = %d, %d", doit.Xreg, doit.beforeSQRReg);
      @(posedge clk);
	rst = 1;
	@(posedge clk);
	rst = 0;
	@(posedge clk);
	Start_Comm = 1;
	@(posedge clk);
	Start_Comm = 0;
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