  
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb
  #include "../helper.asm"

  .section .text.drivers.rcc_driver, "ax", %progbits
@---------------------------------------------------
@ enable PLLI²S (phase locked loop for inter integrated sound system)
  .global _RCC_pll_I2S_enable
  .type _RCC_pll_I2S_enable, %function
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
  .global _RCC_PLL_enable
  .type _RCC_PLL_enable, %function
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
  .global _RCC_CSS_enable
  .type _RCC_CSS_enable, %function
_RCC_CSS_enable:
  LDR     r0, =RCC_BASE_BB    @ load rcc base bit-band address in r0
  MOV     r1, #1              @ 1 to enable
  MOVW    r2, #0x4C           @ CSS bit-band offset (bit19*4bytes)
  STR     r1, [r0, r2]
  bx      r14
  .size _RCC_CSS_enable, .-_RCC_CSS_enable
@---------------------------------------------------
@ enable HSE (high speed external osillator) (not provided on nucleo boards)
  .global _RCC_HSE_enable
  .type _RCC_HSE_enable, %function
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
  .size _RCC_HSE_enable, .-_RCC_HSE_enable

@---------------------------------------------------
@ bypass HSE with an external crystal/ceramic oscillator
  .global _RCC_HSE_ext_bypass
  .type _RCC_HSE_ext_bypass, %function
_RCC_HSE_ext_bypass:
  LDR     r0, =RCC_BASE_BB    @ load rcc base bit-band address in r0
  MOV     r1, #1              @ 1 to enable
  MOVW    r2, #0x48           @ PLLBYP bit-band offset (bit18*4bytes)
  STR     r1, [r0, r2]
  bx      r14
  .size _RCC_HSE_ext_bypass, .-_RCC_HSE_ext_bypass
@---------------------------------------------------
@ enable HSI (high speed internal RC)
  .global _RCC_HSI_enable
  .type _RCC_HSI_enable, %function
_RCC_HSI_enable:
  PUSH_R0_R1
  LDR     r0, =RCC_BASE_BB    @ load rcc base bit-band address in r0
  MOV     r1, #1              @ 1 to enable
  STR     r1, [r0], #0x04     @ enable and transition the ready bit
__hsi_wait:
  LDR     r1, [r0]
  CBZ     r1, __hsi_wait      @ if hsi ready flag is disabled we branch else exit
  POP_R0_R1
  bx      r14
  .size _RCC_HSI_enable, .-_RCC_HSI_enable
@---------------------------------------------------
@ pll_config
  .global _RCC_PLL_config
  .type _RCC_PLL_config, %function
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
  .size _RCC_PLL_config, .-_RCC_PLL_config
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
  .global _RCC_set_bus_presc
  .type _RCC_set_bus_presc, %function
