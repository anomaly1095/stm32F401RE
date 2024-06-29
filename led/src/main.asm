.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

@-------------------------------------------

  .section .text.main, "ax", %progbits
  .type _start, %function
  .global _start
_start:
  WFI
  B   _start
  Bx  lr
  .size _start, .-_start

