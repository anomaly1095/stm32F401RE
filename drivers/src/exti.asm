
.syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb
  #include "../helper.asm"

@-----------------------------------------------------------------
@-----------------------------------------------------------------
@-----------------------------------------------------------------
  .section .text.drivers.exti_driver, "ax", %progbits