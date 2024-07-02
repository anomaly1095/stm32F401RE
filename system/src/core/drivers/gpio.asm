

  .section .text.drivers, "ax", %progbits

@-------------------------------------------------------------------
@ resets gpio port
@ assumes r1, contains port to be reset: "A", "B", "C", "D", "E", "H"
@-------------------------------------------------------------------
  .global _gpio_port_reset
_gpio_port_reset:
  LDR   r0, =RCC_BASE
  LDR   r1, [r0, #0x10] @ RCC_AHB1RST reg
  CMP   r1, #0x41       @ "A"
  BEQ     __resetA
  CMP   r1, #0x42       @ "B"
  BEQ     __resetB
  CMP   r1, #0x43       @ "C"
  BEQ     __resetC
  CMP   r1, #0x44       @ "D"
  BEQ     __resetD
  CMP   r1, #0x45       @ "E"
  BEQ     __resetE
  CMP   r1, #0x48       @ "H"
  BEQ     __resetH
  BX    r14             @ return on failure
__resetA:
  MOV   r2, #0b1
  ORR   r1, r1, r2
  STR   r1, [r0, #0x10] @ RCC_AHB1RST reg
  BX    r14             @ return
__resetB:
  MOV   r2, #(0b1 << 1)
  ORR   r1, r1, r2
  STR   r1, [r0, #0x10] @ RCC_AHB1RST reg
  BX    r14             @ return
__resetC:
  MOV   r2, #(0b1 << 2)
  ORR   r1, r1, r2
  STR   r1, [r0, #0x10] @ RCC_AHB1RST reg
  BX    r14             @ return
__resetD:
  MOV   r2, #(0b1 << 3)
  ORR   r1, r1, r2
  STR   r1, [r0, #0x10] @ RCC_AHB1RST reg
  BX    r14             @ return
__resetE:
  MOV   r2, #(0b1 << 4)
  ORR   r1, r1, r2
  STR   r1, [r0, #0x10] @ RCC_AHB1RST reg
  BX    r14             @ return
__resetH:
  MOV   r2, #(0b1 << 7)
  ORR   r1, r1, r2
  STR   r1, [r0, #0x10] @ RCC_AHB1RST reg
  BX    r14             @ return
  .size _gpio_port_reset, .-_gpio_port_reset
@-------------------------------------------------------------------
@ enables gpio port's clock
@ assumes r1, contains port to be enabled: "A", "B", "C", "D", "E", "H"
@-------------------------------------------------------------------
  .global _gpio_port_enable
_gpio_port_enable:
  LDR   r0, =RCC_BASE
  LDR   r1, [r0, #0x30] @ RCC_AHB1ENR
  CMP   r1, #0x41       @ "A"
  BEQ     __enableA
  CMP   r1, #0x42       @ "B"
  BEQ     __enableB
  CMP   r1, #0x43       @ "C"
  BEQ     __enableC
  CMP   r1, #0x44       @ "D"
  BEQ     __enableD
  CMP   r1, #0x45       @ "E"
  BEQ     __enableE
  CMP   r1, #0x48       @ "H"
  BEQ     __enableH
  BX    r14             @ return
__enableA:
  MOV   r2, #0b1
  ORR   r1, r1, r2
  STR   r1, [r0, #0x30] @ RCC_AHB1ENR reg
  BX    r14             @ return
__enableB:
  MOV   r2, #(0b1 << 1)
  ORR   r1, r1, r2
  STR   r1, [r0, #0x30] @ RCC_AHB1ENR reg
  BX    r14             @ return
__enableC:
  MOV   r2, #(0b1 << 2)
  ORR   r1, r1, r2
  STR   r1, [r0, #0x30] @ RCC_AHB1ENR reg
  BX    r14
__enableD:
  MOV   r2, #(0b1 << 3)
  ORR   r1, r1, r2
  STR   r1, [r0, #0x30] @ RCC_AHB1ENR reg
  BX    r14             @ return
__enableE:
  MOV   r2, #(0b1 << 4)
  ORR   r1, r1, r2
  STR   r1, [r0, #0x30] @ RCC_AHB1ENR reg
  BX    r14             @ return
__enableH:
  MOV   r2, #(0b1 << 7)
  ORR   r1, r1, r2
  STR   r1, [r0, #0x30] @ RCC_AHB1ENR reg
  BX    r14             @ return
  .size _gpio_port_enable, .-_gpio_port_enable

@-------------------------------------------------------------------
@ sets pin mode: (input/output/AF/Analog)
@ assumes r1, contains port to be reset: "A", "B", "C", "D", "E", "H"
@ assumes r2, contains pin-mode (I, O, F, A)=(input, output, alternate function, analog) 
@ assumes r3, contains pin number
@-------------------------------------------------------------------
  .global _set_pinmode
_set_pinmode:
  MULS  r3, r3, #2        @ Calculate the register bit offset for the pin number
  CMP   r1, #0x41
  ITE   EQ
  LDREQ r0, =GPIOA_BASE
  BEQ   __check_pinmode
  CMP   r1, #0x42
  ITE   EQ
  LDREQ r0, =GPIOB_BASE
  BEQ   __check_pinmode
  CMP   r1, #0x43
  ITE   EQ
  LDREQ r0, =GPIOC_BASE
  BEQ   __check_pinmode
  CMP   r1, #0x44
  ITE   EQ
  LDREQ r0, =GPIOD_BASE
  BEQ   __check_pinmode
  CMP   r1, #0x45
  ITE   EQ
  LDREQ r0, =GPIOE_BASE
  BEQ   __check_pinmode
  CMP   r1, #0x48
  ITE   EQ
  LDREQ r0, =GPIOH_BASE
  BEQ   __check_pinmode
  BX    r14               @ return on failure

__check_pinmode:
  CMP   r2, #0x49         @ input mode
  BEQ   __set_pin_in
  CMP   r2, #0x4F         @ output mode
  BEQ   __set_pin_out
  CMP   r2, #0x46         @ alternate function mode
  BEQ   __set_pin_af
  CMP   r2, #0x41         @ analog mode
  BEQ   __set_pin_anlg
  BX    r14               @ return on failure

__set_pin_in:
  LDR   r1, [r0]          @ GPIO_MODER reg
  MOV   r2, #0b11
  LSL   r2, r2, r3        @ shift by number of bits to the correct pin num (0..15)
  BIC   r1, r1, r2        @ clear the bits for input 
  STR   r1, [r0]          @ GPIO_MODER reg
  BX    r14               @ return 
__set_pin_out:
  LDR   r1, [r0]          @ GPIO_MODER v
  MOV   r2, #0b11
  LSL   r2, r2, r3        @ shift by number of bits to the correct pin num (0..15)
  BIC   r1, r1, r2        @ clear the bits 
  MOV   r2, #0b01
  LSL   r2, r2, r3        @ shift by number of bits to the correct pin num (0..15)
  ORR   r1, r1, r2        @ set the bits for output 
  STR   r1, [r0]          @ GPIO_MODER reg
  BX    r14               @ return 
__set_pin_af:
  LDR   r1, [r0]          @ GPIO_MODER reg
  MOV   r2, #0b11
  LSL   r2, r2, r3        @ shift by number of bits to the correct pin num (0..15)
  BIC   r1, r1, r2        @ clear the bits for input 
  MOV   r2, #0b10
  LSL   r2, r2, r3        @ shift by number of bits to the correct pin num (0..15)
  ORR   r1, r1, r2        @ set the bits for alternate function mode 
  STR   r1, [r0]          @ GPIO_MODER reg
  BX    r14               @ return 
__set_pin_anlg:
  LDR   r1, [r0]          @ GPIO_MODER reg
  MOV   r2, #0b11
  LSL   r2, r2, r3        @ shift by number of bits to the correct pin num (0..15)
  ORR   r1, r1, r2        @ set the bits for analog mode 
  STR   r1, [r0]          @ GPIO_MODER reg
  BX    r14               @ return 

  .size _set_pinmode, .-_set_pinmode
@-------------------------------------------------------------------
@ sets pin output type: (push-pull/open-drain)
@ assumes r1, contains port: "A", "B", "C", "D", "E", "H"
@ assumes r2, contains output type (P, O)=(push-pull, open-drain) 
@ assumes r3, contains pin number
@-------------------------------------------------------------------
  .global _set_out_type
_set_out_type:
  CMP   r1, #0x41
  ITE   EQ
  LDREQ r0, =GPIOA_BASE
  BEQ   __set_otype
  CMP   r1, #0x42
  ITE   EQ
  LDREQ r0, =GPIOB_BASE
  BEQ   __set_otype
  CMP   r1, #0x43
  ITE   EQ
  LDREQ r0, =GPIOC_BASE
  BEQ   __set_otype
  CMP   r1, #0x44
  ITE   EQ
  LDREQ r0, =GPIOD_BASE
  BEQ   __set_otype
  CMP   r1, #0x45
  ITE   EQ
  LDREQ r0, =GPIOE_BASE
  BEQ   __set_otype
  CMP   r1, #0x48
  ITE   EQ
  LDREQ r0, =GPIOH_BASE
  BEQ   __set_otype
  BX    r14               @ return on failure

__set_o_type:
  LDR   r1, [r0, #0x04]   @ GPIOx_TYPER reg
  MOV   r4, #0b1          @ mask
  LSL   r4, r4, r3        @ shift to pin position
  CMP   r2, #0x50         @ push-pull 
  IT   EQ
  BICEQ r1, r1, r2        @ clear bit to make it push-pull
  CMP   r2, #0x4F         @ open-drain 
  IT    EQ
  ORREQ r1, r1, r2        @ set bit to make it open-drain
  STR   r1, [r0, #0x04]   @ GPIOx_TYPER reg
  BX    r14
  .size _set_out_type, .-_set_out_type
@-------------------------------------------------------------------
@ sets output speed of pin signal: (low-speed, medium-speed, high-speed, very-high-speed)
@ assumes r1, contains port: "A", "B", "C", "D", "E", "H"
@ assumes r2, contains speed-mode (L, M, H, V)=(low, medium, high, very-high)
@ assumes r3, contains pin number
@-------------------------------------------------------------------
_set_out_speed:
  MULS  r3, r3, #2        @ Calculate the register bit offset for the pin number
  CMP   r1, #0x41
  ITE   EQ
  LDREQ r0, =GPIOA_BASE
  BEQ   __set_ospeed
  CMP   r1, #0x42
  ITE   EQ
  LDREQ r0, =GPIOB_BASE
  BEQ   __set_ospeed
  CMP   r1, #0x43
  ITE   EQ
  LDREQ r0, =GPIOC_BASE
  BEQ   __set_ospeed
  CMP   r1, #0x44
  ITE   EQ
  LDREQ r0, =GPIOD_BASE
  BEQ   __set_ospeed
  CMP   r1, #0x45
  ITE   EQ
  LDREQ r0, =GPIOE_BASE
  BEQ   __set_ospeed
  CMP   r1, #0x48__set_olowspeed:
  ITE   EQ
  LDREQ r0, =GPIOH_BASE
  BEQ   __set_ospeed
  BX    r14               @ return on failure

__set_o_speed:
  LDR   r1, [r0, #0x0C]   @ GPIOx_PUPDR reg
  MOV   r4, #0b11
  LSL   r4, r4, r3
  BIC   r1, r1, r4
  CMP   r2, #0x4C         @ low speed
  BEQ   __set_o_low_speed
  CMP   r2, #0x4D         @ medium speed
  BEQ   __set_o_med_speed
  CMP   r2, #0x48         @ high speed
  BEQ   __set_o_high_speed
  CMP   r2, #0x56         @ very high speed
  BEQ   __set_o_vhigh_speed

__set_o_low_speed:
  STR   r1, [r0, #0x0C]   @ GPIOx_PUPDR reg     
  BX    r14               @ return 
__set_o_med_speed:
  MOV   r2, #0b01         @ set bits at medium speed (01)
  LSL   r2, r2, r3
  ORR   r1, r1, r2
  STR   r1, [r0, #0x0C]   @ GPIOx_PUPDR reg
  BX    r14               @ return
__set_o_high_speed:
  MOV   r2, #0b10         @ set bit at high speed (10)
  LSL   r2, r2, r3
  ORR   r1, r1, r2
  STR   r1, [r0, #0x0C]   @ GPIOx_PUPDR reg
  BX    r14               @ return
__set_o_vhigh_speed:
  ORR   r1, r1, r4        @ set bits at very high speed (11)
  STR   r1, [r0, #0x0C]   @ GPIOx_PUPDR reg
  BX    r14               @ return
  .size _set_out_speed, .-_set_out_speed
@-------------------------------------------------------------------
@ set pullup-pulldown
@ assumes r1, contains port to be reset: "A", "B", "C", "D", "E", "H"
@ assumes r2, contains pin state: (U, D, N)=(pull-up, pull-down, None)
@ assumes r3, contains pin number
@-------------------------------------------------------------------
_set_pull_updown:
  MULS  r3, r3, #2        @ Calculate the register bit offset for the pin number
  CMP   r1, #0x41
  ITE   EQ
  LDREQ r0, =GPIOA_BASE
  BEQ   __set_pupd
  CMP   r1, #0x42
  ITE   EQ
  LDREQ r0, =GPIOB_BASE
  BEQ   __set_pupd
  CMP   r1, #0x43
  ITE   EQ
  LDREQ r0, =GPIOC_BASE
  BEQ   __set_pupd
  CMP   r1, #0x44
  ITE   EQ
  LDREQ r0, =GPIOD_BASE
  BEQ   __set_pupd
  CMP   r1, #0x45
  ITE   EQ
  LDREQ r0, =GPIOE_BASE
  BEQ   __set_pupd
  CMP   r1, #0x48  
  ITE   EQ
  LDREQ r0, =GPIOH_BASE
  BEQ   __set_pupd
  BX    r14               @ return on failure

__set_pupd:
  LDR   r1, [r0, #0x0C]   @ GPIOx_PUPDR reg
  MOV   r2, #0b11
  LSL   r2, r2, r3
  BIC   r1, r1, r2        @ clear bits

  CMP   r2, #0x4E         @ no pull-up no pull-down
  ITT   EQ
  STREQ r1, [r0, #0x0C]   @ GPIOx_PUPDR reg
  BXEQ  r14               @ return
  
  CMP   r2, #0x55         @ pull-up
  ITTEE EQ
  MOVEQ r2, #0b01
  ORREQ r1, r1, r2        @ set bits
  STREQ r1, [r0, #0x0C]   @ GPIOx_PUPDR reg
  BXEQ  r14               @ return

  CMP   r2, #0x44         @ pull-down
  ITTEE EQ
  MOVEQ r2, #0b10
  ORREQ r1, r1, r2        @ set bits
  STREQ r1, [r0, #0x0C]   @ GPIOx_PUPDR reg
  BX    r14               @ return
  .size _set_pull_updown, .-_set_pull_updown
@-------------------------------------------------------------------
@ reads pin input data
@ assumes r1, contains port to be reset: "A", "B", "C", "D", "E", "H"
@ assumes r2, contains pin number
@-------------------------------------------------------------------
_get_pin_value:

  
  .size _get_pin_value, .-_get_pin_value

  .section .rodata.st_periphs, %progbits
  .extern RCC_BASE
  .equ GPIOA_BASE, 0x40020000
  .equ GPIOB_BASE, 0x40020400
  .equ GPIOC_BASE, 0x40020800
  .equ GPIOD_BASE, 0x40020C00
  .equ GPIOE_BASE, 0x40021000
  .equ GPIOH_BASE, 0x40021C00
