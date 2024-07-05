
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb
  #include "../helper.asm"

  .section .text.drivers.i2c_driver, "ax", %progbits


@-----------------------------------------------------------------
  .section .rodata.drivers.i2c_driver, "a", %progbits
  
