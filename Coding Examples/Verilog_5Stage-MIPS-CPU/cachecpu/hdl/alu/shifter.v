/*
   1 | 0 | OP
   -------------
   0 | 0 | SLL
   0 | 1 | SRA
   1 | 0 | ROR
   1 | 1 | no shift
*/

module Shifter
(
    input [15:0] Shift_In,
    input [3:0] Shift_Val,
    input [1:0] Mode,
    output [15:0] Shift_Out
);

wire [15:0] s1out, s2out, s4out;

shifter1 s1(.a(Shift_In), .val(Shift_Val[0]), .in(Mode), .out(s1out));
shifter2 s2(.a(s1out), .val(Shift_Val[1]), .in(Mode), .out(s2out));
shifter4 s4(.a(s2out), .val(Shift_Val[2]), .in(Mode), .out(s4out));
shifter8 s8(.a(s4out), .val(Shift_Val[3]), .in(Mode), .out(Shift_Out));

endmodule

module shifter8
(
    input [15:0] a,
    input val,
    input [1:0] in,
    output [15:0] out
);

wire [1:0] mode;
assign mode = val ? in : 2'b11;

mux4 m0(.a(a[0]), .b(1'b0), .c(a[8]), .d(a[8]), .sel(mode), .out(out[0]));
mux4 m1(.a(a[1]), .b(1'b0), .c(a[9]), .d(a[9]), .sel(mode), .out(out[1]));
mux4 m2(.a(a[2]), .b(1'b0), .c(a[10]), .d(a[10]), .sel(mode), .out(out[2]));
mux4 m3(.a(a[3]), .b(1'b0), .c(a[11]), .d(a[11]), .sel(mode), .out(out[3]));
mux4 m4(.a(a[4]), .b(1'b0), .c(a[12]), .d(a[12]), .sel(mode), .out(out[4]));
mux4 m5(.a(a[5]), .b(1'b0), .c(a[13]), .d(a[13]), .sel(mode), .out(out[5]));
mux4 m6(.a(a[6]), .b(1'b0), .c(a[14]), .d(a[14]), .sel(mode), .out(out[6]));
mux4 m7(.a(a[7]), .b(1'b0), .c(a[15]), .d(a[15]), .sel(mode), .out(out[7]));
mux4 m8(.a(a[8]), .b(a[0]), .c(a[15]), .d(a[0]), .sel(mode), .out(out[8]));
mux4 m9(.a(a[9]), .b(a[1]), .c(a[15]), .d(a[1]), .sel(mode), .out(out[9]));
mux4 m10(.a(a[10]), .b(a[2]), .c(a[15]), .d(a[2]), .sel(mode), .out(out[10]));
mux4 m11(.a(a[11]), .b(a[3]), .c(a[15]), .d(a[3]), .sel(mode), .out(out[11]));
mux4 m12(.a(a[12]), .b(a[4]), .c(a[15]), .d(a[4]), .sel(mode), .out(out[12]));
mux4 m13(.a(a[13]), .b(a[5]), .c(a[15]), .d(a[5]), .sel(mode), .out(out[13]));
mux4 m14(.a(a[14]), .b(a[6]), .c(a[15]), .d(a[6]), .sel(mode), .out(out[14]));
mux4 m15(.a(a[15]), .b(a[7]), .c(a[15]), .d(a[7]), .sel(mode), .out(out[15]));

endmodule

module shifter4
(
    input [15:0] a,
    input val,
    input [1:0] in,
    output [15:0] out
);

wire [1:0] mode;
assign mode = val ? in : 2'b11;

mux4 m0(.a(a[0]), .b(1'b0), .c(a[4]), .d(a[4]), .sel(mode), .out(out[0]));
mux4 m1(.a(a[1]), .b(1'b0), .c(a[5]), .d(a[5]), .sel(mode), .out(out[1]));
mux4 m2(.a(a[2]), .b(1'b0), .c(a[6]), .d(a[6]), .sel(mode), .out(out[2]));
mux4 m3(.a(a[3]), .b(1'b0), .c(a[7]), .d(a[7]), .sel(mode), .out(out[3]));
mux4 m4(.a(a[4]), .b(a[0]), .c(a[8]), .d(a[8]), .sel(mode), .out(out[4]));
mux4 m5(.a(a[5]), .b(a[1]), .c(a[9]), .d(a[9]), .sel(mode), .out(out[5]));
mux4 m6(.a(a[6]), .b(a[2]), .c(a[10]), .d(a[10]), .sel(mode), .out(out[6]));
mux4 m7(.a(a[7]), .b(a[3]), .c(a[11]), .d(a[11]), .sel(mode), .out(out[7]));
mux4 m8(.a(a[8]), .b(a[4]), .c(a[12]), .d(a[12]), .sel(mode), .out(out[8]));
mux4 m9(.a(a[9]), .b(a[5]), .c(a[13]), .d(a[13]), .sel(mode), .out(out[9]));
mux4 m10(.a(a[10]), .b(a[6]), .c(a[14]), .d(a[14]), .sel(mode), .out(out[10]));
mux4 m11(.a(a[11]), .b(a[7]), .c(a[15]), .d(a[15]), .sel(mode), .out(out[11]));
mux4 m12(.a(a[12]), .b(a[8]), .c(a[15]), .d(a[0]), .sel(mode), .out(out[12]));
mux4 m13(.a(a[13]), .b(a[9]), .c(a[15]), .d(a[1]), .sel(mode), .out(out[13]));
mux4 m14(.a(a[14]), .b(a[10]), .c(a[15]), .d(a[2]), .sel(mode), .out(out[14]));
mux4 m15(.a(a[15]), .b(a[11]), .c(a[15]), .d(a[3]), .sel(mode), .out(out[15]));

endmodule

module shifter2
(
    input [15:0] a,
    input val,
    input [1:0] in,
    output [15:0] out
);

wire [1:0] mode;
assign mode = val ? in : 2'b11;

mux4 m0(.a(a[0]), .b(1'b0), .c(a[2]), .d(a[2]), .sel(mode), .out(out[0]));
mux4 m1(.a(a[1]), .b(1'b0), .c(a[3]), .d(a[3]), .sel(mode), .out(out[1]));
mux4 m2(.a(a[2]), .b(a[0]), .c(a[4]), .d(a[4]), .sel(mode), .out(out[2]));
mux4 m3(.a(a[3]), .b(a[1]), .c(a[5]), .d(a[5]), .sel(mode), .out(out[3]));
mux4 m4(.a(a[4]), .b(a[2]), .c(a[6]), .d(a[6]), .sel(mode), .out(out[4]));
mux4 m5(.a(a[5]), .b(a[3]), .c(a[7]), .d(a[7]), .sel(mode), .out(out[5]));
mux4 m6(.a(a[6]), .b(a[4]), .c(a[8]), .d(a[8]), .sel(mode), .out(out[6]));
mux4 m7(.a(a[7]), .b(a[5]), .c(a[9]), .d(a[9]), .sel(mode), .out(out[7]));
mux4 m8(.a(a[8]), .b(a[6]), .c(a[10]), .d(a[10]), .sel(mode), .out(out[8]));
mux4 m9(.a(a[9]), .b(a[7]), .c(a[11]), .d(a[11]), .sel(mode), .out(out[9]));
mux4 m10(.a(a[10]), .b(a[8]), .c(a[12]), .d(a[12]), .sel(mode), .out(out[10]));
mux4 m11(.a(a[11]), .b(a[9]), .c(a[13]), .d(a[13]), .sel(mode), .out(out[11]));
mux4 m12(.a(a[12]), .b(a[10]), .c(a[14]), .d(a[14]), .sel(mode), .out(out[12]));
mux4 m13(.a(a[13]), .b(a[11]), .c(a[15]), .d(a[15]), .sel(mode), .out(out[13]));
mux4 m14(.a(a[14]), .b(a[12]), .c(a[15]), .d(a[0]), .sel(mode), .out(out[14]));
mux4 m15(.a(a[15]), .b(a[13]), .c(a[15]), .d(a[1]), .sel(mode), .out(out[15]));

endmodule

module shifter1
(
    input [15:0] a,
    input val,
    input [1:0] in,
    output [15:0] out
);

wire [1:0] mode;
assign mode = val ? in : 2'b11;

mux4 m0(.a(a[0]), .b(1'b0), .c(a[1]), .d(a[1]), .sel(mode), .out(out[0]));
mux4 m1(.a(a[1]), .b(a[0]), .c(a[2]), .d(a[2]), .sel(mode), .out(out[1]));
mux4 m2(.a(a[2]), .b(a[1]), .c(a[3]), .d(a[3]), .sel(mode), .out(out[2]));
mux4 m3(.a(a[3]), .b(a[2]), .c(a[4]), .d(a[4]), .sel(mode), .out(out[3]));
mux4 m4(.a(a[4]), .b(a[3]), .c(a[5]), .d(a[5]), .sel(mode), .out(out[4]));
mux4 m5(.a(a[5]), .b(a[4]), .c(a[6]), .d(a[6]), .sel(mode), .out(out[5]));
mux4 m6(.a(a[6]), .b(a[5]), .c(a[7]), .d(a[7]), .sel(mode), .out(out[6]));
mux4 m7(.a(a[7]), .b(a[6]), .c(a[8]), .d(a[8]), .sel(mode), .out(out[7]));
mux4 m8(.a(a[8]), .b(a[7]), .c(a[9]), .d(a[9]), .sel(mode), .out(out[8]));
mux4 m9(.a(a[9]), .b(a[8]), .c(a[10]), .d(a[10]), .sel(mode), .out(out[9]));
mux4 m10(.a(a[10]), .b(a[9]), .c(a[11]), .d(a[11]), .sel(mode), .out(out[10]));
mux4 m11(.a(a[11]), .b(a[10]), .c(a[12]), .d(a[12]), .sel(mode), .out(out[11]));
mux4 m12(.a(a[12]), .b(a[11]), .c(a[13]), .d(a[13]), .sel(mode), .out(out[12]));
mux4 m13(.a(a[13]), .b(a[12]), .c(a[14]), .d(a[14]), .sel(mode), .out(out[13]));
mux4 m14(.a(a[14]), .b(a[13]), .c(a[15]), .d(a[15]), .sel(mode), .out(out[14]));
mux4 m15(.a(a[15]), .b(a[14]), .c(a[15]), .d(a[0]), .sel(mode), .out(out[15]));

endmodule

module mux4
(
    input a,
    input b,
    input c,
    input d,
    input [1:0] sel,
    output out
);

assign out = (sel == 2'b00) ? b :
             (sel == 2'b01) ? c :
             (sel == 3'b10) ? d :
             a;

endmodule
