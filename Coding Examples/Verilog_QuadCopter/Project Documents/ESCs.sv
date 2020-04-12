module ESCs(frnt, bck, lft, rght, frnt_spd, bck_spd, lft_spd, rght_spd, motors_off, clk, rst_n);

// see slide 43 of the project spec for diagram
// will have to add an edited version of ESC_interface to project for testing
localparam FRNT_OFF = 10'h220;
localparam BCK_OFF = 10'h220;
localparam LFT_OFF = 10'h220;
localparam RGHT_OFF = 10'h220;

input logic [10:0] frnt_spd, bck_spd, lft_spd, rght_spd;
input logic motors_off;
input wire clk, rst_n;

output logic frnt, bck, lft, rght;

logic [10:0] SPEED_frnt, SPEED_bck, SPEED_lft, SPEED_rght;
logic [9:0] frnt_off, bck_off, lft_off, rght_off;

// set SPEED input for each ESC, really uses an nAND
assign SPEED_frnt = motors_off ? 11'h000 : frnt_spd;
assign SPEED_bck = motors_off ? 11'h000 : bck_spd;
assign SPEED_lft = motors_off ? 11'h000 : lft_spd;
assign SPEED_rght = motors_off ? 11'h000 : rght_spd;

// set OFF input for each ESC, also uses nAND
assign frnt_off = motors_off ? 10'h000 : FRNT_OFF;
assign bck_off = motors_off ? 10'h000 : BCK_OFF;
assign lft_off = motors_off ? 10'h000 : LFT_OFF;
assign rght_off = motors_off ? 10'h000 : RGHT_OFF;

// instantiate ESC_interface (edited to take width of period counter as a parameter)
// use 18 as period counter width for faster simulation, and 20 for the "real"
ESC_interface #(18) ESC_interface_frnt(.clk(clk), .rst_n(rst_n), .PWM(frnt), .OFF(frnt_off), .SPEED(SPEED_frnt));
ESC_interface #(18) ESC_interface_bck(.clk(clk), .rst_n(rst_n), .PWM(bck), .OFF(bck_off), .SPEED(SPEED_bck));
ESC_interface #(18) ESC_interface_lft(.clk(clk), .rst_n(rst_n), .PWM(lft), .OFF(lft_off), .SPEED(SPEED_lft));
ESC_interface #(18) ESC_interface_rght(.clk(clk), .rst_n(rst_n), .PWM(rght), .OFF(rght_off), .SPEED(SPEED_rght));


endmodule
