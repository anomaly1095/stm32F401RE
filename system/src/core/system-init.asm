.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb
@-------------------------------------------

  .section .text.sysinit, "ax", %progbits
  .type _sysinit, %function
  .global _sysinit
_sysinit:
  @ enable HSI 16Mhz 
  LDR   r0, =RCC_BASE
  LDR   r1, [r0]            @ PLL_CR reg
  MOV   r2, #0b1            @ HSION bit
  ORR   r1, r1, r2
  STR   r1, [r0]

  LSL   r2, r2, #1          @ HSIRDY bit
__hsi_wait:
  LDR   r1, [r0]            @ PLL_CR reg
  TST   r1, r2
  BEQ   __hsi_wait          @ wait for hsi te be enabled

__pwr_config:
  @ set VOS bits to 0x10 (power scale 2)
  @ set DBP to enable write access to RTC registers
  @ flash in power down in stop mode
  @ enable PVD

  @ PLL config (prescalers and source)
  LDR   r1, [r0, #0x04]     @ RCC_PLLGFGR reg
  MOVW  r2, #336            @ PLLN (bit 6..14) = 336
  LSL   r2, r2, #6
  ORR   r1, r1, r2
  MOVW  r2, #16             @ PLLM (bits 0..5) = 16
  ORR   r1, r1, r2
  MOVW  r2, #0b01           @ PLLP (bits 16,17) = 4
  ORR   r1, r1, r2
  MOV   r2, #0b1
  LSL   r2, r2, #22         @ clear (bit 22) to set PLLSRC to HSI
  BIC   r1, r1, r2
  STR   r1, [r0, #0x04]

  @ PLL enable
  LDR   r1, [r0]            @ RCC_CR reg
  LSL   r2, r2, #2          @ PLLON (bit 24)
  ORR   r1, r1, r2
  STR   r1, [r0]

  LSL   r2, r2, #1          @ PLLRDY (bit 25)
__pll_wait:
  LDR   r1, [r0]            @ RCC_CR reg
  TST   r1, r2
  BEQ   __pll_wait          @ wait for phase locked loop to be locked and running

  @ set pll as sysclk
  LDR   r1, [r0, #0x08]     @ RCC_CFGR reg
  MOV   r2, #0b10           @ SW (bits 0,1)
  ORR   r1, r1, r2
  STR   r1, [r0, #0x08]

  LSL   r2, r2, #2          @ SWS (bit 2,3)
__sysclk_wait:
  LDR   r1, [r0, #0x08]     @ RCC_CFGR reg
  TST   r1, r2
  BEQ   __sysclk_wait       @ wait for PLL to be selected as sysclk input by the multiplexer

  @ set AHB prescaler
  LDR   [r0, #0x08]         @ RCC_CFGR reg
  MOV   r2, #(0b1 << 7)
  BIC   r1, r1, r2          @ clear bit 7 to set AHB prescaler at 1 (no div)
  @ SET APB1 prescaler to 2
  MOVW  r2, #(0b100 << 10)  @ PPRE1 (bits 10..12)
  ORR   r1, r1, r2
  @ SET APB2 prescaler to 1 (nodiv)
  LSL   r2, r2, #3          @ PPRE2 (bits 13..15)
  BIC   r1, r1, r2
  @ save
  STR   r1, [r0, #0x08]     @ RCC_CFGR reg
  
__check_hash:
  @ CRC checksum on kernel space



__flash_config:

  LDR   r0, =FLASH_BASE
  LDR   r1, [r0]            @ FLASH_ACR reg
  LDR   r2, =FLASH_CFG_MASK    @ disable caches, reset caches, enable prefetch, set latency at 2WS
  AND   r1, r1, r2
  STR   r1, [r0]            @ FLASH_ACR reg
  LDR   r1, [r0]            @ FLASH_ACR reg
  MOVW  r2, #(0b11 << 9)    @ enable caches 
  ORR   r1, r1, r2
  STR   r1, [r0]            @ FLASH_ACR reg

  @ unlock FLASH_OPTCR for Option bytes config
  LDR   r1, =OPTKEY1
  STREX r2, r1, [r0, 0x08]      @ FLASH_OPTKEYR reg
  LDR   r2, =OPTKEY2  
  STREX r1, r2, [r0, 0x08]      @ FLASH_OPTKEYR reg

  @ unlock FLASH_CR
  LDR   r1, =KEY1 
  STREX r2, r1, [r0, 0x04]      @ FLASH_KEYR reg
  LDR   r2, =KEY2 
  STREX r1, r2, [r0, 0x04]      @ FLASH_KEYR reg
  

  @ lock FLASH_CR
  LDR   r1, [r0, #0x10]     @ FLASH_CR reg
  MOV   r2, #0b1
  ROR   r2, #1
  ORR   r1, r1, r2
  STR   r1, [r0, #0x10]     @ FLASH_CR reg
  @ lock FLASH_OPTCR
  LDR   r1, [r0, #0x14]     @ FLASH_OPTCR reg
  MOV   r2, #0b1
  ORR   r1, r1, r2
  STR   r1, [r0, #0x14]     @ FLASH_OPTCR reg

@ enable systick and it's interrupt
__systick_config:
  @ more details on calibration in docs
  LDR   r0, =SYSTICK_BASE
  MOVW  r1, #10500          @ set systick counter reload value at 10500
  STR   r1, [r0, #0x04]     @ STK_LOAD reg
  
  MOV   r1, #0b010          @ TICKINT & CLKSOURCE bits
  STR   r1, [r0]            @ STK_CTRL reg
  MOV   r2, #0b1            @ ENABLE bit 
  ORR   r1, r1, r2
  STR   r1, [r0]            @ STK_CTRL reg

__mpu_config:

  @ For each section:
  @ 1- set the VALID bit
  @ 2- load the starting address in ADDR
  @ 3- set the xn(instruction fetches), AP(access permission), TEX(), S(shareable or not), C(cacheable), B(bufferable), 
  @     SRD (to disable overlapping regions in flash and sram), SIZE (size in bytes = 2^(SIZE+1)), then ENABLE

Region 0: 0x00000000 to 0x1FFFFFFF (FLASH)

    TEX, C, B: Typically, this region is cacheable and bufferable (TEX = 000, C = 1, B = 1).
    AP: Read-only or read-write, depending on your needs.
    xn: 0 (since code execution from FLASH is required).
    S: not shareable.

Region 1: 0x80000000 to 0x8001FFFF (Kernel FLASH)

    TEX, C, B: Similar to Region 0, set as cacheable and bufferable.
    AP: Set access permissions according to kernel requirements.
    xn: Typically 0, as kernel code needs to be executable.
    S: Usually shareable.

Region 2: 0x20000000 to 0x3FFFFFFF (SRAM)

    TEX, C, B: Cacheable and bufferable (TEX = 000, C = 1, B = 1).
    AP: Read-write access.
    S: Usually shareable.
    xn: 1 for non-executable memory regions
    S: Usually shareable.


Region 3: 0x20010000 to 0x20018000 (Kernel SRAM)

    TEX, C, B: Same as Region 2.
    AP: Kernel-specific access permissions.
    xn: Typically 1, as this is data memory.
    S: Usually shareable.

Region 4: 0x40000000 to 0x5FFFFFFF (Peripherals)

    TEX, C, B: Device memory (TEX = 000, C = 0, B = 1).
    AP: Typically read-write.
    xn: 1, as peripheral registers are not executable.
    S: Usually shareable.

Region 5: 0x60000000 to 0xDFFFFFFF (Not used)

    Leave this region unconfigured or disable it.

Region 6: 0xE0000000 to 0xE00FFFFF (System Peripherals)

    TEX, C, B: Device memory (TEX = 000, C = 0, B = 1).
    AP: Read-write, according to system needs.
    xn: 1, not executable.
    S: Shareable, typically.

Region 7: 0xE0010000 to 0xFFFFFFFF (ST32 Standard Peripherals)

    TEX, C, B: Device memory (TEX = 000, C = 0, B = 1).
    AP: Read-write.
    xn: 1, not executable.
    S: Shareable.

__exception_config:


__nvic_config:
  @ enable interrupts



__fpu_config:


  @ return
  BX    lr

  .size _sysinit, .-_sysinit
@-------------------------------------------

  .section .rodata.k_regs, "a", %progbits
  .equ RCC_BASE, 0x40023800
  .equ FLASH_BASE, 0x40023C00
  .equ MPU_BASE, 0xE000ED90
  .equ NVIC_BASE, 0xE000E100
  .equ SYSTICK_BASE, 0xE000E010

  .section .rodata.masks, "a", %progbits
  .equ FLASH_CFG_MASK 0b1100100000010
@-------------------------------------------
  
  .section .rodata.keys, "a", %progbits
  @ no read no write section
  .equ OPTKEY1, 0x08192A3B  @ unlock Option byte write ops
  .equ OPTKEY2, 0x4C5D67F   @ unlock Option byte write ops
  .equ KEY1, 0x45670123     @ unlock FLASH_CR access  
  .equ KEY2, 0xCDEF89AB     @ unlock FLASH_CR access  
  k_code_checksum: .word    @ checksum to validate kernel code section
  k_data_checksum: .word    @ checksum to validate kernel data section
