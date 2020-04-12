module CommMaster(TX,RX,cmd,send_cmd,cmd_sent,data,resp,resp_rdy,clk,rst_n, clr_resp_rdy);

input clk,rst_n;
input RX,send_cmd;
input [7:0] cmd;
input [15:0] data;
input clr_resp_rdy;

output resp_rdy,TX;
output logic cmd_sent;
output [7:0] resp;

logic trmt,tx_done;
logic [1:0] sel;
logic [7:0] tx_data;
logic [7:0] data_high,data_low;

typedef enum logic [1:0] {IDLE,CMD_SND,HIGH_SND,LOW_SND} state_t;
state_t state,nxt_state;

UART UART(.clk(clk), .rst_n(rst_n), .RX(RX), .TX(TX), .rx_rdy(resp_rdy), .rx_data(resp),
		  .clr_rx_rdy(clr_resp_rdy), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done));

always_ff @(posedge clk) begin //both flops for the data comming in
	if(send_cmd) begin
		data_high <= data[15:8];
		data_low <= data[7:0];
	end
end

always_comb begin //the case for the 3 input mux
	casez(sel)
		2'b1?: tx_data = cmd;
		2'b01: tx_data = data_high;
		2'b00: tx_data = data_low;
	endcase
end

always_ff @(posedge clk, negedge rst_n) begin //state machine flop
	if(!rst_n)
		state <= IDLE;
	else
		state <= nxt_state;
end

always_comb begin //state machine
	nxt_state = IDLE;
	sel = 2'b10;
	trmt = 0;
	cmd_sent = 0;
	case(state)
		IDLE:if(send_cmd) begin
				nxt_state = CMD_SND;
				trmt = 1;
			end else
				nxt_state = IDLE;
				
		CMD_SND:if(tx_done) begin
					nxt_state = HIGH_SND;
					sel = 2'b01;
					trmt = 1;
				end else begin
					nxt_state = CMD_SND;
					sel = 2'b01;
				end
				
		HIGH_SND:if(tx_done) begin
					nxt_state = LOW_SND;
					sel = 2'b00;
					trmt = 1;
				end else begin
					nxt_state = HIGH_SND;
					sel = 2'b00;
				end

		LOW_SND:if(tx_done) begin
					nxt_state = IDLE;
					cmd_sent = 1;
				end else begin
					nxt_state = LOW_SND;
				end
	endcase
end

endmodule