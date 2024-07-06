
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb
  #include "../helper.asm"

  .section .text.drivers.usart_driver, "ax", %progbits


@-----------------------------------------------------------------
  .section .rodata.drivers.usart_driver, "a", %progbits
  @ USART6 and USART1 are both in APB2 (84mhz)
  .equ USART6_BASE,   0x40011400
  .equ USART6_BASE_BB,0x42228000

  .equ USART1_BASE,   0x40011000
  .equ USART1_BASE_BB,0x42220000
  
  @ USART2 is APB1
  .equ USART2_BASE,   0x40004400
  .equ USART2_BASE_BB,0x42088000

