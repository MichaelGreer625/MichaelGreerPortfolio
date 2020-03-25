// Copyright (c) 2015-16, Joe Krachey
// All rights reserved.
//
// Redistribution and use in source or binary form, with or without modification, 
// are permitted provided that the following conditions are met:
//
// 1. Redistributions in source form must reproduce the above copyright 
//    notice, this list of conditions and the following disclaimer in 
//    the documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
// OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#include "tic_tac_toe.h"

char individual_1[] = "Andrew Stuhr";

	//These are variables for gameplay.
	bool MULTIPLAYER = false;
	volatile bool SLAVE_RECIEVE;
	volatile bool MASTER_SEND;
	volatile bool MASTER_RECIEVE;
	volatile bool button_press;
	volatile uint32_t recievedData;
	PS2_DIR_t Send_Direction = PS2_DIR_CENTER;
	PS2_DIR_t Recieved_Direction;
	uint8_t DIRECTION;
	
	uint8_t OPPX, OPPY;
	
	

PS2_DIR_t Current_Direction = PS2_DIR_CENTER;
PS2_DIR_t Previous_Direction = PS2_DIR_CENTER;

volatile uint16_t X_VAL, Y_VAL;
bool ALERT_SAMPLE;
volatile bool SW2_PRESSED;

TTT_SQUARE_STATUS_t game_board[verBlocks][horBlocks];
TTT_SQUARE_STATUS_t current_player;
TTT_SQUARE_STATUS_t opp_player;
int row;
int col;
int opprow;
int oppcol;
int score;
int oppscore;
int press_count;
int one_sec_count = 0;

