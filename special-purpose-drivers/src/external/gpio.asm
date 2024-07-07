 
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb
  #include "../helper.asm"


  .section .text.drivers.gpio_driver, "ax", %progbits
  
@--------------------------------------------------------
@ arg 0: r0 holds the port ("A", "B", "C", "D", "E", "H")
@ arg 1: r1 holds the pin number (0..15)
@ arg 2: r2 holds the pin mode (0: input, 1: output, 2: alternate function , 3: analog mode)
  .global _gpio_set_moder
  .type _gpio_set_moder, %function
_gpio_set_moder:
  GPIO_CMP_LDR_PORT 0x41, GPIOA_BB
  BEQ     __gpio_set_moder
  GPIO_CMP_LDR_PORT 0x42, GPIOB_BB       @ compare and load gpio port B bitband address
  BEQ     __gpio_set_moder
  GPIO_CMP_LDR_PORT 0x43, GPIOC_BB       @ compare and load gpio port C bitband address
  BEQ     __gpio_set_moder
  GPIO_CMP_LDR_PORT 0x44, GPIOD_BB       @ compare and load gpio port D bitband address
  BEQ     __gpio_set_moder
  GPIO_CMP_LDR_PORT 0x45, GPIOE_BB       @ compare and load gpio port E bitband address
  BEQ     __gpio_set_moder
  GPIO_CMP_LDR_PORT 0x48, GPIOH_BB       @ compare and load gpio port H bitband address
  BEQ     __gpio_set_moder
  BX      r14                 @ failure return

