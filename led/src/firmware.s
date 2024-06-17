.global _start
.extern gpioA_config

  .section .text.firmware, "ax", %progbits
  .type _start, %function

_start:
  BL  gpioA_config
  LDR r4, =DELAY
  MOV r2, #(0b1 << 5)
  LDR r0, =GPIOA_ODR

_led_high:
  LDR r1, [r0]
  ORR r1, r1, r2 
  STR r1, [r0]
  MOV r3, #0
  BL  delay

_led_low:
  LDR r1, [r0]
  BIC r1, r1, r2 
  STR r1, [r0]
  MOV r3, #0
  BL  delay
  B   _led_high
  
  BX  lr // go to default handler

delay:
  CMP r3, r4         // Compare counter with delay value
  SUB r3, r3, #1     // Decrement counter
  BNE delay          // Loop back if not equal (branch not equal)
  BX lr              // Return if equal


  .section .rodata, "a", %progbits

.equ GPIOA_BSRR, 0x40020018
.equ GPIOA_ODR, 0x40020014

// 1 second at 84mhz (each loop iteration consumes a minimum of 4 cpu clock cycles) --> 4min..6max
// CMP and SUB are in 1 cycle each while CMP<cc> depends on the number of cycles required for a pipeline refill. This ranges from 1 to 3
// depending on the alignment and width of the target instruction, and whether the
// processor manages to speculate the address early
.equ DELAY, 20000000 
  .align 4
