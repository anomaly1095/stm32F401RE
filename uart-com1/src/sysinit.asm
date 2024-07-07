 
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb

  .section .text.sysinit, "ax", %progbits
  .global _sysinit
_sysinit:

  LDR     r0, =RCC_BASE_BB    @ load rcc base bit-band address in r0
__HSI_enable:
  MOV     r1, #1              @ 1 to enable
  STR     r1, [r0], #0x04     @ enable and transition the ready bit
__HSI_wait:
  LDR     r1, [r0]
  CBZ     r1, __hsi_wait      @ if hsi ready flag is disabled we branch else exit
  
__PLL_config:
  LDR     r0, =RCC_BASE
  LDR     r1, [r0, #0x04]!    @ load value of RCC_PLLCFGR 
  MOVW    r2, #16             @ set PLLM prescaler at 16 (reduces pll jitter)  
  MOVT    r2, #(0b1 << 6)     @ set clock source HSI
  MOVW    r3, #(336 << 6)     @ set PLLN prescaler at 336
  MOVT    r3, #0b01           @ set PLLP prescaler at 4
  ORR     r1, r1, r2          @ set the bits in r1
  ORR     r1, r1, r3          @ set the bits in r1
  LDR     r1, [r0]            @ store value to RCC_PLLCFGR 
__PLL_enable:
  LDR     r0, =RCC_BASE_BB    @ load rcc base bit-band address in r0
  MOV     r1, #1              @ 1 to enable
  MOVW    r2, #0x60           @ PLLON bit-band offset (bit24*4bytes)
  STR     r1, [r0, r2]!
  ADD     r0, r1, #0x04       @ PLLRDY bit-band offset 
__PLL_wait:
  LDR     r1, [r0]
  CBZ     r1, __pll_wait      @ if pll ready flag is disabled we branch

__SYSCLK_config:
  LDR     r0, =RCC_BASE
  LDR     r1, [r0, #0x08]!    @ RCC_CFGR
  MOVW    r2, #0b11
  BIC     r1, r1, r2          @ clear SW bits
  MOVW    r2, #0b10
  ORR     r1, r1, r2          @ set correct bits in SW bits
  STR     r1, [r0]            @ RCC_CFGR
  LSL     r2, r2, #2          @ set the mask for SWS bits
__SYSCLK_wait:
  LDR     r1, [r0]            @ RCC_CFGR
  TST     r1, r2
  BEQ     __wait_sysclk

  @ APB1 42mhz and APB2 84mhz and AHB 84mhz prescalers
__BUS_pre_config:
  LDR     r1, [r0]            @ RCC_CFGR
  LDR     r2, =BUS_PRESC_MASK @ clear prescaler values
  BIC     r1, r1, r2
  MOVW    r2, #(0b100 << 10)
  ORR     r1, r1, r2
  STR     r1, [r0]            @ RCC_CFGR

__GPIOA_ck_enable:
  LDR     r0, =RCC_AHB1ENR_BB   @ load the bit-band address for the reg
  MOV     r1, #1                @ enabel GPIOA clock
  STR     r1, [r0]

__USART2_ck_enable:
  LDR     r0, =RCC_APB1ENR_BB   @ load the bit-band address for re reg
  ADD     r0, r0, #0x44         @ offset for the bit 11 * 4 bytes
  STR     r1, [r0]

__GPIO_config:
  LDR     r0, =GPIOA_BASE
  @ PA2/PA3 as alternate functions
  LDR     r1, [r0]                  @ GPIOA_MODER
  MOVW    r2, #(0xA << 4)           @ Set PA2/PA3 as alternate functions (10)
  ORR     r1, r1, r2
  STR     r1, [r0]                  @ Write back to GPIOA_MODER
  @ PA2/PA3 output speed settings (very high speed)
  LDR     r1, [r0, #0x08]!          @ GPIOA_OSPEEDR
  MOVW    r2, #(0b1111 << 4)        @ Set high speed for PA2 and PA3
  ORR     r1, r1, r2
  STR     r1, [r0]                  @ Write back to GPIOA_OSPEEDR
  @ PA3 pull-up settings
  LDR     r1, [r0, #0x04]!          @ GPIOA_PUPDR
  MOVW    r2, #(0b01 << 6)           @ Enable pull-up for PA3
  ORR     r1, r1, r2
  STR     r1, [r0]                  @ Write back to GPIOA_PUPDR
  @ PA2/PA3 alternate function selection
  LDR     r1, [r0, #0x14]!          @ GPIOA_AFRL
  MOVW    r2, #(0x77 << 8)          @ Set PA2/PA3 as AF7 (USART2)
  ORR     r1, r1, r2
  STR     r1, [r0]                  @ Write back to GPIOA_AFRL
  
__USART2_config:
  LDR     r0, =USART2_BASE
  @ configure baud rate
  MOVW    r1, #0x1117               @ set baud rate at 9600 bits.s⁻¹
  STR     r1, [r0, #0x08]!          @ USART_BRR
  @ enable interrupts, transmission, word size = 8bits, 
  LDR     r1, [r0, #0x04]!          @ USART_CR1
  LDR     r2, =USART_CR1_MASK       @ set config bits
  ORR     r1, r1, r2
  STR     r1, [r0]
  @ enable USART
  LDR     r1, [r0]                  @ USART_CR1
  MOVW    r2, #(0b1 << 13)          @ enable the usart
  ORR     r1, r1, r2
  STR     r1, [r0]

__NVIC_config:
  LDR     r0, =NVIC_BASE
  MOV     r2, #(0b1 << 6)         @ USART2 interrupt in the 6th bit of NVIC_ISER1
  LDR     r1, [r0, #0x04]!        @ offset for NVIC_ISER1
  ORR     r1, r1, r2              @ set the bit
  STR     r1, [r0]
  
  BX      r14                     @ return
  .size _sysinit, .-_sysinit
  .type _sysinit, %function

@------------------------------------
  .section .rodata.registers, "a", %progbits
  .equ RCC_BASE,      0x40023800
  .equ RCC_BASE_BB,   0x42470000
  .equ RCC_AHB1ENR_BB,0x42470400
  .equ RCC_APB1ENR_BB,0x42470500
  .equ BUS_PRESC_MASK,0xFCF0
  .equ NVIC_BASE,     0xE000E100
  .equ GPIOA_BASE,    0x40020000
  .equ USART2_BASE,   0x40004400
  .equ USART_CR1_MASK,0x11FC
