@ 
@ FILE for main firmware entry point (_start)
@ 

  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16 // HARDWARE FLOATING POINT UNIT
  .thumb

  .extern GPIOC_BASE 

@-------------------------------------------
  .section .text.firmware, "ax", %progbits
  .type _start, %function
  .global _start
_start:
  LDR   r0, =GPIOC_BASE 
  MOV   r2, #(0b01 << 8) 
  MOV   r4, #(0b01 << 5)

  @ wait for sensor signal
sensor_off:
  LDR   r1, [r0, #0x10] @ GPIOC_IDR address (r)
  TST   r1, r2
  BEQ   sensor_off

led_on:
  LDR   r3, [r0, #0x14]  @ GPIOC_ODR address (rw)
  ORR   r3, r3, r4
  STR   r3, [r0, #0x14]  @ GPIOC_ODR address (rw)

sensor_on:
  LDR   r1, [r0, #0x10] @ GPIOC_IDR address (r)
  TST   r1, r2
  BNE   sensor_on

led_off:
  LDR   r3, [r0, #0x14]  @ GPIOC_ODR address (rw)
  BIC   r3, r3, r4
  STR   r3, [r0, #0x14]  @ GPIOC_ODR address (rw)
  B     sensor_off

  @ return
  BX lr

  .size _start, .-_start

@-------------------------------------------
