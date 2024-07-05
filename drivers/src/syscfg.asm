
.syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb
  #include "../helper.asm"

@-----------------------------------------------------------------
@-----------------------------------------------------------------
@-----------------------------------------------------------------
  .section .text.drivers.exti_driver, "ax", %progbits

@--------------------------------------------------------
@ configure the system remap mode used to bypass physical booting 
@ remapping allows instruction access via the ICode bus for better perf
@ done with the BOOT0 (pin60) BOOT1 (pin28-PB28) (on 64pin package of stm32F401)
@ arg 0: r0 holds the BOOT mode (0: main FLASH, 1: system FLASH, 2: embedded SRAM)
_syscfg_set_memrmp:
  push  {r1}
  LDR   r1, =SYSCFG_BASE
  STR   r0, [r1]
  pop   {r1}
  BX    r14
  .size _syscfg_set_memrmp, .-_syscfg_set_memrmp

@--------------------------------------------------------
@ configure the EXTI to select the ports that they will handle 
@ arg 0: r0 holds the port ("A", "B", "C", "D", "E", "H")
@ arg 1: r1 holds the pin number or exception number (same) (0..15)
_syscfg_set_exti:
  PUSH_R0_R2
  LDR     r2, =SYSCFG_BASE
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
  POP_R0_R2
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
  LSL     r0, r0, r1
  STR     r0, [r2, r1]
  POP_R0_R2
  BX      r14                           @ return
syscfg_set_exti2:
  SUB     r1, r1, #4                    @ normalize the address to the register start
  LSL     r0, r0, r1
  STR     r0, [r2, r1]
  POP_R0_R2
  BX      r14                           @ return

__syscfg_set_exti3:
  SUB     r1, r1, #8                    @ normalize the address to the register start
  LSL     r0, r0, r1
  STR     r0, [r2, r1]
  POP_R0_R2
  BX      r14                           @ return

__syscfg_set_exti4:
  SUB     r1, r1, #12                   @ normalize the address to the register start
  LSL     r0, r0, r1
  STR     r0, [r2, r1]
  POP_R0_R2
  BX      r14                           @ return

  .size _syscfg_set_exti, .-_syscfg_set_exti

@--------------------------------------------------------
@ configure the enable or disable the conpensation cell 
@ arg 0: r0 holds the new state of the compensation cell (0, 1)
_syscfg_set_comp_cell:
  

  .size _syscfg_set_exti, .-_syscfg_set_exti

@-----------------------------------------------------------------
@-----------------------------------------------------------------
@-----------------------------------------------------------------
  .section .rodata.drivers.dma_driver, "a", %progbits
  .equ SYSCFG_BASE, 0x40013800
  .equ PAx_pin, 0b0
  .equ PBx_pin, 0b01
  .equ PCx_pin, 0b10
  .equ PDx_pin, 0b11
  .equ PEx_pin, 0b100
  .equ PHx_pin, 0b0111