/*******************************************************************************
* Function Name: tic_tac_toe_hw_init
********************************************************************************
*******************************************************************************/  
void tic_tac_toe_hw_init(void)
{
	GPIOA_Type  *gpioPort;
	//configuring gpio F for SW2
	gpio_enable_port(GPIOF_BASE);
	gpio_config_digital_enable(GPIOF_BASE, SW2_M);
	gpio_config_enable_input(GPIOF_BASE, SW2_M);
	gpio_config_enable_pullup(GPIOF_BASE, SW2_M);
	
	//configuring ps2
	ps2_initialize_hw3();
	
	//configuring timer for the adc conversions.
	gp_timer_config_16(TIMER5_BASE, TIMER_TAMR_TAMR_PERIOD, false, true);
	TIMER5->CTL &= ~(TIMER_CTL_TAEN | TIMER_CTL_TBEN);
	TIMER5->TAILR = 40000;
	TIMER5->TAPR = 0X02;
	TIMER5->ICR |= TIMER_ICR_TATOCINT;
	TIMER5->CTL |= TIMER_CTL_TAEN;
	NVIC_EnableIRQ(TIMER5A_IRQn);
	NVIC_SetPriority(TIMER5A_IRQn, 1);
	
	//configuring timer for the adc conversions.
	gp_timer_config_32(TIMER1_BASE, TIMER_TAMR_TAMR_PERIOD, false, true);
	TIMER5->CTL &= ~(TIMER_CTL_TAEN | TIMER_CTL_TBEN);
	TIMER5->TAILR = 400000000;
	TIMER5->ICR |= TIMER_ICR_TATOCINT;
	TIMER5->CTL |= TIMER_CTL_TAEN;
	NVIC_EnableIRQ(TIMER1A_IRQn);
	NVIC_SetPriority(TIMER1A_IRQn, 1);
	
	//configuring lcd screen
	lcd_config_screen();
	

	
	//this configures the interrupt pin PC7
	gpioPort = (GPIOA_Type*)GPIOC_BASE;
  gpio_enable_port(GPIOC_BASE);
  gpio_config_digital_enable( GPIOC_BASE, 0x80);
  gpio_config_enable_input( GPIOC_BASE, 0x80);
	gpio_config_falling_edge_irq(GPIOC_BASE, 0x80);
	//this enables interrupts for GPIO port C;
	
	
	NVIC_EnableIRQ(GPIOC_IRQn);
	NVIC_SetPriority(GPIOC_IRQn, 1);
	
	io_expander_init();
  return;
}


 /*******************************************************************************
* Function Name: tic_tac_toe_game_init
********************************************************************************
*******************************************************************************/ 
void tic_tac_toe_game_init(TTT_SQUARE_STATUS_t active_player)
{
	//initialize each square's entry to null (unfilled)
	int i;
	int j;
	int x_line;
	int y_line;
	for(i = 0; i < verBlocks; i++){
		for(j = 0; j < horBlocks; j++)
			game_board[i][j] = NONE;
	}
	
	//set global alerts to false
	ALERT_SAMPLE = false;
	SW2_PRESSED = false;
	
	//starting location is the center of the board
	row = 2;
	col = 2;
	
	opprow = 3;
	oppcol = 4;
	
	//initially no presses, counts up to 9 to check tie
	press_count = 0;
	
	//deciding which player goes first
	current_player = active_player;
	opp_player = active_player;
  //clears to bown
  lcd_clear_screen(LCD_BG_COLOR);
  
  //vertical lines
	for(i = 1; i < horBlocks; i ++){
		x_line = i*horPixels;
		 lcd_draw_rectangle_centered(x_line, finalWidth, SCREEN_CENTER_Y, Y_LINE_LENGTH, LCD_LINE_COLOR);
	}
	
  //horizontal lines
	for(i = 1; i < verBlocks; i ++){
		y_line = i*verPixels;
		 lcd_draw_rectangle_centered(SCREEN_CENTER_X, X_LINE_LENGTH, y_line,finalWidth,LCD_LINE_COLOR);
	}
	
	//TESTING: see where "bottome of screen" line appears
	//lcd_draw_rectangle_centered(SCREEN_CENTER_X, X_LINE_LENGTH, 319,finalWidth,LCD_LINE_COLOR);
	

	//Draw top bar to indicate score, time, future steal times, etc.
	lcd_draw_rectangle_centered(SCREEN_CENTER_X, X_LINE_LENGTH, verPixels * 1/2, verPixels ,LCD_LINE_COLOR);
	lcd_draw_rectangle_centered(SCREEN_CENTER_X, X_LINE_LENGTH - 2*finalWidth, verPixels * 1/2, verPixels - 2*finalWidth, LCD_COLOR_BLACK);
	
	//TEST: drawing a gem
	draw_specific_square_2(5, 5, X_WIDTH, X_WIDTH, OrangeGemOutside, OrangeGemInside, LCD_COLOR_BLACK, LCD_COLOR_ORANGE, LCD_BG_COLOR);

	//TEST: draw a 0 in top right
	draw_specific_square(0, 4, X_WIDTH, X_WIDTH, timer_zero, LCD_COLOR_WHITE, LCD_COLOR_BLACK);
	
	//draws first symbol in middle of board
  tic_tac_toe_update_game_board(PS2_DIR_INIT);
	tic_tac_toe_update_game_board_opp(PS2_DIR_INIT);
	
}