__gpio_set_moder:
  @ calculating pin's bit offset
  MOV     r3, #8              @ 4 bytes per bit * 2 bits per pin 
  MUL     r1, r1, r3          @ mult the pinnum by the offset
  LDR     r3, =GPIOx_MODER    @ base bit-band address of the register
  ADD     r1, r1, r3          @ add the bitoffset to reg offset
  MOV     r3, #0b10           @ mask bit 1
  BIC     r3, r2, r3          @ save bit 0 of r2 in r3 by clearing bit 1
  STR     r3, [r0, r1]!       @ set bit 0  
  LSR     r3, r2, #1          @ save bit 1 of r2 in r3 by right shifting
  STR     r3, [r0, #0x04]     @ set bit 1
  BX      r14
  .size _gpio_set_moder, .-_gpio_set_moder

@--------------------------------------------------------
@ arg 0: r0 holds the port ("A", "B", "C", "D", "E", "H")
@ arg 1: r1 holds the pin number (0..15)
@ arg 2: r2 holds the output type (0: push-pull, 1: open-drain)
  .global _gpio_set_otyper
  .type _gpio_set_otyper, %function
_gpio_set_otyper:
  GPIO_CMP_LDR_PORT 0x41, GPIOA_BB       @ load gpio port A bitband address
  BEQ     __gpio_set_otyper
  GPIO_CMP_LDR_PORT 0x42, GPIOB_BB       @ load gpio port B bitband address
  BEQ     __gpio_set_otyper
  GPIO_CMP_LDR_PORT 0x43, GPIOC_BB       @ load gpio port C bitband address
  BEQ     __gpio_set_otyper
  GPIO_CMP_LDR_PORT 0x44, GPIOD_BB       @ load gpio port D bitband address
  BEQ     __gpio_set_otyper
  GPIO_CMP_LDR_PORT 0x45, GPIOE_BB       @ load gpio port E bitband address
  BEQ     __gpio_set_otyper
  GPIO_CMP_LDR_PORT 0x48, GPIOH_BB       @ load gpio port H bitband address
  BEQ     __gpio_set_otyper

__gpio_set_otyper:
  @ calculating pin's bit offset
  MOV     r3, #4              @ 4 bytes per bit * 1 bit per pin 
  MUL     r1, r1, r3          @ mult the pin-num by the bit-offset
  LDR     r3, =GPIOx_OTYPER   @ bit-band offset for GPIOx_OTYPER
  ADD     r1, r1, r3          @ add the bitoffset to reg offset
  STR     r2, [r0, r1]        @ save the output type
  BX      r14
  .size _gpio_set_otyper, .-_gpio_set_otyper

@--------------------------------------------------------
@ arg 0: r0 holds the port ("A", "B", "C", "D", "E", "H")
@ arg 1: r1 holds the pin number (0..15)
@ arg 2: r2 holds the output speed (00: low speed, 01: medium speed, 10: high speed, 11: very high speed)
  .global _gpio_set_ospeeder
  .type _gpio_set_ospeeder, %function
_gpio_set_ospeeder:
  GPIO_CMP_LDR_PORT 0x41, GPIOA_BB       @ load gpio port A bitband address
  BEQ     __gpio_set_ospeeder
  GPIO_CMP_LDR_PORT 0x42, GPIOB_BB       @ load gpio port B bitband address
  BEQ     __gpio_set_ospeeder
  GPIO_CMP_LDR_PORT 0x43, GPIOC_BB       @ load gpio port C bitband address
  BEQ     __gpio_set_ospeeder
  GPIO_CMP_LDR_PORT 0x44, GPIOD_BB       @ load gpio port D bitband address
  BEQ     __gpio_set_ospeeder
  GPIO_CMP_LDR_PORT 0x45, GPIOE_BB       @ load gpio port E bitband address
  BEQ     __gpio_set_ospeeder
  GPIO_CMP_LDR_PORT 0x48, GPIOH_BB       @ load gpio port H bitband address
  BEQ     __gpio_set_ospeeder
__gpio_set_ospeeder:
  @ calculating pin's bit offset
  MOV     r3, #8              @ 4 bytes per bit * 2 bits per pin 
  MUL     r1, r1, r3          @ mult the pinnum by the offset
  LDR     r3, =GPIOx_OSPEEDR  @ base bit-band address of the register
  ADD     r1, r1, r3          @ add the bitoffset to reg offset
  MOV     r3, #0b10           @ mask bit 1
  BIC     r3, r2, r3          @ save bit 0 of r2 in r3 by clearing bit 1
  STR     r3, [r0, r1]!       @ set bit 0
  LSR     r3, r2, #1          @ save bit 1 of r2 in r3 by right shifting
  STR     r3, [r0, #0x04]     @ set bit 1
  BX      r14
  .size _gpio_set_ospeeder, .-_gpio_set_ospeeder

@--------------------------------------------------------
@ arg 0: r0 holds the port ("A", "B", "C", "D", "E", "H")
@ arg 1: r1 holds the pin number (0..15)
@ arg 2: r2 holds the pull state (00: none, 01: pull-up, 10: pull-down, 11: reserved)
  .global _gpio_set_pupdr
  .type _gpio_set_pupdr, %function
_gpio_set_pupdr:
  GPIO_CMP_LDR_PORT 0x41, GPIOA_BB       @ load gpio port A bitband address
  BEQ     __gpio_set_pupdr
  GPIO_CMP_LDR_PORT 0x42, GPIOB_BB       @ load gpio port B bitband address
  BEQ     __gpio_set_pupdr
  GPIO_CMP_LDR_PORT 0x43, GPIOC_BB       @ load gpio port C bitband address
  BEQ     __gpio_set_pupdr
  GPIO_CMP_LDR_PORT 0x44, GPIOD_BB       @ load gpio port D bitband address
  BEQ     __gpio_set_pupdr
  GPIO_CMP_LDR_PORT 0x45, GPIOE_BB       @ load gpio port E bitband address
  BEQ     __gpio_set_pupdr
  GPIO_CMP_LDR_PORT 0x48, GPIOH_BB       @ load gpio port H bitband address
  BEQ     __gpio_set_pupdr
  BX      r14                 @ failure return
__gpio_set_pupdr:
  @ calculating pin's bit offset
  MOV     r3, #8              @ 4 bytes per bit * 2 bits per pin 
  MUL     r1, r1, r3          @ mult the pinnum by the offset
  LDR     r3, =GPIOx_PUPDR    @ base bit-band address of the register
  ADD     r1, r1, r3          @ add the bit-offset to reg offset
  MOV     r3, #0b10           @ mask bit 1
  BIC     r3, r2, r3          @ save bit 0 of r2 in r3 by clearing bit 1
  STR     r3, [r0, r1]!       @ set bit 0
  LSR     r3, r2, #1          @ save bit 1 of r2 in r3 by right shifting
  STR     r3, [r0, #0x04]     @ set bit 1
  BX      r14
  .size _gpio_set_pupdr, .-_gpio_set_pupdr

@--------------------------------------------------------
@ arg 0: r0 holds the port ("A", "B", "C", "D", "E", "H")
@ arg 1: r1 holds the pin number (0..15)
@ arg 2: r2 will hold the state of the pin(0: no signal, 1: signal)
  .global _gpio_get_idr
  .type _gpio_get_idr, %function
_gpio_get_idr:
  GPIO_CMP_LDR_PORT 0x41, GPIOA_BB       @ load gpio port A bitband address
  BEQ     __gpio_get_idr
  GPIO_CMP_LDR_PORT 0x42, GPIOB_BB       @ load gpio port B bitband address
  BEQ     __gpio_get_idr
  GPIO_CMP_LDR_PORT 0x43, GPIOC_BB       @ load gpio port C bitband address
  BEQ     __gpio_get_idr
  GPIO_CMP_LDR_PORT 0x44, GPIOD_BB       @ load gpio port D bitband address
  BEQ     __gpio_get_idr
  GPIO_CMP_LDR_PORT 0x45, GPIOE_BB       @ load gpio port E bitband address
  BEQ     __gpio_get_idr
  GPIO_CMP_LDR_PORT 0x48, GPIOH_BB       @ load gpio port H bitband address
  BEQ     __gpio_get_idr
  BX      r14                 @ failure return
__gpio_get_idr:
  @ calculating pin's bit offset
  LDR     r2, =GPIOx_IDR      @ base bit-band address of the register
  MOV     r3, #4              @ 4 bytes per bit * 1 bit per pin 
  MUL     r1, r1, r3          @ mult the pin-num by the bit-offset
  ADD     r1, r1, r2          @ add the bit-offset to reg-offset
  LDR     r2, [r0, r1]        @ get bit
  BX      r14
  .size _gpio_get_idr, .-_gpio_get_idr

@--------------------------------------------------------
@ arg 0: r0 holds the port ("A", "B", "C", "D", "E", "H")
@ arg 1: r1 holds the pin number (0..15)
@ arg 2: r2 holds the output value (0: signal off, 1: signal on)
  .global _gpio_set_odr
  .type _gpio_set_odr, %function
_gpio_set_odr:
  GPIO_CMP_LDR_PORT 0x41, GPIOA_BB       @ load gpio port A bitband address
  BEQ     __gpio_set_odr
  GPIO_CMP_LDR_PORT 0x42, GPIOB_BB       @ load gpio port B bitband address
  BEQ     __gpio_set_odr
  GPIO_CMP_LDR_PORT 0x43, GPIOC_BB       @ load gpio port C bitband address
  BEQ     __gpio_set_odr
  GPIO_CMP_LDR_PORT 0x44, GPIOD_BB       @ load gpio port D bitband address
  BEQ     __gpio_set_odr
  GPIO_CMP_LDR_PORT 0x45, GPIOE_BB       @ load gpio port E bitband address
  BEQ     __gpio_set_odr
  GPIO_CMP_LDR_PORT 0x48, GPIOH_BB       @ load gpio port H bitband address
  BEQ     __gpio_set_odr
  BX      r14                 @ failure return
__gpio_set_odr:
  @ calculating pin's bit offset
  MOV     r3, #4              @ 4 bytes per bit * 1 bit per pin 
  MUL     r1, r1, r3          @ mult the pin-num by the offset
  LDR     r3, =GPIOx_ODR      @ bit-band offset for GPIOx_OTYPERS
  ADD     r1, r1, r3          @ add the bit-offset to reg-offset
  STR     r2, [r0, r1]        @ save the output type
  BX      r14
  .size _gpio_set_odr, .-_gpio_set_odr

@--------------------------------------------------------
@ arg 0: r0 holds the port ("A", "B", "C", "D", "E", "H")
@ arg 1: r1 holds the pin number (0..15)
@ arg 2: r2 holds the alternate function number (0: AF0...15: AF15)
@ Write the function for locking the port i guess



@--------------------------------------------------------
@ arg 0: r0 holds the port ("A", "B", "C", "D", "E", "H")
@ arg 1: r1 holds the pin number (0..15)
@ arg 2: r2 holds the alternate function number (0: AF0...15: AF15)
  .global _gpio_set_af
  .type _gpio_set_af, %function
_gpio_set_af:
  GPIO_CMP_LDR_PORT 0x41, GPIOA_BB       @ load gpio port A bitband address
  BEQ     __gpio_set_af
  GPIO_CMP_LDR_PORT 0x42, GPIOB_BB       @ load gpio port B bitband address
  BEQ     __gpio_set_af
  GPIO_CMP_LDR_PORT 0x43, GPIOC_BB       @ load gpio port C bitband address
  BEQ     __gpio_set_af
  GPIO_CMP_LDR_PORT 0x44, GPIOD_BB       @ load gpio port D bitband address
  BEQ     __gpio_set_af
  GPIO_CMP_LDR_PORT 0x45, GPIOE_BB       @ load gpio port E bitband address
  BEQ     __gpio_set_af
  GPIO_CMP_LDR_PORT 0x48, GPIOH_BB       @ load gpio port H bitband address
  BEQ     __gpio_set_af
__gpio_set_af:
  MOV     r3, #16             @ 4 bytes per bit * 4 bits per pin 
  CMP     r1, #8              @ check if the pin number is configured in GPIOx_AFRL or GPIOx_AFRH
  MUL     r1, r1, r3          @ mult the pin-num by the offset
  ITE     GE
  LDRGE   r3, =GPIOx_AFRH     @ high register (pin-num >= 8)
  LDRLT   r3, =GPIOx_AFRL     @ low register (pin-num < 8)
  ADD     r1, r1, r3          @ add the bitoffset to reg offset
  
  @ store bit by bit
  MOV     r3, #0b1110         @ mask bit 1 2 3
  BIC     r3, r2, r3
  STR     r3, [r0, r1]!       @ save bit 0
  
  MOV     r3, #0b1101         @ mask bit 0 2 3
  LSR     r3, r3, #1
  BIC     r3, r2, r3
  STR     r3, [r0, 0x04]!     @ save bit 1
  
  MOV     r3, #0b1011         @ mask bit 0 1 3
  LSR     r3, r3, #2
  BIC     r3, r2, r3
  STR     r3, [r0, 0x04]!     @ save bit 2
  
  LSR     r3, r2, #3          @ mask bit 0 1 2
  STR     r3, [r0, 0x04]      @ save bit 3
  BX      r14
  .size _gpio_set_af, .-_gpio_set_af


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
