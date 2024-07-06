 
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb
  #include "../helper.asm"


  .section .text.drivers.gpio_driver, "ax", %progbits
  


@-----------------------------------------------------------------
  .section .rodata.drivers.gpio_driver, "a", %progbits
  @ bit-band gpio port addresses
  .equ GPIOA_BB, 0x42400000
  .equ GPIOB_BB, 0x42408000
  .equ GPIOC_BB, 0x42410000
  .equ GPIOD_BB, 0x42418000
  .equ GPIOE_BB, 0x42420000
  .equ GPIOH_BB, 0x42438000
  @ bit-band gpio register offsets
  .equ GPIOx_MODER,  0x00
  .equ GPIOx_OTYPER, 0x80
  .equ GPIOx_OSPEEDR,0x100
  .equ GPIOx_PUPDR,  0x180
  .equ GPIOx_IDR,    0x200
  .equ GPIOx_ODR,    0x280
  .equ GPIOx_LCKR,   0x300
  .equ GPIOx_AFRL,   0x380
  .equ GPIOx_AFRH,   0x400
