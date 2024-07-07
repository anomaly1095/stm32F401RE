 
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb

  .section .text.main, "ax", %progbits
  .global _start
  .type _start, %function
_start:
  PUSH  {r14}
  LDR   r0, =USART2_BASE_BB
  LDR


  POP   {r14}
  BX    r14
  .size _start, .-_start

  .section .rodata.main, "a", %progbits
  .extern USART2_BASE
  .equ USART2_BASE_BB, 0x42088000 @ bit-band address of uart2
