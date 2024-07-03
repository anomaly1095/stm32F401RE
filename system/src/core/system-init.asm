.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb
@----------------------------------------------
  .section .text.sysinit, "ax", %progbits
  .type _sysinit, %function
  .global _sysinit
@-------------------------------------------

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
  MOVW  r2, 0b1100100000010  @ disable caches, reset caches, enable prefetch, set latency at 2WS
  AND   r1, r1, r2
  STR   r1, [r0]            @ FLASH_ACR reg
  LDR   r1, [r0]            @ FLASH_ACR reg
  MOVW  r2, #(0b11 << 9)    @ enable caches 
  ORR   r1, r1, r2
  STR   r1, [r0]            @ FLASH_ACR reg

  @ unlock FLASH_OPTCR
  LDR   r1, =OPTKEY1
  STREX r2, r1, [r0, 0x08]  @ FLASH_OPTKEYR reg
  LDR   r2, =OPTKEY2  
  STREX r1, r2, [r0, 0x08]  @ FLASH_OPTKEYR reg
  @ unlock FLASH_CR
  LDR   r1, =KEY1 
  STREX r2, r1, [r0, 0x04]  @ FLASH_KEYR reg
  LDR   r2, =KEY2 
  STREX r1, r2, [r0, 0x04]  @ FLASH_KEYR reg
  
  LDR   r1, [r0, #0x14]     @ FLASH_OPTCR reg
  @----!!!!!!!!ENABLE ONLY AFTER PRODUCTION!!!!!!!!!----
  @ MOVT  r2, #0b11111
  @ ORR   r1, r1, r2        @ enable write protection
  @ MOV   r2, #0b1
  @ ROR   r2, r2, #1
  @ BIC   r1, r1, r2        @ use write protection instead of PCROP protection (BIC instead of ORR)
  MOVW  r2, #(0b01 << 2)    @ Set the BOR (brown out reset) level
  ORR   r1, r1, r2 
  MOVW  r2, #(0xAA << 8)    @ set Read protection level to 0
  ORR   r1, r1, r2 
  STR   r1, [r0, #0x14]     @ FLASH_OPTCR reg 

  LDR   r1, [r0, #0x10]     @ FLASH_CR reg
  MOVT  r2, #(01b0000011 << 8) @ enable FLASH interrupts and lock the register
  ORR   r1, r1, r2
  STR   r1, [r0, #0x10]     @ FLASH_CR reg

  @ lock FLASH_OPTCR
  LDR   r1, [r0, #0x14]     @ FLASH_OPTCR reg
  MOV   r2, #0b1
  ORR   r1, r1, r2
  STR   r1, [r0, #0x14]     @ FLASH_OPTCR reg
  @ lock FLASH_CR
  LDR   r1, [r0, #0x10]     @ FLASH_CR reg
  ROR   r2, #1
  ORR   r1, r1, r2
  STR   r1, [r0, #0x10]     @ FLASH_CR reg

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
  LDR   r0, =MPU_BASE         @ Load MPU base address
  LDR   r1, [r0]              @ Load MPU_TYPER register to check MPU type

  @ Check for DREGION bits to see if MPU supports regions
  MOVW  r2, #(0x8 << 8)       @ Prepare mask for DREGION bits
  TST   r1, r2                
  BEQ   __exception_config    @ Branch out if no MPU support
  MOV   r2, #0b1              @ SEPARATE flag bit
  TST   r1, r2
  MOV   r2, #0b111
  ITTEE EQ                    @ Check if separate sections are not supported or only unified
  LDREQ r1, [r0, #0x04]       @ MPU_CTRL reg
  ORREQ r1, r2                @ Set ENABLE, PRIVDEFENA, and HFNMIENA bits
  STREQ r1, [r0, #0x04]       @ MPU_CTRL reg
  BEQ   __exception_config    @ branch without configuring sections


  @ Configure REGION0: 0x00000000 to 0x1FFFFFFF (FLASH for kernel and apps)
  LDR   r1, =SECTION0_BASE
  MOVW  r2, #0b10000            @ Region number 0, VALID bit
  ORR   r1, r1, r2
  STR   r2, [r0, #0x0C]         @ MPU_RBAR reg

  LDR   r2, =SECTION0_MASK
  STR   r2, [r0, #0x10]         @ MPU_RASR reg

  @ Configure REGION1: 0x20000000 to 0x3FFFFFFF (SRAM)
  LDR   r1, =SECTION1_BASE
  MOVW  r2, #0b10001            @ Region number 1, VALID bit
  ORR   r1, r1, r2
  STR   r2, [r0, #0x0C]         @ MPU_RBAR reg

  LDR   r2, =SECTION1_MASK
  STR   r2, [r0, #0x10]         @ MPU_RASR reg

  @ Configure REGION2: 0x20010000 to 0x20017FFF (Kernel SRAM)
  LDR   r1, =SECTION2_BASE
  MOVW  r2, #0b10010            @ Region number 2, VALID bit
  ORR   r1, r1, r2
  STR   r2, [r0, #0x0C]         @ MPU_RBAR reg

  LDR   r2, =SECTION2_MASK
  STR   r2, [r0, #0x10]         @ MPU_RASR reg

  @ Configure REGION3: 0x22200000 to 0x222FFFFF (Bit-Band Area of Kernel SRAM)
  LDR   r1, =SECTION3_BASE
  MOVW  r2, #0b10011            @ Region number 3, VALID bit
  ORR   r1, r1, r2
  STR   r2, [r0, #0x0C]         @ MPU_RBAR reg

  LDR   r2, =SECTION3_MASK
  STR   r2, [r0, #0x10]         @ MPU_RASR reg

  @ Configure REGION4: 0x40000000 to 0x5FFFFFFF (Peripheral Registers)
  LDR   r1, =SECTION4_BASE
  MOVW  r2, #0b10100            @ Region number 4, VALID bit
  ORR   r1, r1, r2
  STR   r2, [r0, #0x0C]         @ MPU_RBAR reg

  LDR   r2, =SECTION4_MASK
  STR   r2, [r0, #0x10]         @ MPU_RASR reg

  @ Configure REGION5: 0x40026000 to 0x40026FFF (DMA Controller)
  LDR   r1, =SECTION5_BASE
  MOVW  r2, #0b10101            @ Region number 5, VALID bit
  ORR   r1, r1, r2
  STR   r2, [r0, #0x0C]         @ MPU_RBAR reg

  LDR   r2, =SECTION5_MASK
  STR   r2, [r0, #0x10]         @ MPU_RASR reg

  @ Configure REGION6: 0x424C0000 to 0x424DFFFF (Bit-Band Area of DMA Controller)
  LDR   r1, =SECTION6_BASE
  MOVW  r2, #0b10110            @ Region number 6, VALID bit
  ORR   r1, r1, r2
  STR   r2, [r0, #0x0C]         @ MPU_RBAR reg

  LDR   r2, =SECTION6_MASK
  STR   r2, [r0, #0x10]         @ MPU_RASR reg

  @ Configure REGION7: 0xE0000000 to 0xE00FFFFF (System Peripheral Space)
  LDR   r1, =SECTION7_BASE
  MOVW  r2, #0b10111            @ Region number 7, VALID bit
  ORR   r1, r1, r2
  STR   r2, [r0, #0x0C]         @ MPU_RBAR reg

  LDR   r2, =SECTION7_MASK
  STR   r2, [r0, #0x10]         @ MPU_RASR reg

  @ Enable background map, enable mpu during NMI AND FAULTS, enable MPU
  LDR   r1, [r0, #0x04]       @ MPU_CTRL reg
  MOV   r2, #0b111
  ORR   r1, r2                @ Set ENABLE, PRIVDEFENA, and HFNMIENA bits
  STR   r1, [r0, #0x04]       @ MPU_CTRL reg

__exception_config:
  
__nvic_config:

__fpu_config:

  @ return
  BX    r14

  .size _sysinit, .-_sysinit
@-------------------------------------------------------------------------------------------------------
@---------------------------------------------- registers for stm peripherals 
  .section .rodata.st_regs, "a", %progbits
  .global RCC_BASE
  .global SYSCFG_BASE
  .equ RCC_BASE, 0x40023800
  .equ FLASH_BASE, 0x40023C00
  .equ SYSCFG_BASE, 0x40013800

@-------------------------------------------------------------------------------------------------------

@---------------------------------------------- registers for core system periphs 
  .section .rodata.sys_regs, "a", %progbits
  .equ MPU_BASE, 0xE000ED90
  .equ NVIC_BASE, 0xE000E100
  .equ SYSTICK_BASE, 0xE000E010

@-------------------------------------------------------------------------------------------------------

  .section .rodata.sections, "a", %progbits

  @----------------------------- System Peripheral Space
  .equ SECTION7_SIZE, 0x00100000    @ 1MB
  .equ SECTION7_BASE, 0xE0000000
  @                     XN = 1    |   AP =  001   |  TEX =  000   |   S =  1    |   C = 0     |   B = 0     |SRD=00000000| SIZE = 19 | ENABLE 
  .equ SECTION7_MASK, (0b1 << 28) | (0b001 << 24) | (0b000 << 19) | (0b1 << 18) | (0b0 << 17) | (0b0 << 16) | (0x0 << 8) | (19 << 1) | 0b1
  
  @----------------------------- Bit-Band Area of DMA Controller
  .equ SECTION6_SIZE, 0x00020000    @ 128KB
  .equ SECTION6_BASE, 0x424C0000
  @                     XN = 1    |   AP =  010   |  TEX =  000   |   S =  1    |   C = 0     |   B = 1     |SRD=00000000| SIZE = 16 | ENABLE 
  .equ SECTION6_MASK, (0b1 << 28) | (0b010 << 24) | (0b000 << 19) | (0b1 << 18) | (0b0 << 17) | (0b1 << 16) | (0x0 << 8) | (16 << 1) | 0b1
  
  @----------------------------- DMA Controller
  .equ SECTION5_SIZE, 0x00001000    @ 4KB
  .equ SECTION5_BASE, 0x40026000
  @                     XN = 1    |   AP =  010   |  TEX =  000   |   S =  1    |   C = 0     |   B = 1     |SRD=00000000| SIZE = 11 | ENABLE 
  .equ SECTION5_MASK, (0b1 << 28) | (0b010 << 24) | (0b000 << 19) | (0b1 << 18) | (0b0 << 17) | (0b1 << 16) | (0x0 << 8) | (11 << 1) | 0b1

  @----------------------------- Peripheral Registers
  .equ SECTION4_SIZE, 0x20000000    @ 512MB
  .equ SECTION4_BASE, 0x40000000
  @                     XN = 1    |   AP =  011   |  TEX =  000   |   S =  1    |   C = 0     |   B = 1     |SRD=00000000| SIZE = 28 | ENABLE 
  .equ SECTION4_MASK, (0b1 << 28) | (0b011 << 24) | (0b000 << 19) | (0b1 << 18) | (0b0 << 17) | (0b1 << 16) | (0x0 << 8) | (28 << 1) | 0b1

  @----------------------------- Bit-Band Area of KERNEL SRAM
  .equ SECTION3_SIZE, 0x00100000    @ 1MB
  .equ SECTION3_BASE, 0x22200000
  @                     XN = 1    |   AP =  001   |  TEX =  001   |   S =  0    |   C = 0     |   B = 0     |SRD=00000000| SIZE = 19 | ENABLE 
  .equ SECTION3_MASK, (0b1 << 28) | (0b001 << 24) | (0b001 << 19) | (0b0 << 18) | (0b0 << 17) | (0b0 << 16) | (0x0 << 8) | (19 << 1) | 0b1

  @----------------------------- KERNEL SRAM
  .equ SECTION2_SIZE, 0x00008000    @ 32KB
  .equ SECTION2_BASE, 0x20010000
  @                     XN = 0    |   AP =  001   |  TEX =  001   |   S =  0    |   C = 1     |   B = 1     |SRD=00000000| SIZE = 14 | ENABLE 
  .equ SECTION2_MASK, (0b0 << 28) | (0b001 << 24) | (0b001 << 19) | (0b0 << 18) | (0b1 << 17) | (0b1 << 16) | (0x0 << 8) | (14 << 1) | 0b1

  @----------------------------- SRAM
  .equ SECTION1_SIZE, 0x20000000    @ 512MB
  .equ SECTION1_BASE, 0x20000000
  @                     XN = 1    |   AP =  011   |  TEX =  000   |   S =  1    |   C = 1     |   B = 0     |SRD=00000000| SIZE = 28 | ENABLE 
  .equ SECTION1_MASK, (0b1 << 28) | (0b011 << 24) | (0b000 << 19) | (0b1 << 18) | (0b1 << 17) | (0b0 << 16) | (0x0 << 8) | (28 << 1) | 0b1

  @----------------------------- FLASH for kernel and apps
  .equ SECTION0_SIZE, 0x20000000    @ 512MB
  .equ SECTION0_BASE, 0x00000000
  @                     XN = 0    |   AP =  010   |  TEX =  000   |   S =  1    |   C = 1     |   B = 0     |SRD=00000000| SIZE = 28 | ENABLE 
  .equ SECTION0_MASK, (0b0 << 28) | (0b010 << 24) | (0b000 << 19) | (0b1 << 18) | (0b1 << 17) | (0b0 << 16) | (0x0 << 8) | (28 << 1) | 0b1

@-------------------------------------------------------------------------------------------------------

@----------------------------------------------
  .section .rodata.keys, "a", %progbits
@----------------------------------------------

  @ no read no write section
  .equ OPTKEY1, 0x08192A3B    @ unlock Option byte write ops
  .equ OPTKEY2, 0x4C5D67F     @ unlock Option byte write ops
  .equ KEY1, 0x45670123       @ unlock FLASH_CR access to program/erase FLASH memory  
  .equ KEY2, 0xCDEF89AB       @ unlock FLASH_CR access to program/erase FLASH memory  
  k_code_checksum: .word      @ checksum to validate kernel code section
  k_data_checksum: .word      @ checksum to validate kernel data section
