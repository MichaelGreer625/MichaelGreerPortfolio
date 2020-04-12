module A2D_intf(clk,rst_n,strt_cnv,chnnl,cnv_cmplt,res,SS_n,SCLK,MOSI,MISO);

input clk,rst_n,strt_cnv,MISO;
input [2:0] chnnl;

output logic cnv_cmplt;
output SS_n,SCLK,MOSI;
output [11:0] res;

wire [15:0] chnnl_extnd;
wire [15:0] res_extnd;
wire done;
logic cnv_cmplt_S,wrt;

//SPI_mstr
SPI_mstr16 SPI_mstr16(.clk(clk), .rst_n(rst_n), .SS_n(SS_n), .SCLK(SCLK), .MISO(MISO),
		  .MOSI(MOSI), .cmd(chnnl_extnd), .rd_data(res_extnd), .done(done), .wrt(wrt));

//extended versions of signals for connection to SPI
assign chnnl_extnd = {2'b00,chnnl,11'h000};
assign res = res_extnd[11:0];

//the enumerated type for testing
typedef enum logic [1:0] {IDLE,SEND,WAIT,RCV} state_t;
state_t state,nxt_state;

//the flop for the state machine
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		state <= IDLE;
	else
		state <= nxt_state;
end

//the state machine
always_comb begin
	wrt = 0;
	cnv_cmplt_S = 0;
	nxt_state = IDLE;
	case(state)
		IDLE:if(strt_cnv) begin
			nxt_state = SEND;
			wrt = 1;
		end else
			nxt_state = IDLE;

		SEND:if(done)
			nxt_state = WAIT;
		else
			nxt_state = SEND;

		WAIT: begin
			nxt_state = RCV;
			wrt = 1;
		end

		RCV:if(done) begin
			nxt_state = IDLE;
			cnv_cmplt_S = 1;
		end else
			nxt_state = RCV;
	endcase
end

//the set rst flop for cnv_cmplt
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		cnv_cmplt <= 0;
	else if(strt_cnv)
		cnv_cmplt <= 0;
	else if(cnv_cmplt_S)
		cnv_cmplt <= 1;
end

endmodule
