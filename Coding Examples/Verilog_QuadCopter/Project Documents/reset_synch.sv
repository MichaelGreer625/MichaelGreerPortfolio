module reset_synch(RST_n, clk, rst_n);

input RST_n, clk;
output logic rst_n;

logic ff1_to_ff2;

always_ff @ (negedge clk, negedge RST_n) begin
	if (!RST_n) begin
		ff1_to_ff2 <= 1'b0;
		rst_n <=  1'b0;
	end
	else begin
		ff1_to_ff2 <= 1'b1;
		rst_n <= ff1_to_ff2;
	end
end

endmodule
