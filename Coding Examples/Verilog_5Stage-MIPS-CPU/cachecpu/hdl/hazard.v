module hazard(
input MemRead,
input [3:0] ExRegRt,
input [3:0] DeRegRt,
input [3:0] DeRegRs,
output muxWrite
);

//wire [3:0] muxTemp;
//assign muxTemp = {{3{MemRead}}, MemRead} & ((~(ExRegRt ^ DeRegRs)) | (~(ExRegRt ^ DeRegRt)));
//assign muxWrite = ~(muxTemp[3] & muxTemp[2] & muxTemp[1] & muxTemp[0]);
 
assign muxWrite = MemRead & ((ExRegRt == DeRegRt) | (ExRegRt == DeRegRs));

endmodule
