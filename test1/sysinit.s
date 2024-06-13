.equ RCC_CR, 0x40023800
.equ RCC_PLLCFGR, 0x40023804
.equ RCC_CFGR, 0x40023808

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
  LDR   r3, [r0]               // Load the value of RCC_CR into r3
  MOV   r4, #2
  TST   r3, r4                 // Check if bit 1 (HSIRDY) is set
  BNE   hsi_wait               // If set, wait for HSI to stabilize

pll_conf:
  LDR   r3, [r1]               // Load the value of RCC_PLLCFGR into r3
  MOV   r4, #0b1
  LSL   r4, r4, #22
  RBIT  r4, r4       // reverse bits
  AND   r3, r3, r4    // Clear bit 22 (PLLSRC) to set HSI as PLL input
  MOV   r4, #16
  ORR   r3, r3, r4            // Set PLLM to 16
  MOV   r4, #(336 >> 4)      // 336 >> 4
  LSL   r4, r4, #10
  ORR   r3, r3, r4    // Set PLLN to 336
  MOV   r4, #1
  LSL   r4, r4, #16
  ORR   r3, r3, r4     // Set PLLP to 4
  STR   r3, [r1]               // Save the updated value back to RCC_PLLCFGR

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
  BNE   pll_wait  

pll_sysclk:
  LDR   r3, [r2]
  MOV   r4, #0b10
  ORR   r3, r3, r4           // set PLL as source of sysclk
  STR   r3, [r2]                // save config changes

pll_sysclk_wait:
  LDR   r3, [r2]
  MOV   r4, #0b100
  TST   r3, r4
  BNE   pll_sysclk_wait

  // return
  BX lr
