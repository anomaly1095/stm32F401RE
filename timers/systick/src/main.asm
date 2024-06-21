@ 
@  main firmware entry point (_start)
@ 
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb

  .global _start
  .extern periph_config
@----------------------------------------

  .section .text.interrupts, "ax", %progbits
  .type SysTick_Handler, %function

_start:
  BL periph_config


  .size _start, .-_start

@----------------------------------------
