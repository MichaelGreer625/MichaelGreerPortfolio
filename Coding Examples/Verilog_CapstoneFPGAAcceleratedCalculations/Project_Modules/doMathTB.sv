`timescale 1 ns / 1 ps


module doMathTB;

   reg clk, rst;
   //reg [31:0] theCount1, theCount2;
   reg startSequence;
  // reg DATA_IN1, DATA_IN2;
   wire [31:0] X;
   wire [15:0] Y;
   wire complete;
   reg trippedone, trippedtwo;


   doMath doit(.CLK(clk), .RST(rst), .trippedone(trippedone), .trippedtwo(trippedtwo), 
		.startSequence(startSequence), 
		.complete(complete), .X(X), .Y(Y));

   always #1 clk = ~clk;



   always @(posedge complete) begin
      $display("Count11, Count22 (%d, %d)", doit.theCount11, doit.theCount22);

      $display("Count1, Count2 (%d, %d)", doit.theCount1, doit.theCount2);
      $display("XregWire, breforeSQR (%d, %d)", doit.Xregwire, doit.beforeSQR);
      $display("toSqrRoot, breforeSQR (%d, %d)", doit.toSqrRoot, doit.beforeSQR);
     




      $display("X, Y (%d, %d)", X, Y);
      $finish;
   end



   initial begin
      clk = 0;
      rst = 0;
	trippedone = 0;
	trippedtwo = 0;
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
	#125177
        trippedone = 1;
	
	trippedtwo = 1;
   end
endmodule