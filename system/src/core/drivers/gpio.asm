

  .section .text.drivers, "ax", %progbits

@-------------------------------------------------------------------
@ resets gpio port
@ assumes r1 contains port to be reset: "A", "B", "C", "D", "E", "H"
@-------------------------------------------------------------------
.global _gpio_port_reset
_gpio_port_reset:
  LDR   r0, =RCC_BASE
  LDR   r2, [r0, #0x10]   @ RCC_AHB1RST reg

  CMP   r1, #0x41         @ "A"
  MOV   r3, #0b1
  BEQ   __reset_port
  CMP   r1, #0x42         @ "B"
  MOV   r3, #(0b1 << 1)
  BEQ   __reset_port
  CMP   r1, #0x43         @ "C"
  MOV   r3, #(0b1 << 2)
  BEQ   __reset_port
  CMP   r1, #0x44         @ "D"
  MOV   r3, #(0b1 << 3)
  BEQ   __reset_port
  CMP   r1, #0x45         @ "E"
  MOV   r3, #(0b1 << 4)
  BEQ   __reset_port
  CMP   r1, #0x48         @ "H"
  MOV   r3, #(0b1 << 7)
  BEQ   __reset_port

  BX    r14               @ return on failure

__reset_port:
  ORR   r2, r2, r3        @ Set the reset bit for the selected port
  STR   r2, [r0, #0x10]   @ Write back to RCC_AHB1RST reg
  BX    r14               @ return
.size _gpio_port_reset, .-_gpio_port_reset

@-------------------------------------------------------------------
@ enables gpio port's clock
@ assumes r1 contains port to be enabled: "A", "B", "C", "D", "E", "H"
@-------------------------------------------------------------------
.global _gpio_port_enable
_gpio_port_enable:
  LDR   r0, =RCC_BASE
  LDR   r2, [r0, #0x30]   @ RCC_AHB1ENR reg

  CMP   r1, #0x41         @ "A"
  MOV   r3, #0b1
  BEQ   __enable_common
  CMP   r1, #0x42         @ "B"
  MOV   r3, #(0b1 << 1)
  BEQ   __enable_common
  CMP   r1, #0x43         @ "C"
  MOV   r3, #(0b1 << 2)
  BEQ   __enable_common
  CMP   r1, #0x44         @ "D"
  MOV   r3, #(0b1 << 3)
  BEQ   __enable_common
  CMP   r1, #0x45         @ "E"
  MOV   r3, #(0b1 << 4)
  BEQ   __enable_common
  CMP   r1, #0x48         @ "H"
  MOV   r3, #(0b1 << 7)
  BEQ   __enable_common

  BX    r14               @ return on failure

__enable_common:
  ORR   r2, r2, r3        @ Set the enable bit for the selected port
  STR   r2, [r0, #0x30]   @ Write back to RCC_AHB1ENR reg
  BX    r14               @ return
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
  CMP   r1, #0x41         @ "A"
  ITT   EQ
  LDR   r0, =GPIOA_BASE
  BEQ   __check_pinmode
  CMP   r1, #0x42         @ "B"
  ITT   EQ
  LDR   r0, =GPIOB_BASE
  BEQ   __check_pinmode
  CMP   r1, #0x43         @ "C"
  ITT   EQ
  LDR   r0, =GPIOC_BASE
  B     __check_pinmode
  CMP   r1, #0x44         @ "D"
  ITT   EQ
  LDR   r0, =GPIOD_BASE
  B     __check_pinmode
  CMP   r1, #0x45         @ "E"
  ITT   EQ
  LDR   r0, =GPIOE_BASE
  B     __check_pinmode
  CMP   r1, #0x48         @ "H"
  ITT   EQ
  LDR   r0, =GPIOH_BASE
  B     __check_pinmode
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
  CMP   r1, #0x41         @ "A"
  ITT   EQ
  LDR   r0, =GPIOA_BASE
  B     __set_otype
  CMP   r1, #0x42         @ "B"
  ITT   EQ
  LDR   r0, =GPIOB_BASE
  B     __set_otype
  CMP   r1, #0x43         @ "C"
  ITT   EQ
  LDR   r0, =GPIOC_BASE
  BEQ   __set_otype
  CMP   r1, #0x44         @ "D"
  ITT   EQ
  LDR   r0, =GPIOD_BASE
  B     __set_otype
  CMP   r1, #0x45         @ "E"
  ITT   EQ
  LDR   r0, =GPIOE_BASE
  B     __set_otype
  CMP   r1, #0x48         @ "H"
  ITT   EQ
  LDR   r0, =GPIOH_BASE
  B     __set_otype
  BX    r14               @ return on failure

__set_o_type:
  LDR   r1, [r0, #0x04]   @ GPIOx_TYPER reg
  MOV   r4, #0b1          @ mask
  LSL   r4, r4, r3        @ shift to pin position
  CMP   r2, #0x50         @ push-pull 
  IT    EQ
  BIC   r1, r1, r2        @ clear bit to make it push-pull
  CMP   r2, #0x4F         @ open-drain 
  IT    EQ
  ORR   r1, r1, r2        @ set bit to make it open-drain
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
  CMP   r1, #0x41         @ "A"
  ITT   EQ
  LDR   r0, =GPIOA_BASE
  B     __set_ospeed
  CMP   r1, #0x42         @ "B"
  ITT   EQ
  LDR   r0, =GPIOB_BASE
  B     __set_ospeed
  CMP   r1, #0x43         @ "C"
  ITT   EQ
  LDR   r0, =GPIOC_BASE
  B     __set_ospeed
  CMP   r1, #0x44         @ "D"
  ITT   EQ
  LDR   r0, =GPIOD_BASE
  B     __set_ospeed
  CMP   r1, #0x45         @ "E"
  ITT   EQ
  LDR   r0, =GPIOE_BASE
  B     __set_ospeed
  CMP   r1, #0x48         @ "H"
  ITT   EQ
  LDR   r0, =GPIOH_BASE
  B     __set_ospeed
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
  CMP   r1, #0x41         @ "A"
  ITT   EQ
  LDR   r0, =GPIOA_BASE
  B     __set_pupd
  CMP   r1, #0x42         @ "B"
  ITT   EQ
  LDR   r0, =GPIOB_BASE
  B     __set_pupd
  CMP   r1, #0x43         @ "C"
  ITT   EQ
  LDR   r0, =GPIOC_BASE
  B     __set_pupd
  CMP   r1, #0x44         @ "D"
  ITT   EQ
  LDR   r0, =GPIOD_BASE
  B     __set_pupd
  CMP   r1, #0x45         @ "E"
  ITT   EQ
  LDR   r0, =GPIOE_BASE
  B     __set_pupd
  CMP   r1, #0x48         @ "H"
  ITT   EQ
  LDR   r0, =GPIOH_BASE
  B     __set_pupd
  BX    r14               @ return on failure

__set_pupd:
  LDR   r1, [r0, #0x0C]   @ GPIOx_PUPDR reg
  MOV   r2, #0b11
  LSL   r2, r2, r3
  BIC   r1, r1, r2        @ clear bits

  CMP   r2, #0x4E         @ no pull-up no pull-down
  ITT   EQ
  STR   r1, [r0, #0x0C]   @ GPIOx_PUPDR reg
  BX    r14               @ return
  
  CMP   r2, #0x55         @ pull-up
  ITT   EQ
  MOV   r2, #0b01
  ORR   r1, r1, r2        @ set bits
  ITT   EQ
  STR   r1, [r0, #0x0C]   @ GPIOx_PUPDR reg
  BX    r14               @ return

  CMP   r2, #0x44         @ pull-down
  ITT   EQ
  MOV   r2, #0b10
  ORR   r1, r1, r2        @ set bits
  IT    EQ
  STR   r1, [r0, #0x0C]   @ GPIOx_PUPDR reg
  BX    r14               @ return
  .size _set_pull_updown, .-_set_pull_updown

@-------------------------------------------------------------------
@ reads pin input data
@ assumes r1, contains port to be reset: "A", "B", "C", "D", "E", "H"
@ assumes r2, contains pin number
@ function will write the value of data (0 or 1) in r3
@-------------------------------------------------------------------
_get_input_data:
  CMP   r1, #0x41         @ "A"
  ITT   EQ
  LDR   r0, =GPIOA_BASE
  B     __get_input_d
  CMP   r1, #0x42         @ "B"
  ITT   EQ
  LDR   r0, =GPIOB_BASE
  B     __get_input_d
  CMP   r1, #0x43         @ "C"
  ITT   EQ
  LDR   r0, =GPIOC_BASE
  B     __get_input_d
  CMP   r1, #0x44         @ "D"
  ITT   EQ
  LDR   r0, =GPIOD_BASE
  B     __get_input_d
  CMP   r1, #0x45         @ "E"
  ITT   EQ
  LDR   r0, =GPIOE_BASE
  B     __get_input_d
  CMP   r1, #0x48         @ "H"
  ITT   EQ
  LDR   r0, =GPIOH_BASE
  B     __get_input_d
  BX    r14               @ return on failure

__get_input_d:
  LDR   r1, [r0, #0x14]
  MOV   r3, #0b1
  LSL   r3, r3, r2        @ set mask at bit position
  TST   r1, r3
  ITE   EQ
  MOV   r3, #0            @ input = 0
  MOV   r3, #1            @ input = 1
  BX    r14
  .size _get_pin_value, .-_get_pin_value

@-------------------------------------------------------------------
@ writes output data to pin
@ assumes r1, contains port to be reset: "A", "B", "C", "D", "E", "H"
@ assumes r2, contains pin number
@ assumes r3 will contain the value of data to be written (0 or 1)
@-------------------------------------------------------------------
_set_output_data:
  CMP   r1, #0x41         @ "A"
  ITT   EQ
  LDR   r0, =GPIOA_BASE
  B     __set_output_d
  CMP   r1, #0x42         @ "B"
  ITT   EQ
  LDR   r0, =GPIOB_BASE
  B     __set_output_d
  CMP   r1, #0x43         @ "C"
  ITT   EQ
  LDR   r0, =GPIOC_BASE
  B     __set_output_d
  CMP   r1, #0x44         @ "D"
  ITT   EQ  
  LDR   r0, =GPIOD_BASE
  B     __set_output_d
  CMP   r1, #0x45         @ "E"
  ITT   EQ
  LDR   r0, =GPIOE_BASE
  B     __set_output_d
  CMP   r1, #0x48         @ "H"
  ITT   EQ
  LDR   r0, =GPIOH_BASE
  B     __set_output_d
  BX    r14               @ return on failure
__set_output_d:
  LDR   r1, [r0, #0x18]   @ GPIOx_BSSR reg 
  CMP   r3, #0b1
  ITEE  EQ
  LSL   r3, r3, r2
  MULS  r2, r2, #2
  LSL   r3, r3, r2
  STR   r3, [r0, #0x18]   @ GPIOx_BSSR reg
  .size _set_pin_value, .-_set_pin_value

@-------------------------------------------------------------------
@ select alternate function for pin
@ assumes r1, contains port to be reset: "A", "B", "C", "D", "E", "H"
@ assumes r2, contains pin number
@ assumes r3 contains the alternate function number (0..15)
@-------------------------------------------------------------------
_select_af:
  CMP   r1, #0x41         @ "A"
  ITT   EQ
  LDR   r0, =GPIOA_BASE
  B     __sel_af
  CMP   r1, #0x42         @ "B"
  ITT   EQ
  LDR   r0, =GPIOB_BASE
  B     __sel_af
  CMP   r1, #0x43         @ "C"
  ITT   EQ
  LDR   r0, =GPIOC_BASE
  B     __sel_af
  CMP   r1, #0x44         @ "D"
  ITT   EQ
  LDR   r0, =GPIOD_BASE
  B     __sel_af
  CMP   r1, #0x45         @ "E"
  ITT   EQ
  LDR   r0, =GPIOE_BASE
  B     __sel_af
  CMP   r1, #0x48         @ "H"
  ITT   EQ
  LDR   r0, =GPIOH_BASE
  B     __sel_af
  BX    r14               @ return on failure

__sel_af:
  MOVW  r4, #1111          @ Initialize mask for setting bits
  CMP   r2, #8             @ Check if pin number is >= 8
  BGE   __sel_af_high      @ Branch to high register handling if true

  @ Low register for AFRL (0 --> 7)
  LDR   r1, [r0, #0x20]    @ Load GPIOx_AFRL
  MUL   r2, r2, #4         @ Calculate bit offset
  LSL   r3, r3, r2         @ Shift alternate function number to position
  LSL   r4, r4, r2         @ Create mask for clearing bits
  BIC   r1, r1, r4         @ Clear existing bits
  ORR   r1, r1, r3         @ Set new alternate function bits
  STR   r1, [r0, #0x20]    @ Store updated GPIOx_AFRL
  BX    r14                @ Return

__sel_af_high:
  @ High register for AFRH (8 --> 15)
  LDR   r1, [r0, #0x24]    @ Load GPIOx_AFRH
  SUB   r2, r2, #8         @ Normalize pin number to start at 0 (not 8)
  MUL   r2, r2, #4         @ Calculate bit offset
  LSL   r3, r3, r2         @ Shift alternate function number to position
  LSL   r4, r4, r2         @ Create mask for clearing bits
  BIC   r1, r1, r4         @ Clear existing bits
  ORR   r1, r1, r3         @ Set new alternate function bits
  STR   r1, [r0, #0x24]    @ Store updated GPIOx_AFRH
  BX    r14                @ Return

  .size _select_af, .-_select_af

  .section .rodata.st_periphs, %progbits
  .extern RCC_BASE
  .equ GPIOA_BASE, 0x40020000
  .equ GPIOB_BASE, 0x40020400
  .equ GPIOC_BASE, 0x40020800
  .equ GPIOD_BASE, 0x40020C00
  .equ GPIOE_BASE, 0x40021000
  .equ GPIOH_BASE, 0x40021C00
