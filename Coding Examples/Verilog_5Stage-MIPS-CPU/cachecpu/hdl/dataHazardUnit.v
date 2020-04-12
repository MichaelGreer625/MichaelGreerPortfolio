module dataHazardUnit(
input EXMEMRegWrite, 
input MEMWBRegWrite,
input [3:0] EXMEMRegRd,
input [3:0] MEMWBRegRd,
input [3:0] IDEXRegRt,
input [3:0] IDEXRegRs,
output [1:0] forwardA,
output [1:0] forwardB
);
wire EXhazard;
wire MEMhazard;

assign EXhazard = EXMEMRegWrite & (EXMEMRegRd != 0); 
assign MEMhazard = MEMWBRegWrite & (MEMWBRegRd != 0);

assign forwardA = EXhazard & (EXMEMRegRd == IDEXRegRs) ? 2'b10 : 
		  MEMhazard & (MEMWBRegRd == IDEXRegRs)  ? 2'b01 : 2'b00;

assign forwardB = EXhazard & (EXMEMRegRd == IDEXRegRt) ? 2'b10 : 
		  MEMhazard & (MEMWBRegRd == IDEXRegRt) ? 2'b01 : 2'b00;
endmodule
