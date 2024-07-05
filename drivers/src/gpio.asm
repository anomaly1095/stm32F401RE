 
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb
  .include "../helper.asm"

@-----------------------------------------------------------------
@-----------------------------------------------------------------
@-----------------------------------------------------------------
  .section .text.gpio_driver, "ax", %progbits
  
@--------------------------------------------------------
@ arg 0: r0 holds the port ("A", "B", "C", "D", "E", "H")
@ arg 1: r1 holds the pin number (0..15)
@ arg 2: r2 holds the pin mode (0: input, 1: output, 2: alternate function , 3: analog mode)
  .global _gpio_set_moder
  .type _gpio_set_moder, %function
_gpio_set_moder:
  PUSH_R0_R5
  CMP     r0, #0x41         @ "A"
  ITT     EQ
  LDREQ   r0, =GPIOA_BB     @ load gpio port A bitband address
  BEQ     __gpio_set_moder
  CMP     r0, #0x42         @ "B"
  ITT     EQ
  LDREQ   r0, =GPIOB_BB     @ load gpio port B bitband address
  BEQ     __gpio_set_moder
  CMP     r0, #0x43         @ "C"
  ITT     EQ
  LDREQ   r0, =GPIOC_BB     @ load gpio port C bitband address
  BEQ     __gpio_set_moder
  CMP     r0, #0x44         @ "D"
  ITT     EQ
  LDREQ   r0, =GPIOD_BB     @ load gpio port D bitband address
  BEQ     __gpio_set_moder
  CMP     r0, #0x45         @ "E"
  ITT     EQ
  LDREQ   r0, =GPIOE_BB     @ load gpio port E bitband address
  BEQ     __gpio_set_moder
  CMP     r0, #0x48         @ "H"
  ITT     EQ
  LDREQ   r0, =GPIOH_BB     @ load gpio port H bitband address
  BEQ     __gpio_set_moder
  BX      r14               @ failure return

__gpio_set_moder:
  LDR     r3, =GPIOx_MODER  @ base bit-band address of the register
  MOV     r4, #0x04         @ 4 bytes per bit 
  MOV     r5, #2            @ 2 bits per pin
  @ calculating pin's bit offset
  MUL     r1, r1, r4
  MUL     r1, r1, r5
  ADD     r1, r1, r3     
  BIC     r3, r2, r5        @ save bit 0 of r2 in r3 by clearing bit 1
  LSR     r4, r2, #1        @ save bit 1 of r2 in r3 by right shifting
  STR     r3, [r0, r1]!     @ set 0
  STR     r4, [r0, #0x04]   @ set 1
  POP_R0_R5
  BX      r14
  .size _gpio_set_moder, .-_gpio_set_moder

@--------------------------------------------------------
@ arg 0: r0 holds the port ("A", "B", "C", "D", "E", "H")
@ arg 1: r1 holds the pin number (0..15)
@ arg 2: r2 holds the pin mode (0: input, 1: output, 2: alternate function , 3: analog mode)

  .global _gpio_set_typer
  .type _gpio_set_typer, %function
_gpio_set_typer:
  






@-----------------------------------------------------------------
@-----------------------------------------------------------------
@-----------------------------------------------------------------
  .section .rodata.gpio_driver, "a", %progbits
  @ bit-band gpio port addresses
  .equ GPIOA_BB, 0x42400000
  .equ GPIOB_BB, 0x42408000
  .equ GPIOC_BB, 0x42410000
  .equ GPIOD_BB, 0x42418000
  .equ GPIOE_BB, 0x42420000
  .equ GPIOH_BB, 0x42438000
  @ bit-band gpio register offsets
  .equ GPIOx_MODER, 0x00
  .equ GPIOx_OTYPER, 0x80
  .equ GPIOx_OSPEEDR, 0x100
  .equ GPIOx_PUPDR, 0x180
  .equ GPIOx_IDR, 0x200
  .equ GPIOx_ODR, 0x280
  .equ GPIOx_LCKR, 0x300
  .equ GPIOx_AFRL, 0x380
  .equ GPIOx_AFRH, 0x400