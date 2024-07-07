
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb
  #include "../helper.asm"

  .section .text.drivers.nvic_driver, "ax", %progbits
@ expects r0 to hold the index or position of the exception to enable
_NVIC_enable:
  LDR     r1, =NVIC_ISER0
  MOV     r2, #0b1
  CMP     r0, #31         @ use NVIC_ISER0
  BLE     __NVIC_enable0
  CMP     r0, #63         @ use NVIC_ISER1
  BLE     __NVIC_enable1
  B       __NVIC_enable2  @ else use NVIC_ISER2
__NVIC_enable0:
  LSL     r2, r2, r0      @ shift the mask to the correct offset
  LDR     r0, [r1]
  ORR     r0, r0, r2      @ set the bit
  STR     r0, [r1]
  BX      r14             @ return

__NVIC_enable1:
  SUB     r0, r0, #32     @ normalize the bit offsets to start at 0
  LSL     r2, r2, r0      @ shift the mask to the correct offset
  LDR     r0, [r1, #0x04]!
  ORR     r0, r0, r2      @ set the bit
  STR     r0, [r1]
  BX      r14             @ return

__NVIC_enable2:
  SUB     r0, r0, #64     @ normalize the bit offsets to start at 0
  LSL     r2, r2, r0      @ shift the mask to the correct offset
  LDR     r0, [r1, #0x08]!
  ORR     r0, r0, r2      @ set the bit
  STR     r0, [r1]
  BX      r14             @ return

@-----------------------------------------------------------------
  .section .rodata.drivers.nvic_driver, "a", %progbits
  .equ NVIC_ISER0, 0xE000E100

