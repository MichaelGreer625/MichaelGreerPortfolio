module UART_wrapper(clr_cmd_rdy, cmd_rdy, snd_resp, resp_sent, cmd, data, resp, RX, TX, clk, rst_n);
input clr_cmd_rdy, snd_resp, RX, clk, rst_n; // into the wrapper
input reg [7:0] resp; // input to UART tx_data
output logic cmd_rdy, resp_sent, TX; // outputs from the wrapper
output reg [7:0] cmd; // the first byte from the UART transmission
output reg [15:0] data; // data collection from UART
logic rdy, clr_rdy; // UART outputs, some go right out and some to the state machine
wire [7:0] rx_data; // output to the circuit from the UART
logic sel_1, sel_2; // select bits from SM to the MUXes on data and cmd outputs

logic set_cmd_rdy, clr_cmd_rdy_i; // sm output to set when the transfer is complete
typedef enum reg[1:0] {ZERO_IN, ONE_IN, TWO_IN, THREE_IN} state_t; // states
state_t state, nextState;

// Josh Widra (and Kitt)
// instantiate the UART, connecting wires to wrapper internal and some right to inputs or outputs
UART UART(.clk(clk),.rst_n(rst_n),.RX(RX),.TX(TX),.rx_rdy(rdy),.clr_rx_rdy(clr_rdy),
	.rx_data(rx_data),.trmt(snd_resp),.tx_data(resp),.tx_done(resp_sent));

// set the command byte during its cycle
always_ff @ (posedge clk) begin
	if (sel_1)
		cmd <= rx_data;
	else
		cmd <= cmd;
end

// set the top data byte during its cycle
always_ff @ (posedge clk) begin
	if (sel_2)
		data[15:8] <= rx_data;
	else
		data[15:8] <= data[15:8];
end

// the bottom data byte is constantly set, but won't be used until the transfer is complete
// which is what setting cmd_rdy is good for
assign data[7:0] = rx_data;

// set command ready once the transfer is complete
always_ff @ (posedge clk, negedge rst_n) begin
	if (!rst_n)
		cmd_rdy <= 0;
	else if (clr_cmd_rdy)
		cmd_rdy <= 0;
	else if (set_cmd_rdy)
		cmd_rdy <= 1;
	else if (clr_cmd_rdy_i)
		cmd_rdy <= 0;
end


// state machine flop
always @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		state <= ZERO_IN;
	else
		state <= nextState;
end

// FSM combinational logic
always_comb begin
// default the state machine outputs to avoid latches
clr_rdy = 0;
sel_1 = 0;
sel_2 = 0;
set_cmd_rdy = 0;
clr_cmd_rdy_i = 0;
nextState = ZERO_IN;
case (state)
	ZERO_IN: begin
		if (!rdy)
			nextState = ZERO_IN;
		else begin
			nextState = ONE_IN;
			clr_cmd_rdy_i = 1;
			clr_rdy = 1;
			sel_1 = 1;
		end
	end
	ONE_IN: begin
		if (!rdy)
			nextState = ONE_IN;
		else begin
			nextState = TWO_IN;
			clr_rdy = 1;
			sel_2 = 1;
		end
	end
	TWO_IN: begin
		if (!rdy)
			nextState = TWO_IN;
		else begin
			nextState = ZERO_IN;
			clr_rdy = 1;
			set_cmd_rdy = 1;
		end
	end
	// THREE_IN
	//default: begin
		//if (!rdy)
			//nextState = THREE_IN;
		//else begin
			//nextState = ZERO_IN;
			//clr_rdy = 1;
			//set_cmd_rdy = 1;
		//end
	//end
endcase
end

endmodule
