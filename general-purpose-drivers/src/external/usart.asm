
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb
  #include "../helper.asm"

  .section .text.drivers.usart_driver, "ax", %progbits


@-----------------------------------------------------------------
  .section .rodata.drivers.usart_driver, "a", %progbits
  