/*******************************************************************************
* Function Name: tic_tac_toe_update_game_board.
********************************************************************************
*******************************************************************************/
void tic_tac_toe_update_game_board(PS2_DIR_t direction)
{		
	//storing the previous location for later
	int prev_row;
	int prev_col;
	prev_row = row;
	prev_col = col;
	
	
	
	//center position/initial position??????
	if(direction == PS2_DIR_INIT){
		if(current_player == X_ENTRY)
			draw_specific_square(row, col, X_WIDTH, X_WIDTH, Bitmaps_X, LCD_PLAYER1_COLOR, LCD_BG_COLOR	 );
		else
			draw_specific_square(row, col, X_WIDTH, X_WIDTH, Bitmaps_O, LCD_PLAYER1_COLOR , LCD_BG_COLOR	 );
		return;
	}
			
	//move location based off ps2 direction (if possible)
	else if((direction == PS2_DIR_UP) && (row > 1))
		row--;

	else if((direction == PS2_DIR_DOWN) && (row < verBlocks-1))
		row++;
	
	else if((direction == PS2_DIR_LEFT) && (col > 0))
		col--;
	
	else if((direction == PS2_DIR_RIGHT) && (col < horBlocks-1))
		col++;
		
		
	//if change in position occurs, update new background and overwrite old background
	if((prev_row != row) || (prev_col != col)){
		
		//"clearing" previous location's picture by drawing it's value (blank, x, or or)
		switch(game_board[prev_row][prev_col]){
			case NONE:
								if(current_player == X_ENTRY)
									draw_specific_square(prev_row, prev_col, X_WIDTH, X_WIDTH, Bitmaps_X, BG_COLOR_X , BG_COLOR_X );
								else 
									draw_specific_square(prev_row, prev_col, X_WIDTH, X_WIDTH, Bitmaps_O, BG_COLOR_O , BG_COLOR_O );
								break;
			case O_ENTRY:
								draw_specific_square(prev_row, prev_col, X_WIDTH, X_WIDTH, Bitmaps_O, FG_COLOR_O , BG_COLOR_O );
								break;
			case X_ENTRY:
								draw_specific_square(prev_row, prev_col, X_WIDTH, X_WIDTH, Bitmaps_X, FG_COLOR_X , BG_COLOR_X );
								break;
		}
			
		//drawing current location's new picture as claimed or unclaimed
		switch(game_board[row][col]){
			case NONE:
								if(current_player == X_ENTRY)
									draw_specific_square(row, col, X_WIDTH, X_WIDTH, Bitmaps_X, LCD_PLAYER1_COLOR , LCD_BG_COLOR);
								else
									draw_specific_square(row, col, X_WIDTH, X_WIDTH, Bitmaps_O, LCD_PLAYER1_COLOR , LCD_BG_COLOR);
								break;
			case O_ENTRY:
								draw_specific_square(row, col, X_WIDTH, X_WIDTH, Bitmaps_O, FG_COLOR_CLAIMED , LCD_BG_COLOR);
								break;				
			case X_ENTRY:
								draw_specific_square(row, col, X_WIDTH, X_WIDTH, Bitmaps_X, FG_COLOR_CLAIMED , LCD_BG_COLOR);
								break;			
		}
	}
	return;
}

void tic_tac_toe_update_game_board_opp(PS2_DIR_t direction)
{		
	//storing the previous location for later
	int prev_opprow;
	int prev_oppcol;
	prev_opprow = opprow;
	prev_oppcol = oppcol;
	
	
	
	//center position/initial position??????
	if(direction == PS2_DIR_INIT){
		if(opp_player == X_ENTRY)
			draw_specific_square(opprow, oppcol, X_WIDTH, X_WIDTH, Bitmaps_X, LCD_PLAYER1_COLOR, LCD_BG_COLOR	 );
		else
			draw_specific_square(opprow, oppcol, X_WIDTH, X_WIDTH, Bitmaps_O, LCD_PLAYER1_COLOR , LCD_BG_COLOR	 );
		return;
	}
			
	//move location based off ps2 direction (if possible)
	else if((direction == PS2_DIR_UP) && (opprow > 1))
		opprow--;

	else if((direction == PS2_DIR_DOWN) && (opprow < verBlocks-1))
		opprow++;
	
	else if((direction == PS2_DIR_LEFT) && (oppcol > 0))
		oppcol--;
	
	else if((direction == PS2_DIR_RIGHT) && (oppcol < horBlocks-1))
		oppcol++;
		
		
	//if change in position occurs, update new background and overwrite old background
	if((prev_opprow != opprow) || (prev_oppcol != oppcol)){
		
		//"clearing" previous location's picture by drawing it's value (blank, x, or or)
		switch(game_board[prev_opprow][prev_oppcol]){
			case NONE:
								//This clear the spot if its empty, check the colors.
								if(opp_player == X_ENTRY)
									draw_specific_square(prev_opprow, prev_oppcol, X_WIDTH, X_WIDTH, Bitmaps_X, BG_COLOR_X , BG_COLOR_X );
								else 
									draw_specific_square(prev_opprow, prev_oppcol, X_WIDTH, X_WIDTH, Bitmaps_O, BG_COLOR_O , BG_COLOR_O );
								break;
			case O_ENTRY:
								draw_specific_square(prev_opprow, prev_oppcol, X_WIDTH, X_WIDTH, Bitmaps_O, FG_COLOR_O , BG_COLOR_O );
								break;
			case X_ENTRY:
								draw_specific_square(prev_opprow, prev_oppcol, X_WIDTH, X_WIDTH, Bitmaps_X, FG_COLOR_X , BG_COLOR_X );
								break;
		}
			
		//drawing current location's new picture as claimed or unclaimed
		switch(game_board[opprow][oppcol]){
			case NONE:
								if(opp_player == X_ENTRY)
									draw_specific_square(opprow, oppcol, X_WIDTH, X_WIDTH, Bitmaps_X, LCD_PLAYER1_COLOR , LCD_BG_COLOR);
								else
									draw_specific_square(opprow, oppcol, X_WIDTH, X_WIDTH, Bitmaps_O, LCD_PLAYER1_COLOR , LCD_BG_COLOR);
								break;
			case O_ENTRY:
								draw_specific_square(opprow, oppcol, X_WIDTH, X_WIDTH, Bitmaps_O, FG_COLOR_CLAIMED , LCD_BG_COLOR);
								break;				
			case X_ENTRY:
								draw_specific_square(opprow, oppcol, X_WIDTH, X_WIDTH, Bitmaps_X, FG_COLOR_CLAIMED , LCD_BG_COLOR);
								break;			
		}
	}
	return;
}

