.global _start
.extern gpioA_config

  .section .text.firmware, "ax", %progbits
    .type _start %function

_start:
  BL  gpioA_config
  LDR r2, =DELAY

_led_high:
  LDR r0, =GPIOA_BSRR
  MOV r1, #(0b1 << 5)
  STR r1, [r0]
  MOV r3, #0
  BL  delay
_led_low:
  LDR r0, =GPIOA_BSRR       // Load the address of GPIOA_BSRR
  MOV r1, #0b1
  LSL r1, r1, #21
  STR r1, [r0]              // Write the value to GPIOA_BSRR, resetting pin 5 low
  MOV r3, #0
  BL  delay
  B   _led_high

  BX  lr // go to default handler

delay:
  CMP r3, r2         // Compare counter with delay value
  SUB r3, r3, #1     // Decrement counter
  BNE delay          // Loop back if not equal (branch not equal)
  BX lr              // Return if equal


  .section .rodata, "a", %progbits

.equ GPIOA_BSRR, 0x40020018
.equ DELAY, 28000000 // 1 second at 84mhz