_RCC_set_bus_presc:
  LDR     r0, =RCC_BASE
  LDR     r1, [r0, #0x08]!
  MOVW    r2, #(0b111111001111 << 4)  @ clear prescaler values
  BIC     r1, r1, r2
  MOVW    r2, #(0b100 << 10)
  ORR     r1, r1, r2
  STR     r1, [r0]
  BX      r14
  .size _RCC_set_bus_presc, .-_RCC_set_bus_presc
@---------------------------------------------------
@ enable RCC interrupts (triggered when clocks are ready)  
  .global _RCC_enable_intrpts
  .type _RCC_enable_intrpts, %function
_RCC_enable_intrpts:
  LDR     r0, =RCC_BASE
  LDR     r1, [r0, #0x0C]!            @ RCC_CIR reg
  MOVW    r2, #(0b111111 << 8)        @ enable clock ready interrupts
  ORR     r1, r1, r2
  STR     r1, [r0]
  BX      r14
  .size _RCC_enable_intrpts, .-_RCC_enable_intrpts
@---------------------------------------------------
@ clear RCC interrupt flags  
  .global _RCC_clear_intrpts
  .type _RCC_clear_intrpts, %function
_RCC_clear_intrpts:
  LDR     r0, =RCC_BASE
  LDR     r1, [r0, #0x0C]!            @ RCC_CIR reg
  MOV     r2, #0
  MOVT    r2, #(0b10111111)           @ clear clock ready interrupt flags
  ORR     r1, r1, r2
  STR     r1, [r0]
  BX      r14
  .size _RCC_clear_intrpts, .-_RCC_clear_intrpts
@---------------------------------------------------
@ reste DMA2  
  .global _RCC_reset_DMA2
  .type _RCC_reset_DMA2, %function
_RCC_reset_DMA2:
  LDR     r0, =RCC_AHB1RSTR_BB
  ADD     r0, r0, #88                 @ 22nd bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
  .size _RCC_reset_DMA2, .-_RCC_reset_DMA2
@---------------------------------------------------
@ reset DMA1  
  .global _RCC_reset_DMA1
  .type _RCC_reset_DMA1, %function
_RCC_reset_DMA1:
  LDR     r0, =RCC_AHB1RSTR_BB
  ADD     r0, r0, #84                 @ 21st bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
  .size _RCC_reset_DMA1, .-_RCC_reset_DMA1
@---------------------------------------------------
@ reset CRC
  .global _RCC_reset_CRC
  .type _RCC_reset_CRC, %function
_RCC_reset_CRC:
  LDR     r0, =RCC_AHB1RSTR_BB
  ADD     r0, r0, #48                 @ 12th bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
  .size _RCC_reset_CRC, .-_RCC_reset_CRC
@---------------------------------------------------
@ reset GPIOH
  .global _RCC_reset_GPIOH
  .type _RCC_reset_GPIOH, %function
_RCC_reset_GPIOH:
  LDR     r0, =RCC_AHB1RSTR_BB
  ADD     r0, r0, #28                 @ 7th bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
  .size _RCC_reset_GPIOH, .-_RCC_reset_GPIOH
@---------------------------------------------------
@ reset GPIOE
  .global _RCC_reset_GPIOE
  .type _RCC_reset_GPIOE, %function
_RCC_reset_GPIOE:
  LDR     r0, =RCC_AHB1RSTR_BB
  ADD     r0, r0, #16                 @ 4th bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
  .size _RCC_reset_GPIOE, .-_RCC_reset_GPIOE
@---------------------------------------------------
@ reset GPIOD
  .global _RCC_reset_GPIOD
  .type _RCC_reset_GPIOD, %function
_RCC_reset_GPIOD:
  LDR     r0, =RCC_AHB1RSTR_BB
  ADD     r0, r0, #12                 @ 3rd bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
  .size _RCC_reset_GPIOD, .-_RCC_reset_GPIOD
@---------------------------------------------------
@ reset GPIOC
  .global _RCC_reset_GPIOC
  .type _RCC_reset_GPIOC, %function
_RCC_reset_GPIOC:
  LDR     r0, =RCC_AHB1RSTR_BB
  ADD     r0, r0, #8                 @ 2nd bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
  .size _RCC_reset_GPIOC, .-_RCC_reset_GPIOC
@---------------------------------------------------
@ reset GPIOB
  .global _RCC_reset_GPIOB
  .type _RCC_reset_GPIOB, %function
_RCC_reset_GPIOB:
  LDR     r0, =RCC_AHB1RSTR_BB
  ADD     r0, r0, #4                 @ 1st bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
  .size _RCC_reset_GPIOB, .-_RCC_reset_GPIOB
@---------------------------------------------------
@ reset GPIOA
  .global _RCC_reset_GPIOA
  .type _RCC_reset_GPIOA, %function
_RCC_reset_GPIOA:
  LDR     r0, =RCC_AHB1RSTR_BB
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
  .size _RCC_reset_GPIOA, .-_RCC_reset_GPIOA
@---------------------------------------------------
@---------------------------------------------------
@ enable DMA2  
  .global _RCC_enable_DMA2
  .type _RCC_enable_DMA2, %function
_RCC_enable_DMA2:
  LDR     r0, =RCC_AHB1ENR_BB
  ADD     r0, r0, #88                 @ 22nd bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
  .size _RCC_enable_DMA2, .-_RCC_enable_DMA2
@---------------------------------------------------
@ enable DMA1  
  .global _RCC_enable_DMA2
  .type _RCC_enable_DMA2, %function
_RCC_enbale_DMA1:
  LDR     r0, =RCC_AHB1ENR_BB
  ADD     r0, r0, #84                 @ 21st bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
  .size _RCC_enable_DMA1, .-_RCC_enable_DMA1
@---------------------------------------------------
@ enable CRC
  .global _RCC_enable_CRC
  .type _RCC_enable_CRC, %function
_RCC_enable_CRC:
  LDR     r0, =RCC_AHB1ENR_BB
  ADD     r0, r0, #48                 @ 12th bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
  .size _RCC_enable_CRC, .-_RCC_enable_CRC
@---------------------------------------------------
@ enable GPIOH
  .global _RCC_enable_GPIOH
  .type _RCC_enable_GPIOH, %function
_RCC_enable_GPIOH:
  LDR     r0, =RCC_AHB1ENR_BB
  ADD     r0, r0, #28                 @ 7th bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
  .size _RCC_enable_GPIOH, .-_RCC_enable_GPIOH
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
  .size _RCC_enable_GPIOE, .-_RCC_enable_GPIOE
@---------------------------------------------------
@ enable GPIOD
  .global _RCC_enable_GPIOD
  .type _RCC_enable_GPIOD, %function
_RCC_enable_GPIOD:
  LDR     r0, =RCC_AHB1ENR_BB
  ADD     r0, r0, #12                 @ 3rd bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
  .size _RCC_enable_GPIOD, .-_RCC_enable_GPIOD
@---------------------------------------------------
@ enable GPIOC
  .global _RCC_enable_GPIOC
  .type _RCC_enable_GPIOC, %function
_RCC_enable_GPIOC:
  LDR     r0, =RCC_AHB1ENR_BB
  ADD     r0, r0, #8                 @ 2nd bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
  .size _RCC_enable_GPIOC, .-_RCC_enable_GPIOC
@---------------------------------------------------
@ enable GPIOB
  .global _RCC_enable_GPIOB
  .type _RCC_enable_GPIOB, %function
_RCC_enable_GPIOB:
  LDR     r0, =RCC_AHB1ENR_BB
  ADD     r0, r0, #4                 @ 1st bit * 4 bytes for each bit
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
  .size _RCC_enable_GPIOB, .-_RCC_enable_GPIOB
@---------------------------------------------------
@ enable GPIOA
  .global _RCC_enable_GPIOA
  .type _RCC_enable_GPIOA, %function
_RCC_enable_GPIOA:
  LDR     r0, =RCC_AHB1ENR_BB
  MOV     r1, #1
  STR     r1, [r0]
  BX      r14
  .size _RCC_enable_GPIOA, .-_RCC_enable_GPIOA
@-----------------------------------------------------------------
@-----------------------------------------------------------------
@ reset USB OTG FS
_RCC_reset_OTGFS:
  LDR     r0, =RCC_AHB2RSTR_BB
  MOV     r1, #1
  STR     r1, [r0, #28]
  BX      r14
@-----------------------------------------------------------------
@-----------------------------------------------------------------
@ enable USB OTG FS
_RCC_enable_OTGFS:
  LDR     r0, =RCC_AHB1ENR_BB
  MOV     r1, #1
  STR     r1, [r0, #28]
  BX      r14
@-----------------------------------------------------------------
@-----------------------------------------------------------------
@ reset power interface
_RCC_reset_PWR:
  LDR     r0, =RCC_APB1ENR_BB
  

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
