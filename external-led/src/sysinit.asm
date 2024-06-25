@ HSI   = 16mhz
@ PLL   = 84mhz
@ SYSCLK= PLL
@ AHB   = SYSCLK/1
@ HPRE2 = AHB/1
@ HPRE1 = AHB/2
@ 2 wate states flash read operation
@ prefetch enable
@ instruction & data cache enable

@-------------------------------------------

  .section .text.sysinit, "ax", %progbits
  .type __sysinit, %function
  .global __sysinit
  
__sysinit:
  LDR   r0, =RCC_BASE

__hsi_enable:
  LDR   r1, [r0, #0x00]     @ PLL_CR reg
  MOV   r2, #(#0b1 << 0)
  ORR   r1, r1, r2
  STR   r1, [r0, #0x00]     @ PLL_CR reg

  LSL   r2, r2, #1
__hsi_wait:
  LDR   r1, [r0, #0x00]     @ PLL_CR reg
  TST   r1, r2
  BEQ   __hsi_wait

__pll_config:
  LDR   r1, [r0, #0x04]     @ RCC_PLLCFGR reg
  @ pll source
  MOV   r2, #0b1
  LSL   r2, r2, #22         @ PLLSRC bits
  ORR   r1, r1, r2
  @ pll prescalers
  MOV   r2, #16             @ PLLM bits
  ORR   r1, r1, r2
  MOVW  r2, #336
  LSL   r2, r2, #6          @ PLLN bits
  ORR   r1, r1, r2
  MOV   r2, #0b01
  LSL   r2, r2, #16         @ PLLP bits
  ORR   r1, r1, r2
  @ save changes
  STR   r1, [r0, #0x04]     @ RCC_PLLCFGR reg

__pll_enable:
  LDR   r1, [r0, #0x00]     @ PLL_CR reg
  MOV   r2, #0b1
  LSL   r2, r2, #24         @ PLLON bit
  ORR   r1, r1, r2
  STR   r1, [r0, #0x00]     @ PLL_CR reg

  LSL   r2, r2, #1          @ PLLRDY bit
__pll_wait:
  LDR   r1, [r0, #0x00]     @ PLL_CR reg
  TST   r1, r2
  BEQ   __pll_wait

__pll_as_sysclk:
  LDR   r1, [r0, #0x08]     @ RCC_CFGR reg
  MOV   r2, #(0b10, #0)     @ SW bits
  ORR   r1, r1, r2
  STR   r1, [r0, #0x08]     @ RCC_CFGR reg

  LSL   r2, r2, #2          @ SWS bits
__sysclk_wait:
  LDR   r1, [r0, #0x08]     @ RCC_CFGR reg
  TST   r1, r2
  BEQ   __sysclk_wait

__hclk_set:
  LDR   r1, [r0, #0x08]     @ RCC_CFGR reg
  MOV   r2, #(0b1000 << 4)  @ HPRE 
  BIC   r1, r1, r2          @ AHB = SYSCLK/1
  STR   r1, [r0, #0x08]

__hpre_set:
  LDR   r1, [r0, #0x08]     @ RCC_CFGR reg
  MOV   r2, #(0b100 << 10)  @ HPRE1 APB1 = AHB/2
  MOV   r3, #(0b100 << 13)  @ HPRE2 APB2 = AHB/1
  ORR   r1, r1, r2
  BIC   r1, r1, r3
  STR   r1, [r0, #0x08]     @ RCC_CFGR reg

__flash_config:
  LDR   r0, =FLASH_BASE
  
  LDR   r1, [r0, #0x00]     @ FLASH_ACR reg
  MOVW  r2, #(0b11 << 12)   @ DCRST & ICRST bits
  ROR   r1, r1, r2
  STR   r1, [r0, #0x00]     @ FLASH_ACR reg
  
  LDR   r1, [r0, #0x00]     @ FLASH_ACR reg
  MOVW  r2, #(0b111 << 8)   @ DCEN & ICEN & PRFTEN bits 
  ROR   r1, r1, r2
  STR   r1, [r0, #0x00]     @ FLASH_ACR reg
  
  LDR   r1, [r0, #0x00]     @ FLASH_ACR reg
  MOVW  r2, #(0b10 << 7)    @ LATENCY bits (2 wait states)
  ROR   r1, r1, r2
  STR   r1, [r0, #0x00]     @ FLASH_ACR reg

  LDR   r1, [r0, #0x10]     @ FLASH_CR reg
  MOVW  r2, #(0b10 << 8)    @ PSIZE (program parallelism = 32 bits)
  ORR   r1, r1, r2
  MOV   r2, #0b11
  LSL   r2, r2, #24         @ EOPIE & ERRIE bits: flash interrupts enable 
  ORR   r1, r1, r2
  MOV   r2, #0b1
  LSL   r2, r2, #31         @ LOCK bit: read only flash
  ORR   r1, r1, r2
  STR   r1, [r0, #0x10]     @ FLASH_CR reg

  LDR   r0, =NVIC_BASE
  LDR   r1, [r0, #0x100]    @ NVIC_ISER1 reg
  MOV   r2, #(0b1 << 4)     @ FLASH interrupt enable (SETENA bits)
  ORR   r1, r1, r2
  STR   r1, [r0, #0x100]    @ NVIC_ISER1 reg

__gpio_config:
  @ set PC13 as EXTI13 source 
  LDR   r0, =SYSCFG_BASE
  LDR   r1, [r0, #0x14]     @ SYSCFG_EXTICR4
  MOV   r2, #(0b0010 << 4)  @ EXTI13 bits  
  ORR   r1, r1, r2
  STR   r1, [r0, #0x14]     @ SYSCFG_EXTICR4 reg

  @ mask interrupt EXTI13
  LDR   r0, =EXTI_BASE
  LDR   r1, [r0, #0x00]     @ EXTI_IMR reg
  MOV   r2, #(0b1 << 13)    @ IMR13 bit
  ORR   r1, r1, r2
  STR   r1, [r0, #0x00]     @ EXTI_IMR reg

  @ interrupt on rising edge detection in PC13
  LDR   r1, [r0, #0x08]     @ EXTI_RTSR reg
  MOV   r2, #(0b1 << 13)    @ TR13 bit
  ORR   r1, r1, r2
  STR   r1, [r0, #0x00]     @ EXTI_RTSR reg

  @ enable EXTI10..15 interrupts
  LDR   r0, =NVIC_BASE
  LDR   r1, [r0, #0x104]    @ NVIC_ISER2 reg
  MOV   r2, #(0b1 << 8)     @ EXTI[15..10] interrupt enable bit (SETENA bits)
  ORR   r1, r1, r2
  STR   r1, [r0, #0x104]    @ NVIC_ISER2 reg

  @ enable gpio sections now (PC13 and an LED maybe PA5 fr builtin LD2) 

  @ RTC config?
__systick_config:


  BX    lr @ return
  .size __sysinit, .-__sysinit

@-------------------------------------------

  .section .rodata, "a", %progbits
  .equ RCC_BASE, 0x40023800
  .equ SYSTICK_BASE, 0xE000E010
  .equ FLASH_BASE, 0x40023C00
  .equ NVIC_BASE, 0xE000E000
  .equ SYSCFG_BASE, 0x40013800
  .equ EXTI_BASE, 0x40013C00