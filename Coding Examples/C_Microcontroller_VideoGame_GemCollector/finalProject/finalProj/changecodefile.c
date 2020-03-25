/*

void tic_tac_toe_update_game_board_opp(PS2_DIR_t direction)
{		
	//storing the previous location for later
	int prev_opprow;
	int prev_oppcol;
	prev_opprow = opprow;
	prev_oppcol = oppcol;
	
	
	
	//center position/initial position??????
	if(direction == PS2_DIR_INIT){
		if(current_player == X_ENTRY)
			draw_specific_square(opprow, oppcol, X_WIDTH, X_WIDTH, Bitmaps_X, LCD_PLAYER1_oppcolOR, LCD_BG_oppcolOR	 );
		else
			draw_specific_square(opprow, oppcol, X_WIDTH, X_WIDTH, Bitmaps_O, LCD_PLAYER1_oppcolOR , LCD_BG_oppcolOR	 );
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
								if(current_player == X_ENTRY)
									draw_specific_square(prev_opprow, prev_oppcol, X_WIDTH, X_WIDTH, Bitmaps_X, BG_oppcolOR_X , BG_oppcolOR_X );
								else 
									draw_specific_square(prev_opprow, prev_oppcol, X_WIDTH, X_WIDTH, Bitmaps_O, BG_oppcolOR_O , BG_oppcolOR_O );
								break;
			case O_ENTRY:
								draw_specific_square(prev_opprow, prev_oppcol, X_WIDTH, X_WIDTH, Bitmaps_O, FG_oppcolOR_O , BG_oppcolOR_O );
								break;
			case X_ENTRY:
								draw_specific_square(prev_opprow, prev_oppcol, X_WIDTH, X_WIDTH, Bitmaps_X, FG_oppcolOR_X , BG_oppcolOR_X );
								break;
		}
			
		//drawing current location's new picture as claimed or unclaimed
		switch(game_board[opprow][oppcol]){
			case NONE:
								if(current_player == X_ENTRY)
									draw_specific_square(opprow, oppcol, X_WIDTH, X_WIDTH, Bitmaps_X, LCD_PLAYER1_oppcolOR , LCD_BG_oppcolOR);
								else
									draw_specific_square(opprow, oppcol, X_WIDTH, X_WIDTH, Bitmaps_O, LCD_PLAYER1_oppcolOR , LCD_BG_oppcolOR);
								break;
			case O_ENTRY:
								draw_specific_square(opprow, oppcol, X_WIDTH, X_WIDTH, Bitmaps_O, FG_oppcolOR_CLAIMED , LCD_BG_oppcolOR);
								break;				
			case X_ENTRY:
								draw_specific_square(opprow, oppcol, X_WIDTH, X_WIDTH, Bitmaps_X, FG_oppcolOR_CLAIMED , LCD_BG_oppcolOR);
								break;			
		}
	}
	return;
}
*/