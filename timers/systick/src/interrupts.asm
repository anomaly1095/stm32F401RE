@ 
@ file for interrupt service routine emplementations
@ 
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb


@----------------------------------------

  .section .text.interrupts, "ax", %progbits
  .type SysTick_Handler, %function

@ no need to push and pop registers (auto done for r0->r3 sp->spsr)
@ no need to clear interrupt flag for systick
SysTick_Handler:
  @ handle milliseconds
  LDR     r0, =systick_cntr
  LDR     r1, [r0, #0x00]
  MOVW    r3, #1
  ADD     r1, r3          @ increment milliseconds
  MOVW    r3, #1000
  CMP     r1, r3          @ check if milliseconds reached 1000
  BNE     SysTick_Handler_Exit
  @ increment seconds
  LDR     r2, [r0, #0x04]
  MOVW    r3, #1
  ADD     r2, r3

SysTick_Handler_Exit:
  STR     r1, [r0, #0x00] @ store back milliseconds value
  STR     r2, [r0, #0x04] @ store back seconds value
  BX      lr


  
@----------------------------------------


  .section .data, "aw", %progbits
systick_cntr:
  @ system milliseconds
  .word 0
  @ system seconds
  .word 0
