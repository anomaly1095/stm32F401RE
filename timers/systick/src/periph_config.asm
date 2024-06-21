@ 
@ file for peripheral configuration
@ 
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16 // HARDWARE FLOATING POINT UNIT
  .thumb

  .global periph_config

@----------------------------------------

  .section .text.periph_config, "ax", %progbits
  .type periph_config, 

periph_config:

  @ GPIOA enable 
  LDR     r0, =RCC_BASE
  LDR     r1, [r0, #0x30]!
  MOVW    r2, #0b1
  ROR     r1, r1, r2
  STR     r1, [r0]
  
  @ GPIOA
  LDR     r0, =GPIOA_BASE
  
  @ ADC


  .size periph_config, .-periph_config

@----------------------------------------

  .section .rodata.registers, "a", %progbits
  ..extern RCC_BASE
  .equ GPIOA_BASE, 0x40020000
