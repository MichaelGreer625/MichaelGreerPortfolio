////////////////////////////////////////////////////////////////////////////////
// Main File:        MasterGameLoop.c
//
// Author:           Michael Greer
// Email:            mgreer2@madison.wisc.edu
// CS Login:         greer
//
/////////////////////////// OTHER SOURCES OF HELP //////////////////////////////
//                   fully acknowledge and credit all sources of help,
//                   other than Instructors and TAs.
//
// Persons:          Identify persons by name, relationship to you, and email.
//                   Describe in detail the the ideas and help they provided.
//
// Online sources:   avoid web searches to solve your problems, but if you do
//                   search, be sure to include Web URLs and description of 
//                   of any information you find.
////////////////////////////////////////////////////////////////////////////////

#include "main.h"
#include "hw3_lib.h"


bool testing = false;


//defalt value, dont change.
bool MASTER = false;
int packetsSent  = 0;
int packetsRecieved = 0;


uint8_t MmyID[]      = { 3,5,3,6,8};
uint8_t MremoteID[]  = { 3,5,3,8,6};

uint8_t SmyID[]      = { 3,5,3,8,6};
uint8_t SremoteID[]  = { 3,5,3,6,8};


void initializeBoard(void)
{
  DisableInterrupts();
  init_serial_debug(true, true);
	ft6x06_init();
  spi_select_init();
  spi_select(NORDIC);
  wireless_initialize();
  SysTick_Config(10000000);
  EnableInterrupts();
}


