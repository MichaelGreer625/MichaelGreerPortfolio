#include "io_expander.h"



bool io_expander_init(void){
	initializeI2CMaster(I2C1_BASE);
	io_expander_write_reg(MCP23017_IODIRA_R, 0x00);
	io_expander_write_reg(MCP23017_IODIRB_R, 0xFF);
	io_expander_write_reg(MCP23017_GPPUB_R, 0xFF);
}




void io_expander_write_reg(uint8_t reg, uint8_t data){
			
	 i2c_status_t status;
  
  // Before doing anything, make sure the I2C device is idle
  while ( I2CMasterBusy(I2C1_BASE)) {};

  //==============================================================
  // Set the I2C address to be the EEPROM
	// ADD CODE
  //==============================================================
	status = i2cSetSlaveAddr(I2C1_BASE, MCP23017_DEV_ID, I2C_WRITE);
  
	
	i2cSendByte(
     I2C1_BASE,
     reg,
     I2C_MCS_START | I2C_MCS_RUN
			);
		
	i2cSendByte(
     I2C1_BASE,
     data,
     I2C_MCS_RUN | I2C_MCS_STOP
			);
		
}
uint8_t io_expander_read_reg(uint8_t reg, uint8_t *data) {
	
		 i2c_status_t status;
  
  // Before doing anything, make sure the I2C device is idle
  while ( I2CMasterBusy(I2C1_BASE)) {};

  //==============================================================
  // Set the I2C address to be the EEPROM
	// ADD CODE
  //==============================================================
	status = i2cSetSlaveAddr(I2C1_BASE, MCP23017_DEV_ID, I2C_WRITE);
  

		i2cSendByte(
     I2C1_BASE,
     reg,
     I2C_MCS_START | I2C_MCS_RUN
		);

  //==============================================================
  // Set the I2C slave address to be the EEPROM and in Read Mode
	// ADD CODE
  //==============================================================

		status = i2cSetSlaveAddr(I2C1_BASE, MCP23017_DEV_ID, I2C_READ);

  //==============================================================
  // Read the data returned by the EEPROM
	// ADD CODE
  //==============================================================
  
	i2cGetByte(
  I2C1_BASE, 
  data, 
  I2C_MCS_START | I2C_MCS_RUN | I2C_MCS_STOP
	);
		


	}

bool isDetPressed(void){
	uint8_t datatho;
	io_expander_read_reg(MCP23017_GPIOB_R, &datatho);
	if(datatho & 0x02)
		return false;
	else
		return true;
	
}

void displayLED(uint8_t numLEDS){
	
	uint8_t mask;
	if(numLEDS > 8)
			mask = 0xFF;
	else
		mask = 0xFF >> (8 - numLEDS);
	io_expander_write_reg(MCP23017_GPIOA_R, mask);
}