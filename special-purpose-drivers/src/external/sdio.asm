
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb
  #include "../helper.asm"

  .section .text.drivers.sdio_driver, "ax", %progbits


@-----------------------------------------------------------------
  .section .rodata.drivers.sdio_driver, "a", %progbits
  