/*******************************************************************************
* Function Name: tic_tac_toe_check_for_win
********************************************************************************
*******************************************************************************/
TTT_GAME_STATUS_t tic_tac_toe_check_for_win(void)
{
	/*
	if(		//O Combinations
				((game_board[0][0] == O_ENTRY) && (game_board[1][0] == O_ENTRY) && (game_board[2][0] == O_ENTRY))	//left column
		||	((game_board[0][1] == O_ENTRY) && (game_board[1][1] == O_ENTRY) && (game_board[2][1] == O_ENTRY))	//middle column
		||	((game_board[0][2] == O_ENTRY) && (game_board[1][2] == O_ENTRY) && (game_board[1][2] == O_ENTRY))	//right column
		||	((game_board[0][0] == O_ENTRY) && (game_board[0][1] == O_ENTRY) && (game_board[0][2] == O_ENTRY))	//top row	
		||	((game_board[1][0] == O_ENTRY) && (game_board[1][1] == O_ENTRY) && (game_board[1][2] == O_ENTRY))	//middle row	
		||	((game_board[2][0] == O_ENTRY) && (game_board[2][1] == O_ENTRY) && (game_board[2][2] == O_ENTRY))	//bottom row	
		||	((game_board[0][0] == O_ENTRY) && (game_board[1][1] == O_ENTRY) && (game_board[2][2] == O_ENTRY))	//middle row	
		||	((game_board[0][2] == O_ENTRY) && (game_board[1][1] == O_ENTRY) && (game_board[2][0] == O_ENTRY))	//bottom row	
		)
		return O_WINNER;
	
			//X Combinations
	if(		
				((game_board[0][0] == X_ENTRY) && (game_board[1][0] == X_ENTRY) && (game_board[2][0] == X_ENTRY))	//left column
		||	((game_board[0][1] == X_ENTRY) && (game_board[1][1] == X_ENTRY) && (game_board[2][1] == X_ENTRY))	//middle column
		||	((game_board[0][2] == X_ENTRY) && (game_board[1][2] == X_ENTRY) && (game_board[1][2] == X_ENTRY))	//right column
		||	((game_board[0][0] == X_ENTRY) && (game_board[0][1] == X_ENTRY) && (game_board[0][2] == X_ENTRY))	//top row	
		||	((game_board[1][0] == X_ENTRY) && (game_board[1][1] == X_ENTRY) && (game_board[1][2] == X_ENTRY))	//middle row	
		||	((game_board[2][0] == X_ENTRY) && (game_board[2][1] == X_ENTRY) && (game_board[2][2] == X_ENTRY))	//bottom row	
		||	((game_board[0][0] == X_ENTRY) && (game_board[1][1] == X_ENTRY) && (game_board[2][2] == X_ENTRY))	//middle row	
		||	((game_board[0][2] == X_ENTRY) && (game_board[1][1] == X_ENTRY) && (game_board[2][0] == X_ENTRY))	//bottom row	
		)
			return X_WINNER;
	
	//board is filled and no winner
	if(press_count == 9)
		return TIE;
	
	//default
  return ONGOING;
	*/
}


