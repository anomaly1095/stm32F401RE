
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb
  #include "../helper.asm"

  .section .text.drivers.exti_driver, "ax", %progbits

@--------------------------------------------------------
@ configure the EXTI to select the ports that they will handle 
@ arg 0: r0 holds the port ("A", "B", "C", "D", "E", "H")
@ arg 1: r1 holds the pin number or exception number (same) (0..15)
  .global _syscfg_set_exti
  .type _syscfg_set_exti, %function
_syscfg_set_exti:
  PUSH_R0_R3
  LDR     r2, =SYSCFG_BASE
  MOVW    r2, #0b1111
  GPIO_CMP_LDR_PORT 0x41, PAx_pin       @ compare and load gpio port A bit mask in r0
  BEQ     __syscfg_set_exti
  GPIO_CMP_LDR_PORT 0x42, PBx_pin       @ compare and load gpio port B bit mask in r0
  BEQ     __syscfg_set_exti
  GPIO_CMP_LDR_PORT 0x43, PCx_pin       @ compare and load gpio port C bit mask in r0
  BEQ     __syscfg_set_exti
  GPIO_CMP_LDR_PORT 0x44, PDx_pin       @ compare and load gpio port D bit mask in r0
  BEQ     __syscfg_set_exti
  GPIO_CMP_LDR_PORT 0x45, PEx_pin       @ compare and load gpio port E bit mask in r0
  BEQ     __syscfg_set_exti
  GPIO_CMP_LDR_PORT 0x48, PHx_pin       @ compare and load gpio port H bit mask in r0
  BEQ     __syscfg_set_exti
  POP_R0_R3
  BX      r14                           @ failure return
__syscfg_set_exti:
  CMP     r1, #3
  BLE     __syscfg_set_exti1            @ EXTIx: (x <= 3)
  CMP     r1, #7
  BLE     __syscfg_set_exti2            @ EXTIx: (3 < x <= 7)
  CMP     r1, #11
  BLE     __syscfg_set_exti3            @ EXTIx: (7 < x <= 11)
  BGT     __syscfg_set_exti4            @ EXTIx: (11 < x <= 15)
__syscfg_set_exti1:
  ADD     r2, r2, #0x08                 @ set the Exti offset
  LSL     r0, r0, r1                    @ shift the EXTI mask by the bit offset
  LSL     r3, r3, r1                    @ shift the clear mask by the bit offset
  LDR     r1, [r2]                      @ load the register value in r1
  BIC     r1, r1, r3                    @ clear the old bits
  ORR     r1, r1, r3                    @ set the new bits
  STR     r0, [r2]
  POP_R0_R3
  BX      r14                           @ return
syscfg_set_exti2:
  ADD     r2, r2, #0x0C                 @ set the Exti offset
  SUB     r1, r1, #4                    @ normalize the address to the register start
  LSL     r0, r0, r1                    @ shift the EXTI mask by the bit offset
  LSL     r3, r3, r1                    @ shift the clear mask by the bit offset
  LDR     r1, [r2]                      @ load the register value in r1
  BIC     r1, r1, r3                    @ clear the old bits
  ORR     r1, r1, r3                    @ set the new bits
  STR     r0, [r2]
  POP_R0_R3
  BX      r14                           @ return
__syscfg_set_exti3:
  ADD     r2, r2, #0x10                 @ set the Exti offset
  SUB     r1, r1, #8                    @ normalize the address to the register start
  LSL     r0, r0, r1                    @ shift the EXTI mask by the bit offset
  LSL     r3, r3, r1                    @ shift the clear mask by the bit offset
  LDR     r1, [r2]                      @ load the register value in r1
  BIC     r1, r1, r3                    @ clear the old bits
  ORR     r1, r1, r3                    @ set the new bits
  STR     r0, [r2]
  POP_R0_R3
  BX      r14                           @ return
__syscfg_set_exti4:
  ADD     r2, r2, #0x14                 @ set the Exti offset
  SUB     r1, r1, #12                    @ normalize the address to the register start
  LSL     r0, r0, r1                    @ shift the EXTI mask by the bit offset
  LSL     r3, r3, r1                    @ shift the clear mask by the bit offset
  LDR     r1, [r2]                      @ load the register value in r1
  BIC     r1, r1, r3                    @ clear the old bits
  ORR     r1, r1, r3                    @ set the new bits
  STR     r0, [r2]
  POP_R0_R3
  BX      r14                           @ return
  .size _syscfg_set_exti, .-_syscfg_set_exti

@--------------------------------------------------------
@ enable or disable the conpensation cell 
@ arg 0: r0 holds the new state of the compensation cell (0, 1)
  .global _syscfg_set_comp_cell
  .type _syscfg_set_comp_cell, %function
_syscfg_set_comp_cell:
  PUSH_R0_R2
  LDR     r1, =SYSCFG_BASE
  LDR     r2, [r1, #0x20]!    @ get the current value of SYSCFG_CMPCR
  CMP     r0, #1
  ITEE    EQ
  ORREQ   r2, r2, r0          @ in case r0=1 (enable) we use ORR
  MOVNE   r0, #0b1
  BICNE   r2, r2, r0          @ in case r0=0 (enable) we use BIC
  STR     r2, [r1]            @ save back the value in SYSCFG_CMPCR
  POP_R0_R2
  BX      r14


  .size _syscfg_set_comp_cell, .-_syscfg_set_comp_cell

@--------------------------------------------------------
@ checks the state of the compensation cells
@ arg 0: r0 will hold the value of the cell (1: enabled, 0,, disabled)
  .global _syscfg_rdy_comp_cell
  .type _syscfg_rdy_comp_cell, %function
_syscfg_rdy_comp_cell:
  PUSH_R0_R1
  LDR     r0, =SYSCFG_BASE
  LDR     r0, [r0, #0x20]!      @ SYSCFG_CMPCR reg
  MOV     r1, #(0b1 << 8)       @ READY bit
  TST     r0, r1
  ITE     EQ
  MOVEQ   r0, #0                @ test false (cell disabled)
  MOVNE   r0, #1                @ test true (cell enabled)
  POP_R0_R1
  BX      r14

  .size _syscfg_rdy_comp_cell, .-_syscfg_rdy_comp_cell

@-----------------------------------------------------------------
  .section .rodata.drivers.exti_driver, "a", %progbits
  .equ SYSCFG_BASE, 0x40013800
  .equ PAx_pin, 0b0
  .equ PBx_pin, 0b01
  .equ PCx_pin, 0b10
  .equ PDx_pin, 0b11
  .equ PEx_pin, 0b100
  .equ PHx_pin, 0b0111
