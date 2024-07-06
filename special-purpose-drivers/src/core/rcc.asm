  
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb
  #include "../helper.asm"

  .section .text.drivers.rcc_driver, "ax", %progbits
@---------------------------------------------------
@ enable PLLI²S (phase locked loop for inter integrated sound system)
_RCC_PLL_I2S_enable:
  LDR     r0, =RCC_BASE_BB    @ load rcc base bit-band address in r0
  MOV     r1, #1              @ 1 to enable
  MOVW    r2, #0x68           @ PLLI2SON bit-band offset (bit26*4bytes)
  STR     r1, [r0, r2]!
  ADD     r0, r1, #0x04       @ PLLI2SRDY bit-band offset 
__pll_i2s_wait:
  LDR     r1, [r0]
  CBZ     r1, __pll_i2s_wait  @ if pll ready flag is disabled we branch
  bx      r14
  .size _RCC_pll_I2S_enable, .-_RCC_pll_I2S_enable
@---------------------------------------------------
@ enable PLL (phase locked loop)
_RCC_PLL_enable:
  LDR     r0, =RCC_BASE_BB    @ load rcc base bit-band address in r0
  MOV     r1, #1              @ 1 to enable
  MOVW    r2, #0x60           @ PLLON bit-band offset (bit24*4bytes)
  STR     r1, [r0, r2]!
  ADD     r0, r1, #0x04       @ PLLRDY bit-band offset 
__pll_wait:
  LDR     r1, [r0]
  CBZ     r1, __pll_wait  @ if pll ready flag is disabled we branch
  bx      r14
  .size _RCC_PLL_enable, .-_RCC_PLL_enable
@-----------------------------------------------------------------
@ enable CSS (clock security system)
_RCC_CSS_enable:
  LDR     r0, =RCC_BASE_BB    @ load rcc base bit-band address in r0
  MOV     r1, #1              @ 1 to enable
  MOVW    r2, #0x4C           @ CSS bit-band offset (bit19*4bytes)
  STR     r1, [r0, r2]
  bx      r14
@---------------------------------------------------
@ enable HSE (high speed external osillator) (not provided on nucleo boards)
_RCC_HSE_enable:
  LDR     r0, =RCC_BASE_BB    @ load rcc base bit-band address in r0
  MOV     r1, #1              @ 1 to enable
  MOVW    r2, #0x40           @ HSEON bit-band offset (bit16*4bytes)
  STR     r1, [r0, r2]!
  ADD     r0, r1, #0x04       @ HSERDY bit-band offset 
__hse_wait:
  LDR     r1, [r0]
  CBZ     r1, __hse_wait      @ if hse ready flag is disabled we branch else exit
  bx      r14
@---------------------------------------------------
@ bypass HSE with an external crystal/ceramic oscillator
_RCC_HSE_ext_bypass:
  LDR     r0, =RCC_BASE_BB    @ load rcc base bit-band address in r0
  MOV     r1, #1              @ 1 to enable
  MOVW    r2, #0x48           @ PLLBYP bit-band offset (bit18*4bytes)
  STR     r1, [r0, r2]
  bx      r14
@---------------------------------------------------
@ enable HSI (high speed internal RC)
_RCC_HSI_enable:
  LDR     r0, =RCC_BASE_BB    @ load rcc base bit-band address in r0
  MOV     r1, #1              @ 1 to enable
  STR     r1, [r0], #0x04     @ enable and transition the ready bit
__hsi_wait:
  LDR     r1, [r0]
  CBZ     r1, __hsi_wait      @ if hsi ready flag is disabled we branch else exit
  bx      r14
  .size _RCC_HSI_enable, .-_RCC_HSI_enable
