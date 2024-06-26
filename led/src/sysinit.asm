@ HSI   = 16mhz
@ PLL   = 84mhz
@ SYSCLK= PLL
@ AHB   = SYSCLK/1
@ HPRE2 = AHB/1
@ HPRE1 = AHB/2
@ 2 wate states flash read operation
@ prefetch enable
@ instruction & data cache enable
@ PC13(builtin button) input open drain pullup
@ PA5(builtin led) output push-pull  
@ SYSTICK 1 interrupt per ms (84.000.000/8 = 10.500.000 ticks/s = 10.500 ticks/ms)
@ interrupt from:  SYSCLK / PC13 (button) / FLASH operations

  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16 // HARDWARE FLOATING POINT UNIT
  .thumb

@-------------------------------------------

  .section .text.sysinit, "ax", %progbits
  .type __sysinit, %function
  .global __sysinit
  
__sysinit:
  LDR   r0, =RCC_BASE
@-------------------------------------------clocks

__hsi_enable:
  LDR   r1, [r0]            @ PLL_CR reg
  MOV   r2, #(0b1 << 0)
  ORR   r1, r1, r2
  STR   r1, [r0]            @ PLL_CR reg

  LSL   r2, r2, #1
__hsi_wait:
  LDR   r1, [r0]            @ PLL_CR reg
  TST   r1, r2
  BEQ   __hsi_wait

