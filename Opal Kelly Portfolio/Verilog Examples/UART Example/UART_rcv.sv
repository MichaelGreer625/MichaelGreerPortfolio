module UART_rcv(RX, clr_rdy, rst_n, clk, rx_data, rdy);
input RX, clr_rdy, rst_n, clk;
output [7:0] rx_data;
output rdy;

logic [9:0] rx_shift_reg;
logic [11:0] baud_cnt;
logic [3:0] bit_cnt;
logic rdy;
logic metastable, metastable1;
logic start, receiving;
logic set_rdy, clr_rdy_in;
logic shift;
logic countZero;
typedef enum reg {IDLE, RECIEVING} theState;
theState state, nextState;


always_ff@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		metastable <= 1;
		metastable1 <= 1;
	end
	else begin
		metastable1 <= RX;
		metastable <= metastable1;
	end
end


always_ff@(posedge clk)begin
	if(shift)
		rx_shift_reg <= {RX, rx_shift_reg[9:1]};

end
always_ff@(posedge clk)begin
	if(start)
		baud_cnt <= 1302;
	else if(shift) 
		baud_cnt <= 2604;
	else if(receiving)
		baud_cnt <= baud_cnt - 1;

end

assign shift = baud_cnt == 1;

always_ff@(posedge clk)begin
	if(start)
		bit_cnt <= 10;
	else if (shift)
		bit_cnt <= bit_cnt - 1;
end

assign countZero = bit_cnt == 0;
assign rx_data = rx_shift_reg[8:1];

always_ff@(posedge clk, negedge rst_n)begin
	if(!rst_n)
		state <= IDLE;
	else	
		state <= nextState;
end

always_ff@(posedge clk, negedge rst_n)begin
	if(!rst_n)
		rdy <= 0;
	else if(clr_rdy)
		rdy <= 0;
	else if(set_rdy)
		rdy <= 1;
	else if(clr_rdy_in)
		rdy <= 0;

end


always_comb begin
start = 0;
receiving = 0;
set_rdy = 0;
clr_rdy_in = 0;
nextState = IDLE;


case(state)
	IDLE:	
		if(!metastable)begin
			start = 1; 
			clr_rdy_in = 1;
			nextState = RECIEVING;
		end
	RECIEVING:
		if(countZero)begin
			set_rdy = 1;
			nextState = IDLE;
		end
		else begin
			receiving = 1;
			nextState = RECIEVING;
		end
endcase



end


endmodule 