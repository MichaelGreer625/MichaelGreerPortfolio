module UART_tx(trmt, tx_data, rst_n, clk, tx_done, TX);
input trmt, rst_n, clk;
input [7:0] tx_data;
output tx_done, TX;

reg [3:0] bit_cnt;
reg [11:0] baud_cnt;
reg [9:0] tx_shift_reg;
reg tx_done;
logic shift, load, count_reached, transmitting, set_done, clr_done;

always_ff@(posedge clk)begin 
	if(load)
		bit_cnt <= 4'd0; 
	else if(shift)
		bit_cnt <= bit_cnt + 1;

end

always_ff@(posedge clk, negedge rst_n)begin
	if(!rst_n)
		baud_cnt <= 12'd0;
	else if(shift)
		baud_cnt <= 12'd0;
	else if(transmitting)
		baud_cnt <= baud_cnt + 1;

end

assign shift = baud_cnt >= 2604;

always_ff@(posedge clk, negedge rst_n)begin
	if(!rst_n)
		tx_shift_reg <= 10'b1111111111;
	else if(load)
		tx_shift_reg <= {1'b1, tx_data, 1'b0};
	else if(shift)
		tx_shift_reg <= {1'b1, tx_shift_reg[9:1]};
end
assign TX = tx_shift_reg[0];

typedef enum reg {IDLE, WAIT} state_t;
state_t state, next_state;

always_ff@(posedge clk, negedge rst_n)begin
	if (!rst_n)
		state <= IDLE;
	else
		state <= next_state;
end
assign count_reached = bit_cnt >= 10;
always_comb begin 
	load = 0;
	transmitting = 0;
	set_done = 0;
	clr_done = 0;
	next_state = IDLE;
	case(state)
		IDLE: 
			if(trmt)begin
				load = 1;
				clr_done = 1;
				next_state = WAIT;
			end
		WAIT:
			if(count_reached)begin
				set_done = 1;
				next_state = IDLE;
			end else begin 
				transmitting = 1;	
				next_state = WAIT;
			end
	endcase

end

always_ff@(posedge clk, negedge rst_n)begin
	if(!rst_n)
		tx_done <= 0;
	else if(set_done)
		tx_done <= 1;
	else if(clr_done)
		tx_done <= 0;
end

endmodule


