
/*

These have been modified below to follow in order with Table Three.
  2 1 0 | OP
  --------------
  0 0 0 | ADD
  0 0 1 | SUB
  0 1 0 | RED
  0 1 1 | XOR
  1 0 0 | SLL 
  1 0 1 | SRA
  1 1 0 | ROR
  1 1 1 | PADDSB

  flags: ZVN
*/

module alu
(
    input [15:0] a,
    input [15:0] b,
    input [2:0] ctl,
    output reg [15:0] result,
    output [2:0] flags
);

wire [3:0] single;
wire [15:0] add_out, red_out, shift_out, xor_out;

//------------------------------------------------------------------------
//-------------Flag creation for module-----------------------------------
//------------------------------------------------------------------------
	
// set N flag as sign bit of result
assign flags[0] = result[15];

// set Z flag (for all operations currently)
assign flags[2] = (result == 16'h0) ? 1'b1 : 1'b0; 
	
//------------------------------------------------------------------------
//-Module Instantiation andoutput creation for inputs to mux below--------
//------------------------------------------------------------------------
	
// more adders to support RED
red red_blk(.psum(add_out), .carry1(single), .result(red_out));

// shifter module
Shifter shift_blk(.Shift_In(a), .Shift_Val(b[3:0]), .Mode(ctl[1:0]), .Shift_Out(shift_out));

// 16bit CLA to support ADD/SUB/PADDSB/RED
adder16 adder(.a(a), .b(b), .mode(ctl[1:0]), .single(single), .sum(add_out), .ovf(flags[1]));
  
// XOR support
assign xor_out = a ^ b;

//------------------------------------------------------------------------
//----------Result mux that feeds in outputs above, outputs result--------
//------------------------------------------------------------------------
	
// mux outputs based on ctl
//assign result = ctl[2] ? ((ctl[1] & ctl[0]) ? xor_out : shift_out) :
//                         ((ctl[1] & ctl[0]) ? red_out : add_out);
	
	
  always@(*)
  case(ctl)
	3'b000 : result = add_out;//add the assorted output values for the assorted opcodes.
	3'b001 : result = add_out;
	3'b010 : result = red_out;
	3'b011 : result = xor_out;
	3'b100 : result = shift_out;
	3'b101 : result = shift_out;
	3'b110 : result = shift_out;
	3'b111 : result = add_out;
    endcase

endmodule


