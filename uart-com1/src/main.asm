 
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb

  .section .text.main, "ax", %progbits
  .global _start
  .type _start, %function
_start:
  LDR     r0, =__data__
  CMP     r1, 
  MOV     r1, #0
__loop:
  CMP     r1

  B       __loop
  BX      r14
  .size _start, .-_start

@--------------------------
  .section .data.main, "a", %progbits  
__data__:
  .byte  0x59       @ 'Y'
  .ascii "Youssef"
