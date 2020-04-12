module UART_tx(trmt, tx_data, tx_done, clk, rst_n, TX);

input logic trmt, clk, rst_n;
input [7:0] tx_data;
output logic tx_done, TX;

logic load, transmitting, shift, set_done, clr_done, state, nextState;
logic [3:0] bit_cnt;
logic [11:0] baud_cnt;
logic [8:0] tx_shft_reg; // only need 9 bits for shifting in 1's..?

localparam IDLE = 1'b0;
localparam TRANSMITTING = 1'b1;

// FSM and datapath
// leftmost ff on diagram, tracks when 8 bits have been loaded
always_ff @ (posedge clk or negedge rst_n) begin
if (!rst_n)
	bit_cnt <= 4'b0;
else if (load)
	bit_cnt <= 4'b0;
else if (shift)
	bit_cnt <= bit_cnt + 1'b1;
end

// middle-top ff on diagram, tracks baud count
// counting down instead of up
always_ff @ (posedge clk or negedge rst_n) begin
if (!rst_n)
	baud_cnt <= 2604;
else if (load || shift)
	baud_cnt <= 2604;
else if (transmitting)
	baud_cnt <= baud_cnt - 1'b1; 
end

// right-top ff on diagram, tracks data value and shifts
always_ff @ (posedge clk, negedge rst_n) begin
if (!rst_n)
	tx_shft_reg <= 9'b111111111;
else if (load)
	tx_shft_reg <= {tx_data, 1'b0};
else if (!load && shift)
	tx_shft_reg <= {1'b1, tx_shft_reg[8:1]};
end

//bottom-right ff on diagram, tells when UART is done
always_ff @ (posedge clk, negedge rst_n) begin
if (!rst_n)
	tx_done <= 1'b0;
else if (set_done)
	tx_done <= 1'b1;
else if (clr_done)
	tx_done <= 1'b0;
end

// assign the wire coming from flops that need combinational logic
assign shift = ~|baud_cnt;
assign TX = tx_shft_reg[0];

// state machine portion
always @ (posedge clk, negedge rst_n) begin
if (!rst_n)
	state <= IDLE;
else
	state <= nextState;
end

always_comb begin
// default variables to avoid unindended latches
nextState = IDLE;
load = 0;
clr_done = 0;
transmitting = 0;
set_done = 0;
case (state)
	IDLE: if (trmt) begin
		nextState = TRANSMITTING;
		load = 1;
		clr_done = 1;
	end
	else
		nextState = IDLE;
	// default is transmitting state
	default: begin
		if (bit_cnt == 10) begin
			nextState = IDLE;
			set_done = 1;
		end
		else
			nextState = TRANSMITTING;
		transmitting = 1;
	end
endcase
end

endmodule
