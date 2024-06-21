@ 
@ FILE for system configurations more details will be in the docs/
@ 
  
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16 // HARDWARE FLOATING POINT UNIT
  .thumb

@-------------------------------------------

  .section .text.sys_conf, "ax", %progbits
  .global _sysconf

_sysconf:
  @ enable HSI 
  LDR   r0, =RCC_BASE
  LDR   r1, [r0, #0x00] @ RCC_CR
  MOV   r2, #0b1
  ORR   r1, r1, r2
  STR   r1, [r0, #0x00] @ RCC_CR

  @ wait for HSI to be enabled 
wait_hsi:
  LDR   r1, [r0, #0x00] @ RCC_CR
  TST   r1, #(0b1 << 1)
  BEQ   wait_hsi

pll_conf:
  LDR   r1, [r0, #0x04] @ RCC_PLLGFGR

  @ PLLSRC
  MOV   r2, #0b01
  LSL   r2, #22
  BIC   r1, r1, r2
  
  @ PLLM
  MOVW  r2, #0b111111
  RBIT  r2, r2
  AND   r1, r1, r2
  MOVW  r2, #(0b01 << 4)
  ORR   r1, r1, r2
  
  @ PLLN
  MOVW  r2, #0b111111111
  RBIT  r2, r2
  AND   r1, r1, r2
  MOVW  r2, #336
  LSL   r2, r2, #6
  ORR   r1, r1, r2

  @ PLLP
  MOV   r2, #0b11
  RBIT  r2, r2
  AND   r1, r1, r2
  MOV   r2, #0b01
  LSL   r2, r2, #16
  ORR   r1, r1, r2

  @ save to register
  STR   r1, [r0, #0x04] @ RCC_PLLCFGR

  @ enable pll
  LDR   r1, [r0, #0x00] @ RCC_CR
  MOV   r2, #0b01
  LSL   r2, r2, #24
  ORR   r1, r1, r2
  STR   r1, [r0, #0x00] @ RCC_CR

  @ wait for pll to be enabled
  LSL   r2, r2, #1
wait_pll:
  LDR   r1, [r0, #0x00] @ RCC_CR
  TST   r1, r2
  BEQ wait_pll

  @ set pll as SYSCLK
  LDR   r1, [r0, #0x08] @ RCC_CFGR
  MOVW  r2, #0b11
  RBIT  r2, r2
  AND   r1, r1, r2
  MOVW  r2, #0b10 
  ORR   r1, r1, r2
  STR   r1, [r0, #0x08] @ RCC_CFGR

  @ wait for pll to be set as SYSCLK
wait_sysclk:
  LDR   r1, [r0, #0x08] @ RCC_CFGR
  MOVW  r2, #(0b10 << 2)
  TST   r1, r2
  BEQ   wait_sysclk

  @ AHB prescaler
  LDR   r1, [r0, #0x00] @ RCC_CR
  MOVW  r2, #(0b1000 << 4)
  ORR   r1, r1, r2
  STR   r1, [r0, #0x00] @ RCC_CR
  
  @ return
  BX    lr

  .size _sysconf, .-_sysconf

@-------------------------------------------

  .section .text.periphconf, "ax", %progbits
  .global _periphconf
_periphconf:
  @ GPIOC enable
  LDR   r0, =RCC_BASE
  LDR   r1, [r0, #0x30] @ RCC_AHB1ENR
  MOV   r2, #(0b01 << 2)
  ORR   r1, r1, r2
  STR   r1, [r0, #0x30] @ RCC_AHB1ENR 

  @ PC8 config
  LDR   r0, =GPIOC_BASE
  
  @ set PC8 input & PC5 output
  MOVW  r2, #(0b01 << 10)
  STR   r2, [r0, #0x00] @ GPIOC_MODER

  @ set PC5 push-pull
  LDR   r1, [r0, #0x04] @ GPIOC_OTYPER
  MOV   r2, #(0b01 << 5)
  BIC   r1, r1, r2 
  STR   r1, [r0, #0x04] @ GPIOC_OTYPER

  @ set pull up resistor at PC8 
  MOV   r2, #0b01
  LSL   r2, r2, #16
  STR   r1, [r0, #0x0C] @ GPIOC_PUPDR

  @ set PC5 medium speed
  MOVW  r2, #(0b01 << 10) @ medium speed
  STR   r2, [r0, #0x08]   @ GPIOC_OSPEEDR

  BX    lr
  .size _periphconf, .-_periphconf

@-------------------------------------------

  .section .rodata, "a", %progbits
  .global GPIOC_BASE 
  .equ RCC_BASE, 0x40023800  @ base address of RCC in AHB bus
  .equ GPIOC_BASE, 0x40020800 @ base address of GPIO port C registers
