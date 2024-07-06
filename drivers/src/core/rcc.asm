  
  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb
  #include "../helper.asm"


  .section .text.drivers.rcc_driver, "ax", %progbits
@---------------------------------------------------
@ enable PLLI²S (phase locked loop for inter integrated sound system)
  .global _pll_i2s_enable
  .type _pll_i2s_enable, %function
_pll_i2s_enable:
  PUSH_R0_R2
  LDR     r0, =RCC_BASE_BB    @ load rcc base bit-band address in r0
  MOV     r1, #1              @ 1 to enable
  MOVW    r2, #0x68           @ PLLI2SON bit-band offset (bit26*4bytes)
  STR     r1, [r0, r2]!
  ADD     r0, r1, #0x04       @ PLLI2SRDY bit-band offset 
__pll_i2s_wait:
  LDR     r1, [r0]
  CBZ     r1, __pll_i2s_wait  @ if pll ready flag is disabled we branch
  POP_R0_R2
  bx      r14
  .size _pll_i2s_enable, .-_pll_i2s_enable
@---------------------------------------------------
@ enable PLL (phase locked loop)
  .global _pll_enable
  .type _pll_enable, %function
_pll_enable:
  PUSH_R0_R2
  LDR     r0, =RCC_BASE_BB    @ load rcc base bit-band address in r0
  MOV     r1, #1              @ 1 to enable
  MOVW    r2, #0x60           @ PLLON bit-band offset (bit24*4bytes)
  STR     r1, [r0, r2]!
  ADD     r0, r1, #0x04       @ PLLRDY bit-band offset 
__pll_wait:
  LDR     r1, [r0]
  CBZ     r1, __pll_wait  @ if pll ready flag is disabled we branch
  POP_R0_R2
  bx      r14
  .size _pll_enable, .-_pll_enable
@-----------------------------------------------------------------
@ enable CSS (clock security system)
  .global _css_enable
  .type _css_enable, %function
_css_enable:
  PUSH_R0_R2
  LDR     r0, =RCC_BASE_BB    @ load rcc base bit-band address in r0
  MOV     r1, #1              @ 1 to enable
  MOVW    r2, #0x4C           @ CSS bit-band offset (bit19*4bytes)
  STR     r1, [r0, r2]
  POP_R0_R2
  bx      r14
  .size _css_enable, .-_css_enable
@---------------------------------------------------
@ enable HSE (high speed external osillator) (not provided on nucleo boards)
  .global _hse_enable
  .type _hse_enable, %function
_hse_enable:
  PUSH_R0_R2
  LDR     r0, =RCC_BASE_BB    @ load rcc base bit-band address in r0
  MOV     r1, #1              @ 1 to enable
  MOVW    r2, #0x40           @ HSEON bit-band offset (bit16*4bytes)
  STR     r1, [r0, r2]!
  ADD     r0, r1, #0x04       @ HSERDY bit-band offset 
__hse_wait:
  LDR     r1, [r0]
  CBZ     r1, __hse_wait      @ if hse ready flag is disabled we branch else exit
  POP_R0_R2
  bx      r14
  .size _hse_enable, .-_hse_enable

@---------------------------------------------------
@ bypass HSE with an external crystal/ceramic oscillator
  .global _hse_ext_bypass
  .type _hse_ext_bypass, %function
_hse_ext_bypass:
  PUSH_R0_R2
  LDR     r0, =RCC_BASE_BB    @ load rcc base bit-band address in r0
  MOV     r1, #1              @ 1 to enable
  MOVW    r2, #0x48           @ PLLBYP bit-band offset (bit18*4bytes)
  STR     r1, [r0, r2]
  POP_R0_R2
  bx      r14
  .size _hse_ext_bypass, .-_hse_ext_bypass
@---------------------------------------------------
@ enable HSI (high speed internal RC)
  .global _hsi_enable
  .type _hsi_enable, %function
_hsi_enable:
  PUSH_R0_R1
  LDR     r0, =RCC_BASE_BB    @ load rcc base bit-band address in r0
  MOV     r1, #1              @ 1 to enable
  STR     r1, [r0], #0x04     @ enable and transition the ready bit
__hsi_wait:
  LDR     r1, [r0]
  CBZ     r1, __hsi_wait      @ if hsi ready flag is disabled we branch else exit
  POP_R0_R1
  bx      r14
  .size _hsi_enable, .-_hsi_enable
@---------------------------------------------------
@ pll_config
@ expects r0 to have the desired clock frequency: (0:84, 1:72, 2:64, 3:56, 4:42)
_pll_config:
  PUSH_R0_R3
  LDR     r3, =RCC_BASE
  LDR     r1, [r3, #0x04]!    @ load value of RCC_PLLCFGR 
  
  LDR     r2, =PLLCFGR_MASK   @ clears prescaler values before setting new ones
  BIC     r1, r1, r2
  MOV     r2, #0              @ clear r2

  MOVW    r2, #16             @ set PLLM prescaler at 16 (reduces pll jitter)  
  MOVT    r2, #(0b1 << 6)     @ set clock source HSI
  ORR     r1, r1, r2          @ set the bits in r1

  CBZ     r0, __pll_config_84mhz
  
  CMP     r0, #1
  BEQ     __pll_config_72mhz

  CMP     r0, #2
  BEQ     __pll_config_64mhz

  CMP     r0, #3
  BEQ     __pll_config_56mhz

  CMP     r0, #4
  BEQ     __pll_config_42mhz
  
  B       __pll_config_exit

__pll_config_84mhz:
  MOVW    r2, #(336 << 6)     @ set PLLN prescaler at 336
  MOVT    r2, #0b01           @ set PLLP prescaler at 4
  B       __pll_config_exit   @ exit
__pll_config_72mhz:
  MOVW    r2, #(432 << 6)     @ set PLLN prescaler at 336
  MOVT    r2, #0b10           @ set PLLP prescaler at 6
  B       __pll_config_exit   @ exit
__pll_config_64mhz:
  MOVW    r2, #(256 << 6)     @ set PLLN prescaler at 336
  MOVT    r2, #0b01           @ set PLLP prescaler at 4
  B       __pll_config_exit   @ exit
__pll_config_56mhz:
  MOVW    r2, #(336 << 6)     @ set PLLN prescaler at 336
  MOVT    r2, #0b10           @ set PLLP prescaler at 6
  B       __pll_config_exit   @ exit
__pll_config_42mhz:
  MOVW    r2, #(336 << 6)     @ set PLLN prescaler at 336
  MOVT    r2, #0b11           @ set PLLP prescaler at 8
__pll_config_exit:
  ORR     r1, r1, r2          @ set masks
  STR     r1, [r3]            @ save
  POP_R0_R3                   @ pop use stack
  BX      r14                 @ exit
  .size _pll_config, .-_pll_config
@---------------------------------------------------
@ 
_rcc_mco2:
_rcc_mco2:




@-----------------------------------------------------------------
  .section .rodata.drivers.rcc_driver, "a", %progbits
  .equ RCC_BASE, 0x40023800
  .equ RCC_BASE_BB, 0x42470000
  .equ PLLCFGR_MASK, 0xDFFF

