
.syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb
  #include "../helper.asm"


  .section .text.fpu.dma_driver, "ax", %progbits


@-----------------------------------------------------------------
  .section .rodata.drivers.fpu_driver, "a", %progbits
  
