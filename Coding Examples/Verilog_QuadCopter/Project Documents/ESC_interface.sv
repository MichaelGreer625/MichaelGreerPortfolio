module ESC_interface(clk, rst_n, SPEED, OFF, PWM);

parameter PERIOD_WIDTH = 20;

input clk, rst_n;
input [10:0] SPEED;
input [9:0] OFF;

output reg PWM;

wire [11:0] compensated_speed;
wire [15:0] compensated_speed_promoted;
wire [16:0] setting;
reg [PERIOD_WIDTH-1:0] counter_out;
reg [PERIOD_WIDTH-1:0] counter_in;
wire set_signal;
wire rst_signal;

// do the addition and promotion of the input signals
assign compensated_speed = SPEED + OFF;
assign compensated_speed_promoted = compensated_speed << 4;
assign setting = compensated_speed_promoted + 16'd50000;
// add to the count
assign counter_in = counter_out + 1;
// set the final flop once 20 cycles have passed
assign set_signal = &counter_out;
// comparator to assert rst signal when clocks passed is greater than setting
assign rst_signal = counter_out[16:0] >= setting;

// bottom flip flop for counting up to 20 clock cycles
always_ff @ (posedge clk, negedge rst_n) begin
if (!rst_n)
	counter_out <= 20'h00000;
else
	counter_out <= counter_in;
end

// final ff to set PWM
always_ff @ (posedge clk, negedge rst_n) begin
if (!rst_n)
	PWM = 0;
else if (set_signal)
	PWM = 1;
else if (rst_signal)
	PWM = 0;
else
	PWM = PWM;
end

endmodule
