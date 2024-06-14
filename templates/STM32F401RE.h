
#ifndef STM32F401RE_H
  #define STM32F401RE_H   1

  /**
 * @file Header containing various addresses for the stm32F401 line
 * of microconrollers
 * 
 * */

  /**
   * @brief BOOT modes
   * */

  #define BOOT_FLASH			0b01
  #define BOOT_SRAM				0b10
  #define BOOT_SYSMEM			0b11
  

  /**
   * @brief memory layout section
   * */

  #define ADDR_SRAM 			0x20000000UL
  #define ADDR_SYSMEM 		0X1FFF0000UL
  #define RESERVED 	 			0X08040000UL
  #define ADDR_FLASH 			0x08000000UL
  // #define RESERVED 				0X00000000UL

  #define VEC_TABLE_ADDR	ADDR_FLASH

  /**
   * @brief Flash sectors
   * */

  #define ADDR_SECTOR7		0x08060000UL
  #define ADDR_SECTOR6		0x08040000UL
  #define ADDR_SECTOR5		0x08020000UL
  #define ADDR_SECTOR4		0x08010000UL
  #define ADDR_SECTOR3		0x0800C000UL
  #define ADDR_SECTOR2		0x08008000UL
  #define ADDR_SECTOR1		0x08004000UL
  #define ADDR_SECTOR0		0x08000000UL


  /**
   * @brief Peripheral addresses
   * */

  /*   BUS: AHB2   */
  #define ADDR_OTG_FS		0x50000000UL
  /*  BUS: AHB1  */
  #define ADDR_DM2			0x40026400UL
  #define ADDR_DM1			0x40026000UL
  #define ADDR_FIR			0x40023C00UL
  #define ADDR_RCC			0x40023800UL
  #define ADDR_CRC			0x40023000UL
  #define ADDR_GPIOH		0x40021C00UL
  #define ADDR_GPIOE		0x40021000UL
  #define ADDR_GPIOD		0x40020C00UL
  #define ADDR_GPIOC		0x40020800UL
  #define ADDR_GPIOB		0x40020400UL
  #define ADDR_GPIOA		0x40020000UL
  /*   BUS: APB2  */
  #define ADDR_TIM11		0X40014800UL
  #define ADDR_TIM10		0X40014400UL
  #define ADDR_TIM9			0X40014000UL
  #define ADDR_EXTI			0X40013C00UL
  #define ADDR_SYSCFG		0X40013800UL
  #define ADDR_SPI4			0X40013400UL
  #define ADDR_SPI1			0X40013000UL
  #define ADDR_SDIO			0X40012C00UL
  #define ADDR_ADC1			0X40012000UL
  #define ADDR_USART6		0X40011400UL
  #define ADDR_USART1		0X40011000UL
  #define ADDR_TIM1			0X40010000UL
  /*  BUS: APB1  */
  #define ADDR_PWR			0X40007000UL
  #define ADDR_I2C3			0X40005C00UL
  #define ADDR_I2C2			0X40005800UL
  #define ADDR_I2C1			0X40005400UL
  #define ADDR_USART2		0X40004400UL
  #define ADDR_I2S3_EXT	0X40004000UL
  #define ADDR_I2S3 		0X40003C00UL
  #define ADDR_I2S2   	0X40003800UL
  #define ADDR_I2S2_EXT 0X40003400UL
  #define ADDR_IWDG			0X40003000UL
  #define ADDR_WWDG			0X40002C00UL
  #define ADDR_RTC			0X40002800UL
  #define ADDR_TIM5			0X40000C00UL
  #define ADDR_TIM4			0X40000800UL
  #define ADDR_TIM3			0X40000400UL
  #define ADDR_TIM2			0X40000000UL


  /**
   * @brief GPIO registers same for all ports A..H
   * */

  #define GPIO_OFFSET_MODER 		0x00UL
  #define GPIO_OFFSET_OTYPER 	0x04UL
  #define GPIO_OFFSET_OSPEEDER 0x08UL
  #define GPIO_OFFSET_PUPDR 		0x0CUL
  #define GPIO_OFFSET_IDR 			0x10UL
  #define GPIO_OFFSET_ODR 			0x14UL
  #define GPIO_OFFSET_BSSR 		0x18UL
  #define GPIO_OFFSET_LCKR 		0x1CUL
  #define GPIO_OFFSET_AFRL 		0x20UL
  #define GPIO_OFFSET_AFRH 		0x24UL

  /**
   * @brief GPIO functions 
   * p_porta p_portb p_portx are all pointers to port addresses
   * */


  // resets for port A
  #define GPIO_RESET_MODERA(p_portA)	 	(*(p_portA + GPIO_OFFSET_MODER) 		= 0x0C000000UL)
  #define GPIO_RESET_OTYPERA(p_portA)  	(*(p_portA + GPIO_OFFSET_OTYPER) 		= 0x00000000UL)
  #define GPIO_RESET_OSPEEDERA(p_portA) (*(p_portA + GPIO_OFFSET_OSPEEDER) 	= 0x0C000000UL)
  #define GPIO_RESET_PUPDRA(p_portA)  	(*(p_portA + GPIO_OFFSET_PUPDR) 		= 0x64000000UL)

  // resets for port B
  #define GPIO_RESET_MODERB(p_portB)	 	(*(p_portB + GPIO_OFFSET_MODER)   	= 0x00000280UL)
  #define GPIO_RESET_OTYPERB(p_portB)  	(*(p_portB + GPIO_OFFSET_OTYPER) 		= 0x00000000UL)
  #define GPIO_RESET_OSPEEDERB(p_portB) (*(p_portB + GPIO_OFFSET_OSPEEDER) 	= 0x000000C0UL)
  #define GPIO_RESET_PUPDRB(p_portB)  	(*(p_portB + GPIO_OFFSET_PUPDR) 		= 0x00000100UL)

  // resets for port C/D/E/H
  #define GPIO_RESET_MODERX(p_portX)	 	(*(p_portX + GPIO_OFFSET_MODER) 		= 0x00000000UL)
  #define GPIO_RESET_OTYPERX(p_portX)  	(*(p_portX + GPIO_OFFSET_OTYPER) 		= 0x00000000UL)
  #define GPIO_RESET_OSPEEDERX(p_portX) (*(p_portX + GPIO_OFFSET_OSPEEDER) 	= 0x00000000UL)
  #define GPIO_RESET_PUPDRX(p_portX)  	(*(p_portX + GPIO_OFFSET_PUPDR) 		= 0x00000000UL)

  // common resets for all ports A/B/C/D/E/H
  #define GPIO_RESET_IDRX(p_portX)  		(*(p_portX + GPIO_OFFSET_IDR) 			&= 0x00001111UL)
  #define GPIO_RESET_ODRX(p_portX)  		(*(p_portX + GPIO_OFFSET_ODR) 			= 0x00000000UL)
  #define GPIO_RESET_BSSRX(p_portX)  		(*(p_portX + GPIO_OFFSET_BSSR) 			= 0x00000000UL)
  #define GPIO_RESET_LCKRX(p_portX)  		(*(p_portX + GPIO_OFFSET_LCKR) 			=	0x00000000UL)
  #define GPIO_RESET_AFRLX(p_portX)  		(*(p_portX + GPIO_OFFSET_AFRL) 			= 0x00000000UL)
  #define GPIO_RESET_AFRHX(p_portX)  		(*(p_portX + GPIO_OFFSET_AFRH) 			= 0x00000000UL)


  /**
   *  SET values for pins 
   * pin_num ranges from 0 to 15
   * */
  // set mode
  #define GPIO_SET_INPUT(p_portX, pin_num)			(*(p_portX + GPIO_OFFSET_MODER) |= (0b00 << (pin_num * 2)))
  #define GPIO_SET_OUTPUT(p_portX, pin_num)			(*(p_portX + GPIO_OFFSET_MODER) |= (0b01 << (pin_num * 2)))
  #define GPIO_SET_ALTER_FUNC(p_portX, pin_num)	(*(p_portX + GPIO_OFFSET_MODER) |= (0b10 << (pin_num * 2)))
  #define GPIO_SET_ANALOG(p_portX, pin_num)			(*(p_portX + GPIO_OFFSET_MODER) |= (0b11 << (pin_num * 2)))
  // set type
  #define GPIO_SET_PUSH_PULL(p_portX, pin_num)	(*(p_portX + GPIO_OFFSET_OTYPER) |= (0b0 << pin_num))
  #define GPIO_SET_OPEN_DRAIN(p_portX, pin_num)	(*(p_portX + GPIO_OFFSET_OTYPER) |= (0b1 << pin_num))
  // set speed
  #define GPIO_SET_LOW_SPEED(p_portX, pin_num)			(*(p_portX + GPIO_OFFSET_OSPEEDER) |= (0b00 << (pin_num * 2)))
  #define GPIO_SET_MEDIUM_SPEED(p_portX, pin_num)		(*(p_portX + GPIO_OFFSET_OSPEEDER) |= (0b01 << (pin_num * 2)))
  #define GPIO_SET_HIGH_SPEED(p_portX, pin_num)			(*(p_portX + GPIO_OFFSET_OSPEEDER) |= (0b10 << (pin_num * 2)))
  #define GPIO_SET_VERYHIGH_SPEED(p_portX, pin_num)	(*(p_portX + GPIO_OFFSET_OSPEEDER) |= (0b11 << (pin_num * 2)))
  // set pullup pull/down
  #define GPIO_SET_PULL_UP_DOWN_NONE(p_portX, pin_num)	(*(p_portX + GPIO_OFFSET_PUPDR) |= (0b00 << (pin_num * 2)))
  #define GPIO_SET_PULL_UP(p_portX, pin_num)						(*(p_portX + GPIO_OFFSET_PUPDR) |= (0b01 << (pin_num * 2)))
  #define GPIO_SET_PULL_DOWN(p_portX, pin_num)					(*(p_portX + GPIO_OFFSET_PUPDR) |= (0b10 << (pin_num * 2)))
  // get input value 
  #define GPIO_GET_IDR(p_portX) 		(unsigned long)(*(p_portX + GPIO_OFFSET_IDR))

  /**
   * 
   * other register functions are not necessary for now
   * */
#endif // !STM32f401RE1



#define RCC_AHB1ENR (ADDR_RCC + 0x30) 

