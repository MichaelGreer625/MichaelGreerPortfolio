//MICHAEL GREER (MGREER625@GMAIL.COM)
module SPI_mstr16(clk, rst_n, cmd, wrt, MISO, rd_data, done, SS_n, SCLK, MOSI);

input clk, rst_n, wrt, MISO;
input [15:0] cmd;

output SCLK, MOSI;
output [15:0] rd_data;

reg [4:0] sclk_div;
reg MISO_smpl;
reg [15:0] shft_reg;
reg [4:0] count;
output reg SS_n, done;

logic SCLK, SSclr, SSSet, shft, smpl, rst_cnt;
//ASSORTED MEMORY DEVICES
always@(posedge clk)begin
	if(rst_cnt)
		sclk_div <= 5'b10111;
	else
		sclk_div <= sclk_div + 1;

end

always@(posedge clk)begin
	if(smpl)
		MISO_smpl <= MISO;
end

always@(posedge clk)begin
	if(wrt)
		shft_reg <= cmd;
	else if(shft)
		shft_reg <= {shft_reg[14:0], MISO_smpl};

end

always@(posedge clk, negedge rst_n)begin
	if(!rst_n)begin
		SS_n <= 1;
		done <= 0;	
	end
	else if(SSclr)begin
		SS_n <= 0;
		done <= 0;
	end
	else if(SSSet)begin
		SS_n <= 1;	
		done <= 1;
	end

end

always@(posedge clk)begin
	if(SSclr)
		count <= 5'h00;
	else if(smpl)
		count <= count + 1;	

end

assign SCLK = sclk_div[4];
assign MOSI = shft_reg[15];
assign count16 = count[4];
assign rd_data = shft_reg;


typedef enum reg [1:0] {IDLE, FPORCH, NORMAL, BACK} state_t;
state_t state, nextstate;

always@(posedge clk, negedge rst_n)begin
	if(!rst_n)
		state <= IDLE;
	else
		state <= nextstate;

end
//THIS IS SELF EXPLANITORY, STATE MACHINE BELOW.
always_comb begin
	nextstate = IDLE;
	SSclr = 0;
	SSSet = 0;
	smpl = 0;
	shft = 0;
	rst_cnt = 0;

	case(state)
		IDLE: begin
			rst_cnt = 1;
			if(wrt) begin
				SSclr = 1;
				nextstate = FPORCH;
			end
		end
		FPORCH:
			if(sclk_div == 5'b11111)
				nextstate = NORMAL;
			else 
				nextstate = FPORCH;
		NORMAL:
			if(sclk_div == 5'b11111) begin
				shft = 1;
				nextstate = NORMAL;
			end
			else if(sclk_div == 5'b01111) begin
				smpl = 1;
				nextstate = NORMAL;
			end
			else if(count16)
				nextstate = BACK;
			else
				nextstate = NORMAL;
		BACK:
			if(sclk_div == 5'b11101)begin
				SSSet = 1;
				shft = 1;
				nextstate = IDLE;
			end
			else
				nextstate = BACK;
			

	endcase

end









endmodule
