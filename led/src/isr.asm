.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

@-------------------------------------------

  .section .text.isr, "ax", %progbits
  .type SysTick_Handler, %function
  .type EXTI15_10_IRQHandler, %function
  .global SysTick_Handler
  .global EXTI15_10_IRQHandler

SysTick_Handler:
  LDR   r0, =__isr_data
  LDR   r1, [r0]
  ADD   r1, r1, #1
  MOVW  r2, #1000         @ check if milliseconds = 1000
  CMP   r1, r2
  BXNE  lr                @ return if ms not yet 1000
  
  LDR   r2, [r0, #0x04]
  ADD   r2, r2, #1        @ add a second
  STR   r2, [r0, #0x04]   @ store back seconds
  MOV   r1, #1
  STR   r1, [r0]          @ store back milliseconds
  BX    lr

  .size SysTick_Handler, .-SysTick_Handler

@ custom handler for this app
EXTI15_10_IRQHandler:
  MOV   r2, #0b1
  @ BUTTON1
  LDR   r0, =GPIOC_IDR13_BB
  LDR   r1, [r0]
  TST   r1, r2            @ check if button is pressed
  BXEQ  lr                @ if not return
  @ LD2
  LDR   r0, =GPIOA_ODR5_BB
  LDR   r1, [r0]
  TST   r1, r2            @ check if led is on
  MOVEQ r2, #0b0          @ if on we turn off
  STR   r2, [r0]
  @ clear pending
  LDR   r0, =EXTI_PR13_BB
  STR   r2, [r0]          @ clear pending bit of EXTI13
  BX    lr
  .size EXTI15_10_IRQHandler, .-EXTI15_10_IRQHandler

@-------------------------------------------
  
  .section .rodata, "a", %progbits
  @ bb or BB stands for the bit-band address
  @ IDR registers of each GPIO port
  .equ EXTI_PR13_BB, 0x422782B4 @ bb address of bit 13 of EXTI_PR
  .equ GPIOA_ODR5_BB, 0x42400294 @ bb address of bit 5 in GPIOA_ODR
  .equ GPIOC_IDR13_BB, 0x42410234 @ bb address of bit 13 in GPIOC_IDR

@-------------------------------------------

  .section .data.isr_data, "aw", %progbits
  .type __isr_data, %object
  .global __isr_data
__isr_data:
  .word 0 @ systick millisecond counter
  .word 0 @ systick second counter

  .size __isr_data, .-__isr_data
