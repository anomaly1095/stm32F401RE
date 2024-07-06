
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb
  #include "../helper.asm"

  .section .text.drivers.sysctrl, "ax", %progbits

@ configure the system remap mode used to bypass physical booting 
@ remapping allows instruction access via the ICode bus for better perf
@ done with the BOOT0 (pin60) BOOT1 (pin28-PB28) (on 64pin package of stm32F401)
@ arg 0: r0 holds the BOOT mode (0: main FLASH, 1: system FLASH, 2: embedded SRAM)
  .global _syscfg_set_memrmp
  .type _syscfg_set_memrmp, %function
_syscfg_set_memrmp:
  push  {r1}
  LDR   r1, =SYSCFG_BASE
  STR   r0, [r1]
  pop   {r1}
  BX    r14
  .size _syscfg_set_memrmp, .-_syscfg_set_memrmp


@--------------------------------------------------------
  .section .roata.drivers.sysctrl, "a", %progbits
  .extern SYSCFG_BASE
