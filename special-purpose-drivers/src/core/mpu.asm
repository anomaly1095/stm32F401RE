
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb
  #include "../helper.asm"

  .section .text.drivers.mpu_driver, "ax", %progbits


@-----------------------------------------------------------------
  .section .rodata.drivers.mpu_driver, "a", %progbits
  