__pll_config:
  LDR   r1, [r0, #0x04]     @ RCC_PLLCFGR reg
  @ pll source
  MOV   r2, #0b1
  LSL   r2, r2, #22         @ PLLSRC bits (hsi source)
  ORR   r1, r1, r2
  @ pll prescalers
  MOV   r2, #16             @ PLLM bits (set to 16)
  ORR   r1, r1, r2
  MOVW  r2, #336
  LSL   r2, r2, #6          @ PLLN bits (set to 336)
  ORR   r1, r1, r2
  MOV   r2, #0b01
  LSL   r2, r2, #16         @ PLLP bits (set to 4)
  ORR   r1, r1, r2
  @ save changes
  STR   r1, [r0, #0x04]     @ RCC_PLLCFGR reg

__pll_enable:
  LDR   r1, [r0]            @ PLL_CR reg
  MOV   r2, #0b1
  LSL   r2, r2, #24         @ PLLON bit
  ORR   r1, r1, r2
  STR   r1, [r0]            @ PLL_CR reg

  LSL   r2, r2, #1          @ PLLRDY bit
__pll_wait:
  LDR   r1, [r0]            @ PLL_CR reg
  TST   r1, r2
  BEQ   __pll_wait

__pll_as_sysclk:
  LDR   r1, [r0, #0x08]     @ RCC_CFGR reg
  MOV   r2, #0b10           @ SW bits
  ORR   r1, r1, r2
  STR   r1, [r0, #0x08]     @ RCC_CFGR reg

  LSL   r2, r2, #2          @ SWS bits
__sysclk_wait:
  LDR   r1, [r0, #0x08]     @ RCC_CFGR reg
  TST   r1, r2
  BEQ   __sysclk_wait

__hclk_set:
  LDR   r1, [r0, #0x08]     @ RCC_CFGR reg
  MOV   r2, #(0b1000 << 4)  @ HPRE bits
  BIC   r1, r1, r2          @ AHB = SYSCLK/1
  STR   r1, [r0, #0x08]

__hpre_set:
  LDR   r1, [r0, #0x08]     @ RCC_CFGR reg
  MOVW  r2, #(0b100 << 10)  @ PPRE1 bits APB1 = AHB/2
  MOVW  r3, #(0b100 << 13)  @ PPRE2 bits APB2 = AHB/1
  ORR   r1, r1, r2
  BIC   r1, r1, r3
  STR   r1, [r0, #0x08]     @ RCC_CFGR reg

@------------------------------------------- flash

__flash_config:
  LDR   r0, =FLASH_BASE
  @ reset data and instruction caches
  LDR   r1, [r0]            @ FLASH_ACR reg
  MOVW  r2, #(0b11 << 12)   @ DCRST & ICRST bits
  ROR   r1, r1, r2
  STR   r1, [r0]            @ FLASH_ACR reg
  @ enable data and instruction caches
  LDR   r1, [r0]            @ FLASH_ACR reg
  MOVW  r2, #(0b111 << 8)   @ DCEN & ICEN & PRFTEN bits 
  ROR   r1, r1, r2
  STR   r1, [r0]            @ FLASH_ACR reg
  @ set latency
  LDR   r1, [r0]            @ FLASH_ACR reg
  MOVW  r2, #(0b10 << 7)    @ LATENCY bits (2 wait states)
  ROR   r1, r1, r2
  STR   r1, [r0]            @ FLASH_ACR reg
  @ set parallelism, interrupts, lock  
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
  @ enable Flash interrupts in NVIC
  LDR   r0, =NVIC_BASE
  LDR   r1, [r0]    @ NVIC_ISER1 reg
  MOV   r2, #(0b1 << 4)     @ FLASH interrupt enable (SETENA bits)
  ORR   r1, r1, r2
  STR   r1, [r0]    @ NVIC_ISER1 reg

@------------------------------------------- gpio 

__gpio_config:
  @ reset GPIO_A/C
  LDR   r0, =RCC_BASE
  LDR   r1, [r0, #0x10]     @ RCC_AHB1RSTR reg
  MOVW  r2, #0b101
  ORR   r1, r1, r2
  STR   r1, [r0, #0x10]     @ RCC_AHB1RSTR reg
  LDR   r1, [r0, #0x10]     @ RCC_AHB1RSTR reg
  MOVW  r2, #0b101          @ GPIOARST GPIOCRST bits
  BIC   r1, r1, r2
  STR   r1, [r0, #0x10]     @ RCC_AHB1RSTR reg
  @ enable gpio PC13 (builtin button)-------------------------
  LDR   r0, =GPIOC_BASE
  LDR   r1, [r0]            @ GPIOC_MODER reg
  MOV   r2, #0b11
  LSL   r2, r2, #26         @ MODER13 bits input
  BIC   r1, r1, r2
  STR   r1, [r0]            @ GPIOC_MODER reg
  @ set PC13 to pullup
  LDR   r1, [r0, #0x0C]     @ GPIOC_PUPDR
  MOVW  r2, #0b01
  LSL   r2, r2, #26         @ PUPDR13 bits (pullup)
  ORR   r1, r1, r2
  STR   r1, [r0, #0x0C]     @ GPIOC_PUPDR
  @ set PA5 as output(builtin LED: LD2)-------------------------
  LDR   r0, =GPIOA_BASE
  LDR   r1, [r0]            @ GPIOA_MODER reg
  MOVW r2, #(0b1 << 10)    @ MODER5 bits OUTPUT
  ORR   r1, r1, r2
  STR   r1, [r0]            @ GPIOA_MODER reg
  @ set PA5 as push-pull
  LDR   r1, [r0, #0x04]     @ GPIOA_OTYPER reg
  MOV   r2, #(0b1 << 5)     @ OT5 bits push-pull
  BIC   r1, r1, r2
  STR   r1, [r0, #0x04]     @ GPIOA_TYPER reg
  @ set PA5 to medium speed
  LDR   r1, [r0, #0x08]     @ GPIOA_OSPEEDR reg
  MOVW  r2, #(0b10 << 01)   @ OSPEEDR 
  ORR   r1, r1, r2
  STR   r1, [r0, #0x08]     @ GPIOA_OSPEEDR reg
  @ set PA no push no pull
  LDR   r1, [r0, #0x0C]     @ GPIOA_PUPDR
  MOVW  r2, #0b11
  LSL   r2, r2, #26         @ PUPDR5 bits (None)
  BIC   r1, r1, r2
  STR   r1, [r0, #0x0C]     @ GPIOA_PUPDR
  @ enable GPIO_A/C clocks---------------------
  LDR   r0, =RCC_BASE
  LDR   r1, [r0, #0x30]     @ RCC_AHB1ENR reg
  MOVW  r2, #0b101          @ GPIOAEN/GPIOCEN bits
  ORR   r1, r1, r2
  STR   r1, [r0, #0x30]     @ RCC_AHB1ENR reg

__gpio_interrupts:
  @ set PC13 as EXTI13 source 
  LDR   r0, =SYSCFG_BASE
  LDR   r1, [r0, #0x14]     @ SYSCFG_EXTICR4
  MOV   r2, #(0b0010 << 4)  @ EXTI13 bits  
  ORR   r1, r1, r2
  STR   r1, [r0, #0x14]     @ SYSCFG_EXTICR4 reg
  @ mask interrupt EXTI13
  LDR   r0, =EXTI_BASE
  LDR   r1, [r0]            @ EXTI_IMR reg
  MOVW  r2, #(0b1 << 13)    @ IMR13 bit
  ORR   r1, r1, r2
  STR   r1, [r0]            @ EXTI_IMR reg
  @ interrupt on falling edge detection in PC13
  LDR   r1, [r0, #0x0C]     @ EXTI_FTSR reg
  MOVW  r2, #(0b1 << 13)    @ TR13 bit
  ORR   r1, r1, r2
  STR   r1, [r0, #0x0C]     @ EXTI_RTSR re
  @ enable EXTI10..15 interrupts
  LDR   r0, =NVIC_BASE
  LDR   r1, [r0, #0x04]    @ NVIC_ISER2 reg
  MOVW  r2, #(0b1 << 8)     @ EXTI[15..10] interrupt enable bit (SETENA bits)
  ORR   r1, r1, r2
  STR   r1, [r0, #0x04]    @ NVIC_ISER2 reg

__systick_config:
  LDR   r0, =SYSTICK_BASE
  MOVW  r1, #10499          @ set the counter to 10499 to generate & interrupt/ms
  STR   r1, [r0, #0x04]     @ STK_LOAD reg
  @ Set AHB/8 as SYSTICK input
  LDR   r1, [r0]            @ STK_CTRL
  MOV   r2, #0b100
  BIC   r1, r1, r2
  STR   r1, [r0]            @ STK_CTRL
  @ enable and enable systick interrupt
  LDR   r1, [r0]            @ STK_CTRL
  MOV   r2, #0b11
  ORR   r1, r1, r2
  STR   r1, [r0]            @ STK_CTRL
  
  @ return
  BX    lr
  .size __sysinit, .-__sysinit

@-------------------------------------------

  .section .rodata, "a", %progbits
  .equ RCC_BASE, 0x40023800
  .equ SYSTICK_BASE, 0xE000E010
  .equ FLASH_BASE, 0x40023C00
  .equ NVIC_BASE, 0xE000E100
  .equ SYSCFG_BASE, 0x40013800
  .equ EXTI_BASE, 0x40013C00
  .equ GPIOA_BASE, 0x40020000
  .equ GPIOC_BASE, 0x40020800
@-------------------------------------------