@---------------------------------------------------
@ pll_config
_RCC_PLL_config:
  LDR     r0, =RCC_BASE
  LDR     r1, [r0, #0x04]!    @ load value of RCC_PLLCFGR 
  MOVW    r2, #16             @ set PLLM prescaler at 16 (reduces pll jitter)  
  MOVT    r2, #(0b1 << 6)     @ set clock source HSI
  MOVW    r3, #(336 << 6)     @ set PLLN prescaler at 336
  MOVT    r3, #0b01           @ set PLLP prescaler at 4
  ORR     r1, r1, r2          @ set the bits in r1
  ORR     r1, r1, r3          @ set the bits in r1
  LDR     r1, [r0]            @ store value to RCC_PLLCFGR 
  BX      r14                 @ exit
@---------------------------------------------------
@ set PLL as SYSCLK 
  .global _RCC_SYSCLK_config
  .type _RCC_SYSCLK_config, %function
_RCC_SYSCLK_config:
  LDR     r0, =RCC_BASE
  LDR     r1, [r0, #0x08]!
  MOVW    r2, #0b11
  BIC     r1, r1, r2        @ clear SW bits
  MOVW    r2, #0b10
  ORR     r1, r1, r2        @ set correct bits in SW bits
  STR     r1, [r0]
  LSL     r2, r2, #2        @ set the mask for SWS bits
__wait_sysclk:
  LDR     r1, [r0]
  TST     r1, r2
  BEQ     __wait_sysclk
  BX      r14
  .size _RCC_SYSCLK_config, .-_RCC_SYSCLK_config

@---------------------------------------------------
@ APB1 42mhz and APB2 84mhz and AHB 84mhz prescalers
_RCC_set_bus_presc:
  LDR     r0, =RCC_BASE
  LDR     r1, [r0, #0x08]!
  MOVW    r2, #(0b111111001111 << 4)  @ clear prescaler values
  BIC     r1, r1, r2
  MOVW    r2, #(0b100 << 10)
  ORR     r1, r1, r2
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable RCC interrupts (triggered when clocks are ready)  
_RCC_enable_intrpts:
  LDR     r0, =RCC_BASE
  LDR     r1, [r0, #0x0C]!            @ RCC_CIR reg
  MOVW    r2, #(0b111111 << 8)        @ enable clock ready interrupts
  ORR     r1, r1, r2
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------RCC_AHB1RSTR
@ clear RCC interrupt flags  
_RCC_clear_intrpts:
  LDR     r0, =RCC_BASE
  LDR     r1, [r0, #0x0C]!            @ RCC_CIR reg
  MOV     r2, #0
  MOVT    r2, #(0b10111111)           @ clear clock ready interrupt flags
  ORR     r1, r1, r2
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reste DMA2  
_RCC_reset_DMA2:
  LDR     r0, =RCC_AHB1RSTR_BB
  ADD     r0, r0, #88                 @ 22nd bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset DMA1  
_RCC_reset_DMA1:
  LDR     r0, =RCC_AHB1RSTR_BB
  ADD     r0, r0, #84                 @ 21st bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset CRC
_RCC_reset_CRC:
  LDR     r0, =RCC_AHB1RSTR_BB
  ADD     r0, r0, #48                 @ 12th bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset GPIOH
_RCC_reset_GPIOH:
  LDR     r0, =RCC_AHB1RSTR_BB
  ADD     r0, r0, #28                 @ 7th bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset GPIOE
_RCC_reset_GPIOE:
  LDR     r0, =RCC_AHB1RSTR_BB
  ADD     r0, r0, #16                 @ 4th bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset GPIOD
_RCC_reset_GPIOD:
  LDR     r0, =RCC_AHB1RSTR_BB
  ADD     r0, r0, #12                 @ 3rd bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset GPIOC
_RCC_reset_GPIOC:
  LDR     r0, =RCC_AHB1RSTR_BB
  ADD     r0, r0, #8                 @ 2nd bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset GPIOB
_RCC_reset_GPIOB:
  LDR     r0, =RCC_AHB1RSTR_BB
  ADD     r0, r0, #4                 @ 1st bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset GPIOA
_RCC_reset_GPIOA:
  LDR     r0, =RCC_AHB1RSTR_BB
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@---------------------------------------------------RCC_AHB1ENR
@ enable DMA2  
_RCC_enable_DMA2:
  LDR     r0, =RCC_AHB1ENR_BB
  ADD     r0, r0, #88                 @ 22nd bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable DMA1  
_RCC_enbale_DMA1:
  LDR     r0, =RCC_AHB1ENR_BB
  ADD     r0, r0, #84                 @ 21st bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable CRC
_RCC_enable_CRC:
  LDR     r0, =RCC_AHB1ENR_BB
  ADD     r0, r0, #48                 @ 12th bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable GPIOH
_RCC_enable_GPIOH:
  LDR     r0, =RCC_AHB1ENR_BB
  ADD     r0, r0, #28                 @ 7th bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable GPIOE
  .global _RCC_enable_GPIOE
  .type _RCC_enable_GPIOE, %function
_RCC_enable_GPIOE:
  LDR     r0, =RCC_AHB1ENR_BB
  ADD     r0, r0, #16                 @ 4th bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable GPIOD
_RCC_enable_GPIOD:
  LDR     r0, =RCC_AHB1ENR_BB
  ADD     r0, r0, #12                 @ 3rd bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable GPIOC
_RCC_enable_GPIOC:
  LDR     r0, =RCC_AHB1ENR_BB
  ADD     r0, r0, #8                 @ 2nd bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable GPIOB
_RCC_enable_GPIOB:
  LDR     r0, =RCC_AHB1ENR_BB
  ADD     r0, r0, #4                 @ 1st bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable GPIOA
_RCC_enable_GPIOA:
  LDR     r0, =RCC_AHB1ENR_BB
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------------
@---------------------------------------------------------RCC_AHB2RSTR
@ reset USB OTG FS
_RCC_reset_OTGFS:
  LDR     r0, =RCC_AHB2RSTR_BB
  MOV     r1, #1
  STR     r1, [r0, #28]
  BX      r14
@----------------------------------------------------------
@----------------------------------------------------------RCC_AHB2ENR
@ reset USB OTG FS
_RCC_enable_OTGFS:
  LDR     r0, =RCC_AHB1ENR_BB
  MOV     r1, #1
  STR     r1, [r0, #28]
  BX      r14
@----------------------------------------------------------
@----------------------------------------------------------RCC_APB1RSTR
@ reset power interface
_RCC_reset_PWR:
  LDR     r0, =RCC_APB1RSTR_BB
  ADD     r0, r0, #0x70
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset I2C3
_RCC_reset_I2C3:
  LDR     r0, =RCC_APB1RSTR_BB
  ADD     r0, r0, #0x5C
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset I2C2
_RCC_reset_I2C2:
  LDR     r0, =RCC_APB1RSTR_BB
  ADD     r0, r0, #0x58
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset I2C1
_RCC_reset_I2C1:
  LDR     r0, =RCC_APB1RSTR_BB
  ADD     r0, r0, #0x54
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset USART2
_RCC_reset_USART2:
  LDR     r0, =RCC_APB1RSTR_BB
  ADD     r0, r0, #0x44
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset SPI3
_RCC_reset_SPI3:
  LDR     r0, =RCC_APB1RSTR_BB
  ADD     r0, r0, #0x3C
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset SPI2
_RCC_reset_SPI2:
  LDR     r0, =RCC_APB1RSTR_BB
  ADD     r0, r0, #0x38
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset WWDG
_RCC_reset_WWDG:
  LDR     r0, =RCC_APB1RSTR_BB
  ADD     r0, r0, #0x2C
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset TIM5
_RCC_reset_TIM5:
  LDR     r0, =RCC_APB1RSTR_BB
  ADD     r0, r0, #0x0C
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset TIM4
_RCC_reset_TIM4:
  LDR     r0, =RCC_APB1RSTR_BB
  ADD     r0, r0, #0x08
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset TIM3
_RCC_reset_TIM3:
  LDR     r0, =RCC_APB1RSTR_BB
  ADD     r0, r0, #0x04
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset TIM2
_RCC_reset_TIM2:
  LDR     r0, =RCC_APB1RSTR_BB
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14

@----------------------------------------------------------
@----------------------------------------------------------RCC_APB1ENR
@ enable power interface
_RCC_enable_PWR:
  LDR     r0, =RCC_APB1ENR_BB
  ADD     r0, r0, #0x70
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable I2C3
_RCC_enable_I2C3:
  LDR     r0, =RCC_APB1ENR_BB
  ADD     r0, r0, #0x5C
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable I2C2
_RCC_enable_I2C2:
  LDR     r0, =RCC_APB1ENR_BB
  ADD     r0, r0, #0x58
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable I2C1
_RCC_enable_I2C1:
  LDR     r0, =RCC_APB1ENR_BB
  ADD     r0, r0, #0x54
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable USART2
_RCC_enable_USART2:
  LDR     r0, =RCC_APB1ENR_BB
  ADD     r0, r0, #0x44
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable SPI3
_RCC_enable_SPI3:
  LDR     r0, =RCC_APB1ENR_BB
  ADD     r0, r0, #0x3C
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable SPI2
_RCC_enable_SPI2:
  LDR     r0, =RCC_APB1ENR_BB
  ADD     r0, r0, #0x38
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable WWDG
_RCC_enable_WWDG:
  LDR     r0, =RCC_APB1ENR_BB
  ADD     r0, r0, #0x2C
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable TIM5
_RCC_enable_TIM5:
  LDR     r0, =RCC_APB1ENR_BB
  ADD     r0, r0, #0x0C
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable TIM4
_RCC_enable_TIM4:
  LDR     r0, =RCC_APB1ENR_BB
  ADD     r0, r0, #0x08
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable TIM3
_RCC_enable_TIM3:
  LDR     r0, =RCC_APB1ENR_BB
  ADD     r0, r0, #0x04
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable TIM2
_RCC_enable_TIM2:
  LDR     r0, =RCC_APB1ENR_BB
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14

@----------------------------------------------------------
@----------------------------------------------------------RCC_APB2RSTR
@ reset TIM11
_RCC_reset_TIM11:
  LDR     r0, =RCC_APB2RSTR_BB
  ADD     r0, r0, #0x48
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset TIM10
_RCC_reset_TIM11:
  LDR     r0, =RCC_APB2RSTR_BB
  ADD     r0, r0, #0x44
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset TIM9
_RCC_reset_TIM11:
  LDR     r0, =RCC_APB2RSTR_BB
  ADD     r0, r0, #0x40
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset SYSCFG
_RCC_reset_SYSGFG:
  LDR     r0, =RCC_APB2RSTR_BB
  ADD     r0, r0, #0x38
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset SPI4
_RCC_reset_SPI4:
  LDR     r0, =RCC_APB2RSTR_BB
  ADD     r0, r0, #0x34
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset SPI1
_RCC_reset_SPI1:
  LDR     r0, =RCC_APB2RSTR_BB
  ADD     r0, r0, #0x30
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset SDIO
_RCC_reset_SDIO:
  LDR     r0, =RCC_APB2RSTR_BB
  ADD     r0, r0, #0x2C
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset ADC1
_RCC_reset_ADC1:
  LDR     r0, =RCC_APB2RSTR_BB
  ADD     r0, r0, #0x20
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset USART6
_RCC_reset_USART6:
  LDR     r0, =RCC_APB2RSTR_BB
  ADD     r0, r0, #0x14
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset USART1
_RCC_reset_USART1:
  LDR     r0, =RCC_APB2RSTR_BB
  ADD     r0, r0, #0x10
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ reset TIM1
_RCC_reset_TIM1:
  LDR     r0, =RCC_APB2RSTR_BB
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@----------------------------------------------------------
@----------------------------------------------------------RCC_APB2ENR
@ enable TIM11
_RCC_enable_TIM11:
  LDR     r0, =RCC_APB2ENR_BB
  ADD     r0, r0, #0x48
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable TIM10
_RCC_enable_TIM11:
  LDR     r0, =RCC_APB2ENR_BB
  ADD     r0, r0, #0x44
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable TIM9
_RCC_enable_TIM11:
  LDR     r0, =RCC_APB2ENR_BB
  ADD     r0, r0, #0x40
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable SYSCFG
_RCC_enable_SYSGFG:
  LDR     r0, =RCC_APB2ENR_BB
  ADD     r0, r0, #0x38
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable SPI4
_RCC_enable_SPI4:
  LDR     r0, =RCC_APB2ENR_BB
  ADD     r0, r0, #0x34
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable SPI1
_RCC_enable_SPI1:
  LDR     r0, =RCC_APB2ENR_BB
  ADD     r0, r0, #0x30
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable SDIO
_RCC_enable_SDIO:
  LDR     r0, =RCC_APB2ENR_BB
  ADD     r0, r0, #0x2C
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable ADC1
_RCC_enable_ADC1:
  LDR     r0, =RCC_APB2ENR_BB
  ADD     r0, r0, #0x20
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable USART6
_RCC_enable_USART6:
  LDR     r0, =RCC_APB2ENR_BB
  ADD     r0, r0, #0x14
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable USART1
_RCC_enable_USART1:
  LDR     r0, =RCC_APB2ENR_BB
  ADD     r0, r0, #0x10
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
@---------------------------------------------------
@ enable TIM1
_RCC_enable_TIM1:
  LDR     r0, =RCC_APB2ENR_BB
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14



@-----------------------------------------------------------------
  .section .rodata.drivers.rcc_driver, "a", %progbits
  .equ RCC_BASE,    0x40023800
  .equ RCC_BASE_BB, 0x42470000
  
  .equ RCC_AHB1RSTR_BB,0x42470200
  .equ RCC_AHB2RSTR_BB,0x42470280
  .equ RCC_APB1RSTR_BB,0x42470300
  .equ RCC_APB2RSTR_BB,0x42470380

  .equ RCC_AHB1ENR_BB,  0x42470400
  .equ RCC_AHB2ENR_BB,  0x42470480
  .equ RCC_APB1ENR_BB,  0x42470500
  .equ RCC_APB2ENR_BB,  0x42470580

  .equ RCC_AHB1LPENR_BB, 0x42470600
  .equ RCC_AHB2LPENR_BB, 0x42470680
  .equ RCC_APB1LPENR_BB, 0x42470700
  .equ RCC_APB2LPENR_BB, 0x42470780

  .equ RCC_BDCR_BB,      0x42470800
  .equ RCC_CSR_BB,       0x42470880
  .equ RCC_SSCGR_BB,     0x42470900
  .equ RCC_PLLI2SCFGR_BB,0x42470980
  .equ RCC_DCKCFGR_BBS,  0x42470A00