/*******************************************************************************
* Function Name: tic_tac_toe_sw2_pressed
********************************************************************************
*******************************************************************************/
bool tic_tac_toe_sw2_pressed(void)
{
	if(!SW2_PRESSED)
		return false;
	
	SW2_PRESSED = false;
	return true;
}

/*******************************************************************************
* Function Name: tic_tac_toe_return_direction.
********************************************************************************
*******************************************************************************/
PS2_DIR_t tic_tac_toe_return_direction(uint16_t ps2_x, uint16_t ps2_y)
{
	uint16_t lower_bound =  508;	//0.41V
	uint16_t upper_bound =  3227;	//2.60V
	
	if(ps2_x > upper_bound)
		return PS2_DIR_LEFT;
	
	if(ps2_x < lower_bound)
		return PS2_DIR_RIGHT;
			
	if(ps2_y > upper_bound)
		return PS2_DIR_UP;
		
	if(ps2_y < lower_bound)
		return PS2_DIR_DOWN;
	
  return PS2_DIR_CENTER;	//default
}


/*******************************************************************************
* Function Name: tic_tac_toe_claim_square
********************************************************************************
*******************************************************************************/
void tic_tac_toe_claim_square(void)
{
	/*
	//game board must be clear (NONE) to claim it
	if(game_board[row][col] == NONE){	
		game_board[row][col] = current_player;
		press_count++;
		
		//draw picture of claimed square and switch current_player
		if(current_player == O_ENTRY){
			draw_specific_square(row, col, O_ENTRY, Bitmaps_O, FG_COLOR_CLAIMED  , BG_COLOR_CLAIMED );
			current_player = X_ENTRY;
		}
		else{
			draw_specific_square(row, col, X_ENTRY, Bitmaps_X, FG_COLOR_CLAIMED  , BG_COLOR_CLAIMED );
			current_player = O_ENTRY;
		}
	}
	*/
}

/*******************************************************************************
* Function Name: tic_tac_toe_sample_ready
********************************************************************************
*******************************************************************************/
bool tic_tac_toe_sample_ready(void)
{
	//sample isn't ready
	if(ALERT_SAMPLE == false)
		return false;
	
	//sample is ready, clear it 
	ALERT_SAMPLE = false;
	return true;
}

bool one_second_passed(void){
	if(one_sec_count < 2999)
		return false;
	one_sec_count = 0;
	return true;
}

void clock_test(void){
	draw_specific_square_2(2, 4, X_WIDTH, X_WIDTH, OrangeGemOutside, OrangeGemInside, LCD_COLOR_BLACK, LCD_COLOR_ORANGE, LCD_BG_COLOR);
}


void ADC0SS2_Handler(void){
	//getting x and y values
	X_VAL = ADC0->SSFIFO2;
	Y_VAL = ADC0->SSFIFO2;
	
	//clearing the interupt
	ADC0->ISC = ADC_ISC_IN2;
	return;
}

void TIMER5A_Handler(void){
	static int countttt = 1;
	ADC0->SSMUX2 = (PS2_X_ADC_CHANNEL | PS2_Y_ADC_CHANNEL << 4);
	ADC0->ACTSS |= ADC_ACTSS_ASEN2;
	ADC0->PSSI = ADC_PSSI_SS2;
	TIMER5->ICR |= TIMER_ICR_TATOCINT;	//clear
	SW2_PRESSED = SW2_debounce();
	ALERT_SAMPLE = true;
	one_sec_count++;
	//countttt++;
	//printf("%d\n", countttt);
	
	return;
}

