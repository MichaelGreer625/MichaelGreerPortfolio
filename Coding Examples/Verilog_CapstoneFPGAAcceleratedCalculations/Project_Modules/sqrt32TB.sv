

module sqrt32TB;

   reg clk, rst;
   wire finished;
	
   reg [31:0] x;
   wire [15:0] y;


sqrt32 supy(.CLK(clk), .rdy(finished), .RST(rst), .x(x), .y(y));

   always #1 clk = ~clk;
	






   always @(posedge finished) begin
      $display("y --> %d)", y);
      $finish;
   end


   initial begin
      clk = 0;
      rst = 0;
      x = 25;
      //$monitor($time,,"X, Y = %d, %d", doit.Xreg, doit.beforeSQRReg);
      @(posedge clk);
	rst = 1;
	@(posedge clk);
	rst = 0;
 


   end
endmodule

/*
	@(posedge HasTrippedtho.ADC_CS);
	toPut = 300;

	@(posedge HasTrippedtho.ADC_CS);
	toPut = 400;

	@(posedge HasTrippedtho.ADC_CS);
	toPut = 500;
*/