//*****************************************************************************
//*****************************************************************************
int 
main(void)
{

	
	
  uint16_t x,y;
  
  TTT_GAME_STATUS_t game_status = ONGOING;
  TTT_SQUARE_STATUS_t starting_letter = O_ENTRY;
  
	wireless_com_status_t status;
	uint32_t data = 0;
	uint32_t gotData = 0;
	
	bool ispressed;
	
	
  int i = 0;
  bool validate;
	int mainscreenx, mainscreeny;
  ece353_hw3_init_serial();
	initializeBoard();
  tic_tac_toe_hw_init();
	configWatchdog();
	
	
	displayLED(3);

	

	////////////////////////////////////
	/////////MAINSCREEN LOOP////////////
	////////////////////////////////////
	MainScreenLoop();
	
	//enableWatchdog();
	
	//MASTER has now been set by the main screen loop and now we 
	//can configure the wireless devices.
	if(MASTER)
		wireless_configure_device(MmyID, MremoteID );
	else
		wireless_configure_device(SmyID, SremoteID );
	
	
	/////////////////////////////////////
	//INIT THE GAME BOARD AND VARIABLES//
	/////////////////////////////////////
	tic_tac_toe_game_init(starting_letter);
	

  // Reach infinite loop
  while(1){
   	if( one_second_passed()){
			clock_test();	
		}
				
		
	
	if(MASTER_SEND){
		
		status = wireless_send_32(true, true, 0xffff);
		packetsSent++;
		printf("-----------------------\n");
		printf("Sent: %d\n\r", 0xffff);
		printf("Error Message: %s\n\r",wireless_error_messages[status]);
		printf("-----------------------\n");
		MASTER_SEND = false;
		
		
		//break down the recieved data here.
		//tic_tac_toe_update_game_board(Recieved_Direction);
		//update scores and timer.	
	}
	
	if(MASTER_RECIEVE){
		status = wireless_get_32(true, &gotData);
		packetsRecieved++;
		recievedData = gotData;
		printf("-----------------------\n");
		printf("Received: %d\n\r", gotData);
		printf("Error Message: %s\n\r",wireless_error_messages[status]);
		printf("-----------------------\n");
		MASTER_RECIEVE = false;
	}
		
	if(SLAVE_RECIEVE){
		status = wireless_get_32(true, &gotData);
		packetsRecieved++;
		recievedData = gotData;
		printf("-----------------------\n");
		printf("Received: %d\n\r", gotData);
		printf("Error Message: %s\n\r",wireless_error_messages[status]);
		printf("-----------------------\n");

		
		status = wireless_send_32(true, true, 0x0006);
		packetsSent++;
		printf("-----------------------\n");
		printf("Sent: %d\n\r", 0x0006);
		printf("Error Message: %s\n\r",wireless_error_messages[status]);
		printf("-----------------------\n");
		SLAVE_RECIEVE = false;
	}
	
	
	if(AlertOneSec){
		petWatchDog();
		tic_tac_toe_update_game_board(Send_Direction);
		tic_tac_toe_update_game_board_opp(Send_Direction);
			//do checking logic here to see if you add points for gathering gems.
			//get the send data packeted up
			//then send the data	
		if(MASTER & !testing)
			MASTER_SEND = true;
		
		
		AlertOneSec = false;
		Send_Direction = PS2_DIR_CENTER;
	}
	
		
		
		
		
		
		
    if( tic_tac_toe_sample_ready())
    { 
      // Read the ADC to determine the position of the PS2 Joystick
      x = ps2_get_x();
      y = ps2_get_y();
      

      // Get the current direction the Joystick has been pressed.
      // The valid directions are UP, DOWN, LEFT, RIGHT, and CENTER.
      Current_Direction = tic_tac_toe_return_direction(x,y);
      
      // Only update the screen if the current direction and previous
      // direction were not the same.
      if( Current_Direction != Previous_Direction)
      {
				
				
				if(Current_Direction != PS2_DIR_CENTER){
					Send_Direction = Current_Direction;
				}
				
				if(MULTIPLAYER){
					Send_Direction = Current_Direction;
				}else
					//tic_tac_toe_update_game_board(Current_Direction);
        
        Previous_Direction = Current_Direction;
      }
      
      // Check to see if SW2 was pressed.  If it was, log the 
      // entry from the current player.  Check to see if the resulting
      // move wins the game or results in a tie.  
      //
      // If the game ends, print out the corresponding message to the user
      // and wait until the user presses SW2.  Pressing SW2 should reset the
      // game.  Be sure to switch the player, X or O, that begins each game.
      if( tic_tac_toe_sw2_pressed())
      {
        tic_tac_toe_claim_square();
        
        //game_status = tic_tac_toe_check_for_win();
        
				
        if( game_status != ONGOING)
        {
          if(game_status == X_WINNER)
          {
            ece353_hw3_lcd_X_wins();
          }
          else if ( game_status == O_WINNER)
          {
            ece353_hw3_lcd_O_wins();
          }
          
          else
          {
            ece353_hw3_lcd_tie();
          }
          
          while(!tic_tac_toe_sw2_pressed()){
            // busy wait
          };
          
          if(starting_letter == O_ENTRY)
          {
            starting_letter = X_ENTRY;
          }
          else
          {
            starting_letter = O_ENTRY;
          }
          
          tic_tac_toe_game_init(starting_letter);
          
        }
				
      }
    }
      
  }
}

void programEPROM( uint16_t addr, char *filename){
	
	
	
	  FILE *fptr;
		char c;
    //char filename[100], c;
 
    // Open file
    fptr = fopen(filename, "r");
    if (fptr == NULL)
    {
        printf("Cannot open file \n");
        exit(0);
    }
 
    // Read contents from file
    c = fgetc(fptr);
    while (c != EOF)
    {
        printf ("%c", c);
				eeprom_byte_write(I2C1_BASE,addr, c);
				addr++;

        c = fgetc(fptr);
    }
 
    fclose(fptr);
	
	
	
	
  
}
	
void readEPROM( uint16_t addr){
	
	
	uint8_t c;
		
 
		eeprom_byte_read(I2C1_BASE,addr, &c);
    while (c != 0xf)
    {
        printf ("%c", c);
				eeprom_byte_read(I2C1_BASE,addr, &c);
				addr++;

        eeprom_byte_read(I2C1_BASE,addr, &c);
    }

}
