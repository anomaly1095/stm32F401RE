
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb
  #include "../helper.asm"

  .section .text.drivers.rtc_driver, "ax", %progbits


@-----------------------------------------------------------------
  .section .rodata.drivers.rtc_driver, "a", %progbits
  
