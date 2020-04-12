module alu_test();

reg signed [15:0] a, b;
reg [2:0] ctl;

wire signed [15:0] result, paddr, addr, subr, xorr, red, ror;
wire [2:0] flags;

wire signed [4:0] pa1, pa2, pa3, pa4, p1, p2, p3, p4;

alu iDUT(.a(a), .b(b), .ctl(ctl), .result(result), .flags(flags));

assign addr = a + b;
assign subr = a - b;
assign xorr = a ^ b;

assign pa1 = a[15:12] + b[15:12];
assign pa2 = a[11:8] + b[11:8];
assign pa3 = a[7:4] + b[7:4];
assign pa4 = a[3:0] + b[3:0];

assign p1 = (~a[15] & ~b[15] & pa1[3]) ? 7 : ((a[15] & b[15] & ~pa1[3]) ? -8 : pa1);
assign p2 = (~a[11] & ~b[11] & pa2[3]) ? 7 : ((a[11] & b[11] & ~pa2[3]) ? -8 : pa2);
assign p3 = (~a[7] & ~b[7] & pa3[3]) ? 7 : ((a[7] & b[7] & ~pa3[3]) ? -8 : pa3);
assign p4 = (~a[3] & ~b[3] & pa4[3]) ? 7 : ((a[3] & b[3] & ~pa4[3]) ? -8 : pa4);

assign paddr = {p1, p2, p3, p4};

assign red = pa1 + pa2 + pa3 + pa4;

assign ror = {a[7:0], a[15:8]};

initial begin
forever begin
#2;
a = $random;
b = $random;
ctl = 3'b001; //change ctl to test different instructions
#2;
case (ctl)
3'b000: begin // ADD
        if (addr != result && flags[0] == 1'b1)
            if (result != -32768 && result != 32767)
                $display("ERROR: ADD");
        end
3'b001: begin // SUB
        if (subr!= result && flags[0] == 1'b1)
            if (result != -32768 && result != 32767)
                $display("ERROR: SUB");
        end
3'b010: begin // RED
	if(red != result)
	    $display("ERROR: RED");
        end
3'b011: begin // XOR
        if (xorr != result)
            $display("ERROR: XOR");
        end
3'b100: begin // SLL
        if (a << b[3:0] != result)
            $display("ERROR: SLL");
        end
3'b101: begin // SRA
        if (a >>> b[3:0] != result)
            $display("ERROR: SRA");
        end
3'b110: begin // ROR
	//only tests ROR 8-bits for now
	if (ror != result)
            $display("ERROR: ROR");
        end
3'b111: begin // PADDSB
        if (paddr != result)
            $display("ERROR: PADDSB");
        end
endcase
end
end

initial begin
#400;
$stop;
end

endmodule
