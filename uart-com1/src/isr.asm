
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb

  .section .text.isr, "ax", %progbits
  .type USART2_IRQHandler, %function
  .global USART2_IRQHandler
USART2_IRQHandler:
  

  .size USART2_IRQHandler, .-USART2_IRQHandler

.section .rodata.main, "a", %progbits
  .extern USART2_BASE
  .equ USART2_BASE_BB, 0x42088000         @ bit-band address of uart2