void TIMER1A_Handler(void){
	printf("Packets sent: %d\n", packetsSent);
	printf("Packets recieved\n: %d\n", packetsRecieved);
	return;
}


bool SW2_debounce(void){
	//countZeros will incriment to 7, sw2Value stores button press
	static int countZeros = 0;
	int sw2Value;
 
	//setting sw2Value
  if( (GPIOF->DATA & 0x01) == 0)
     sw2Value = 0;
	else
		sw2Value = 1;
	
	//deciding whether to reset, increment, or saturate countZeros
	if(sw2Value == 1)
		countZeros = 0;
	else if(countZeros < 8)
		countZeros++;
	
	//returning true if countZero is saturated (seven 0's in a row
	if(countZeros == 7)
		return true;
	else
		return false;
}

void draw_specific_square(int position_row, int position_col, uint16_t image_width, uint16_t image_height, const uint8_t *image, uint16_t fColor, uint16_t bColor){
		int x_center;
		int y_center;
	
			
		//calculation x and y based off row and col
		x_center = position_col * horPixels + horPixels/2;
		y_center = position_row * verPixels + verPixels/2;
		
		//drawing background and player image
		lcd_draw_rectangle_centered(x_center, SQUARE_SIZE, y_center, SQUARE_SIZE, bColor);
		lcd_draw_image(x_center, image_width, y_center, image_height, image, fColor, bColor);		
}

void draw_specific_square_2(int position_row, int position_col, uint16_t image_width, uint16_t image_height, const uint8_t *image1, const uint8_t *image2, uint16_t fColor1, uint16_t fColor2, uint16_t bColor){
		int x_center;
		int y_center;
			
		//calculation x and y based off row and col
		x_center = position_col * horPixels + horPixels/2;
		y_center = position_row * verPixels + verPixels/2;
		
		//drawing background and player image
		lcd_draw_rectangle_centered(x_center, SQUARE_SIZE, y_center, SQUARE_SIZE, bColor);
		lcd_draw_image_2(x_center, image_width, y_center, image_height, image1, image2, fColor1, fColor2, bColor);				
}

void GPIOC_Handler (void){
	GPIOA_Type  *gpioPort;
	gpioPort = (GPIOA_Type*)GPIOC_BASE;
	
	if(MASTER)
		MASTER_RECIEVE = true;
	else
		SLAVE_RECIEVE = true;
	
	//printf("hello");
	gpioPort->ICR = 0x80;
	
}

bool checkPosTouch (int x1, int x2, int y1, int y2){
	uint16_t x, y;
	uint8_t touchPoints;
	bool xtrue, ytrue;
	
	
	x = ft6x06_read_x();
	y = ft6x06_read_y();
	x &= 0x0fff;
	y &= 0x0fff;
	x = 240 - x;
	y = 320 - y;
	if(x >= x1 && x <= x2)
		xtrue = true;
	else
		xtrue = false;
	
	if(y >= y1 && y <= y2)
		ytrue = true;
	else
		ytrue = false;
	
	if(xtrue && ytrue)
		return true;
	else 
		return false;
}



void MainScreenLoop (void){
	bool MAINSCREEN = true;
	lcd_clear_screen(LCD_COLOR_ORANGE);
	//we disable interrupts because we do not want one board to 
	//start sending packets to the other prematurely. so we go
	//into an idle state while we decide who is master and 
	//who is the slave.
	DisableInterrupts();
	while(MAINSCREEN){
		if(ft6x06_read_td_status() >=1){
			if(checkPosTouch(0, 240, 0, 160)){
				MASTER = true;
				MAINSCREEN = false;
				printf("master");
			}else if(checkPosTouch(0, 240, 161, 320)){
				MASTER = false;
				MAINSCREEN = false;
				printf("slave");
			}
		}
		

		
		
	}
	EnableInterrupts();
}
