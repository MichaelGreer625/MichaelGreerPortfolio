#include "timers.h"


//*****************************************************************************
// Verifies that the base address is a valid GPIO base address
//*****************************************************************************
static bool verify_base_addr(uint32_t base_addr)
{
   switch( base_addr )
   {
     case TIMER0_BASE:
     case TIMER1_BASE:
     case TIMER2_BASE:
     case TIMER3_BASE:
     case TIMER4_BASE:
     case TIMER5_BASE:
     {
       return true;
     }
     default:
     {
       return false;
     }
   }
}

//*****************************************************************************
// Returns the RCGC and PR masks for a given TIMER base address
//*****************************************************************************
static bool get_clock_masks(uint32_t base_addr, uint32_t *timer_rcgc_mask, uint32_t *timer_pr_mask)
{
  // Set the timer_rcgc_mask and timer_pr_mask using the appropriate
  // #defines in ../include/sysctrl.h
  switch(base_addr)
  {
    case TIMER0_BASE:
    {
      *timer_rcgc_mask = SYSCTL_RCGCTIMER_R0;
      *timer_pr_mask = SYSCTL_PRTIMER_R0;
      break;
    }
    case TIMER1_BASE:
    {
      *timer_rcgc_mask = SYSCTL_RCGCTIMER_R1;
      *timer_pr_mask = SYSCTL_PRTIMER_R1;
      break;
    }
    case TIMER2_BASE:
    {
      *timer_rcgc_mask = SYSCTL_RCGCTIMER_R2;
      *timer_pr_mask = SYSCTL_PRTIMER_R2;
      break;
    }
    case TIMER3_BASE:
    {
      *timer_rcgc_mask = SYSCTL_RCGCTIMER_R3;
      *timer_pr_mask = SYSCTL_PRTIMER_R3;
      break;
    }
    case TIMER4_BASE:
    {
      *timer_rcgc_mask = SYSCTL_RCGCTIMER_R4;
      *timer_pr_mask = SYSCTL_PRTIMER_R4;
      break;
    }
    case TIMER5_BASE:
    {
      *timer_rcgc_mask = SYSCTL_RCGCTIMER_R5;
      *timer_pr_mask = SYSCTL_PRTIMER_R5;
      break;
    }
    default:
    {
      return false;
    }
  }
  return true;
}


//*****************************************************************************
// Waits for 'ticks' number of clock cycles and then returns.
//
//The function returns true if the base_addr is a valid general purpose timer
//*****************************************************************************
bool gp_timer_wait(uint32_t base_addr, uint32_t ticks)
{
  TIMER0_Type *gp_timer;
  
  // Verify the base address.
  if ( ! verify_base_addr(base_addr) )
  {
    return false;
  }

  // Type cast the base address to a TIMER0_Type struct
  gp_timer = (TIMER0_Type *)base_addr;

  //*********************    
  // ADD CODE
  //*********************
	
	//setting the timer interval
	gp_timer->TAILR = ticks;
	
	//Acknowldedge (clear) timer A timeout
	gp_timer->ICR |= TIMER_ICR_TATOCINT;
	
	gp_timer->CTL |= TIMER_CTL_TAEN;
	
	//wait until timer times-out
  while(!(gp_timer->RIS & TIMER_RIS_TATORIS));
	
  return true;
}


