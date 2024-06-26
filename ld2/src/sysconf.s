  .section .text.reset_handler, "ax", %progbits
  .global sys_init

sys_init: // load register addresses
  LDR   r0, =RCC_CR 
  LDR   r1, =RCC_PLLCFGR
  LDR   r2, =RCC_CFGR

hsi_enable: // make sure HSI is enabled
  LDR   r3, [r0]
  MOV   r4, #0b1
  ORR   r3, r3, r4
  STR   r3, [r0]

hsi_wait:
  LDR   r3, [r0]
  MOV   r4, #0b10
  TST   r3, r4                 // Check if bit 1 (HSIRDY) is set
  BEQ   hsi_wait               // If set, wait for HSI to stabilize

pll_conf:

  // PLLSRC
  LDR   r3, [r1]
  MOV   r4, #0b1
  LSL   r4, r4, #22
  BIC   r3, r3, r4       // clear bit 22 to set HSI as pll input

  // PLLM
  MOV   r4, #16
  ORR   r3, r3, r4            // Set PLLM to 16

  // PLLN
  MOV   r4, #(336 >> 4)   // we left shift to be able to fit in immediate value instruction (16bits)
  LSL   r4, r4, #10
  ORR   r3, r3, r4    // Set PLLN to 336

  // PLLP
  MOV   r4, #0b01
  LSL   r4, r4, #17 
  BIC   r3, r3, r4 // clear bit 17
  LSR   r4, r4, #1
  BIC   r3, r3, r4 // clear bit 16

  ORR   r3, r3, r4     // Set PLLP to 4
  STR   r3, [r1]               // Save the updated register to RCC_PLLCFGR

pll_on:
  LDR   r3, [r0]               // Load the value of RCC_CR into r3
  MOV   r4, #1
  LSL   r4, r4, #24
  ORR   r3, r3, r4     // Set PLLON bit to enable PLL

pll_wait:                    // check PLL phase is locked and sync
  LDR   r3, [r0]
  MOV   r4, #1
  LSL   r4, r4, #25
  TST   r3, r4         // check if PLL is locked (PLLRDY = 1)
  BEQ   pll_wait  

pll_sysclk:
  LDR   r3, [r2]
  MOV   r4, #0b10
  ORR   r3, r3, r4           // set PLL as source of sysclk
  STR   r3, [r2]                // save config changes

pll_sysclk_wait:
  LDR   r3, [r2]
  MOV   r4, #0b100
  TST   r3, r4
  BEQ   pll_sysclk_wait

  // return
  BX    lr
  .align 4
  .section .text.periph_config, "ax", %progbits
  .global gpioA_config

gpioA_config:
  // setting the AHB prescaler
  LDR   r0, =RCC_CFGR
  LDR   r1, [r0]
  MOV   r2, #0b1000 // HCLK = SYSCLK/2
  LSL   r2, r2, #4
  ORR   r1, r1, r2
  STR   r1, [r0]

  // enabling GPIOA clock
  LDR   r0, =RCC_AHB1ENR
  LDR   r1, [r0]
  MOV   r2, #0b1
  ORR   r1, r1, r2 // enable GPIO PORTA clock
  STR   r1, [r0]

  // configuring GPIOA MODER (Mode Register)
  LDR   r0, =GPIOA // MODER address
  LDR   r1, [r0]
  MOV   r2, #0b10 // Set pin PA5 as output (binary 10)
  LSL   r2, r2, #10 // Shift to PA5 position (LED)
  ORR   r1, r1, r2
  STR   r1, [r0]

  // configuring GPIOA OSPEEDR (Output Speed Register)
  ADD   r0, r0, #8 // OSPEEDR address
  LDR   r1, [r0]
  MOV   r2, #0b10 // Set pin PA5 to high speed (binary 10)
  LSL   r2, r2, #10 // Shift to PA5 position (LED)
  ORR   r1, r1, r2
  STR   r1, [r0]

  BX lr // Return from subroutine
  .align 4
  .section .rodata, "a", %progbits

.equ RCC_CR, 0x40023800 // RCC main register
.equ RCC_PLLCFGR, 0x40023804 // pll prescalers
.equ RCC_CFGR, 0x40023808 // other prescalers
.equ RCC_AHB1ENR, 0x40023830 // enable AHB peripherals
.equ GPIOA, 0x40020000    // gpio address base address (also AHB base address)