//*****************************************************************************
// Configure a general purpose timer to be a 32-bit timer.  
//
// Paramters
//  base_address          The base address of a general purpose timer
//
//  mode                  bit mask for Periodic, One-Shot, or Capture
//
//  count_up              When true, the timer counts up.  When false, it counts
//                        down
//
//  enable_interrupts     When set to true, the timer generates and interrupt
//                        when the timer expires.  When set to false, the timer
//                        does not generate interrupts.
//
//The function returns true if the base_addr is a valid general purpose timer
//*****************************************************************************
bool gp_timer_config_32(uint32_t base_addr, uint32_t mode, bool count_up, bool enable_interrupts)
{
  uint32_t timer_rcgc_mask;
  uint32_t timer_pr_mask;
  TIMER0_Type *gp_timer;
  
  // Verify the base address.
  if ( ! verify_base_addr(base_addr) )
  {
    return false;
  }
  
  // get the correct RCGC and PR masks for the base address
  get_clock_masks(base_addr, &timer_rcgc_mask, &timer_pr_mask);
  
  // Turn on the clock for the timer
  SYSCTL->RCGCTIMER |= timer_rcgc_mask;

  // Wait for the timer to turn on
  while( (SYSCTL->PRTIMER & timer_pr_mask) == 0) {};
  
  // Type cast the base address to a TIMER0_Type struct
  gp_timer = (TIMER0_Type *)base_addr;
    
  //*********************    
  // ADD CODE
  //*********************
    //Disabling A and B
		gp_timer->CTL &= ~(TIMER_CTL_TAEN);
		gp_timer->CTL &= ~(TIMER_CTL_TBEN);
		
		//Setting timer size
		gp_timer->CFG = TIMER_CFG_32_BIT_TIMER;
		
		//Clearing mode bits, then setting mode
		gp_timer->TAMR &= ~(TIMER_TAMR_TAMR_M);
    gp_timer->TAMR |= mode;
		
		//setting count up
		if(count_up)
			gp_timer->TAMR |= TIMER_TAMR_TACDIR;
		else
			gp_timer->TAMR &= ~(TIMER_TAMR_TACDIR);
		
		//enabling/disabling timeout interpts
		if(enable_interrupts)
			gp_timer->IMR |= TIMER_IMR_TATOIM;
		else
			gp_timer->IMR &= ~(TIMER_IMR_TATOIM);
		
  return true;  
}

bool gp_timer_config_16(uint32_t base_addr, uint32_t mode, bool count_up, bool enable_interrupts)
{
  uint32_t timer_rcgc_mask;
  uint32_t timer_pr_mask;
  TIMER0_Type *gp_timer;
  
  // Verify the base address.
  if ( ! verify_base_addr(base_addr) )
  {
    return false;
  }
  
  // get the correct RCGC and PR masks for the base address
  get_clock_masks(base_addr, &timer_rcgc_mask, &timer_pr_mask);
  
  // Turn on the clock for the timer
  SYSCTL->RCGCTIMER |= timer_rcgc_mask;

  // Wait for the timer to turn on
  while( (SYSCTL->PRTIMER & timer_pr_mask) == 0) {};
  
  // Type cast the base address to a TIMER0_Type struct
  gp_timer = (TIMER0_Type *)base_addr;
    
  //*********************    
  // ADD CODE
  //*********************
    //Disabling A and B
		gp_timer->CTL &= ~(TIMER_CTL_TAEN);
		gp_timer->CTL &= ~(TIMER_CTL_TBEN);
		
		//Setting timer size
		gp_timer->CFG = TIMER_CFG_16_BIT;
		
		//Clearing mode bits, then setting mode
		gp_timer->TAMR &= ~(TIMER_TAMR_TAMR_M);
    gp_timer->TAMR |= mode;
		
		//setting count up
		if(count_up)
			gp_timer->TAMR |= TIMER_TAMR_TACDIR;
		else
			gp_timer->TAMR &= ~(TIMER_TAMR_TACDIR);
		
		//enabling/disabling timeout interpts
		if(enable_interrupts)
			gp_timer->IMR |= TIMER_IMR_TATOIM;
		else
			gp_timer->IMR &= ~(TIMER_IMR_TATOIM);
		
  return true;  
}

void configWatchdog(void){
	
  WATCHDOG0_Type *WD_timer;
	
	WD_timer = (WATCHDOG0_Type *)WATCHDOG0_BASE;
	
	  // Turn on the clock for the timer
  SYSCTL->RCGCWD |= SYSCTL_RCGCWD_R0;

  // Wait for the timer to turn on
  while( (SYSCTL->PRWD & SYSCTL_PRWD_R0) == 0) {};
		
	WD_timer->LOAD = 0X09896800;
	WD_timer->CTL = 0X02; //TURNS ON BIT 1; 
		
		
	
		
	NVIC_EnableIRQ(WATCHDOG0_IRQn);
	NVIC_SetPriority(WATCHDOG0_IRQn, 1);
}

void enableWatchdog(void){
	WATCHDOG0_Type *WD_timer;
	
	WD_timer = (WATCHDOG0_Type *)WATCHDOG0_BASE;
	WD_timer->CTL |= 0X01;
}
	

void petWatchDog(void){
	WATCHDOG0_Type *WD_timer;
	
	WD_timer = (WATCHDOG0_Type *)WATCHDOG0_BASE;
	WD_timer->LOAD = 0X09896800;
	
}
