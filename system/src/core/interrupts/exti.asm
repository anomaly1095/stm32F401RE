
.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

@-------------------------------------------------------------------
  .section text.st_interrupt_config, "ax", %progbits
@-------------------------------------------------------------------

@-------------------------------------------------------------------
@ mask or remove mask for event or interrupt on the EXTIx 
@ assumes r1, contains EXTI number to be set (0..18, 21, 22)
@ assumes r2, contains event or interrupt mask (I, E)=(Interrupt, Event)
@ assumes r3, contains state (1, 0)=(Unmask, Mask)
@-------------------------------------------------------------------
  .global _mask_unmask_exti
  .type _mask_unmask_exti, %function
_mask_unmask_exti:
  LDR     r0, =EXTI_BASE
  CMP     r1, #19
  IT      EQ
  BXEQ    r14
  CMP     r1, #20
  IT      EQ
  BXEQ    r14
  CMP     r2, #0x45       @ "E"
  ITE     EQ
  MOVEQ   r4, #0x04       @ register offset (EXTI_EMR)
  MOVNE   r4, #0x00       @ register offset (EXTI_IMR)
  CBZ     r3, __mask_exti

__unmask_exti:
  MOV     r3, #0b1
  LSL     r3, r3, r1
  LDR     r2, [r0, r4]    
  ORR     r2, r2, r3      @ set the bit
  STR     r2, [r0, r4]
  BX      r14

__mask_exti:
  MOV     r3, #0b1
  LSL     r3, r3, r1
  LDR     r2, [r0, r4]
  BIC     r2, r2, r3      @ clear the bit
  STR     r2, [r0, r4]
  BX      r14

  .size _mask_unmask_exti, .-_mask_unmask_exti

@-------------------------------------------------------------------
@ select rising or falling edge or both pulse detection on the EXTIx line 
@ assumes r1, contains EXTI number to be set (0..18, 21, 22)
@ assumes r2, contains event or interrupt mask (R, F, B)=(rising, falling, both)
@ assumes r3, contains state (1, 0)=(enable, disable)
@-------------------------------------------------------------------
  .global _edge_select_exti
  .type _edge_select_exti, %function
_edge_select_exti:
  LDR     r0, =EXTI_BASE
  
  CMP     r1, #19         @ invalid EXTI -> exit
  IT      EQ
  BXEQ    r14
  CMP     r1, #20         @ invalid EXTI -> exit
  IT      EQ
  BXEQ    r14
  
  CMP     r2, #0x52       @ "R"
  ITT     EQ
  MOVEQ   r4, #0x08       @ register offset (EXTI_RTSR)
  BEQ     __rising_edge_select_exti
  
  CMP     r2, #0x46       @ "F"
  ITT     EQ
  MOVEQ   r4, #0x0C       @ register offset (EXTI_FTSR)
  BEQ     __edge_select_exti

  CMP     r2, #0x42       @ "B"
  IT      EQ
  BEQ     __both_edge_select_exti

  BX      r14             @ exit on error

__edge_select_exti:
  LDR     r4, [r0, r4]!   @ EXTI_?TSR  
  CMP     r3, #0
  MOV     r3, #0b1
  LSL     r3, r3, r1
  ITE     EQ
  BICEQ   r4, r4, r3      @ disable  
  ORRNE   r4, r4, r3      @ enable 
  STR     r4, [r0]        @ EXTI_?TSR
  BX      r14

__both_edge_select_exti:
  MOV     r4, #0x08
  MOV     r5, #0x0C
  LDR     r4, [r0, r4]!   @ EXTI_RTSR  
  LDR     r5, [r0, r5]!   @ EXTI_FTSR  
  CMP     r3, #0
  MOV     r3, #0b1
  LSL     r3, r3, r1
  ITTEE   EQ
  BICEQ   r4, r4, r3      @ disable rising edge trigger interrupt on this EXTI line 
  BICEQ   r5, r5, r3      @ disable falling edge trigger interrupt on this EXTI line 
  ORRNE   r4, r4, r3      @ enable rising edge trigger interrupt on this EXTI line
  ORRNE   r5, r5, r3      @ enable falling edge trigger interrupt on this EXTI line
  STR     r4, [r0]        @ EXTI_RTSR
  STR     r5, [r0]        @ EXTI_FTSR
  BX      r14

  .size _edge_select_exti, .-_edge_select_exti

@-------------------------------------------------------------------
@ this function uses bitband addresses for interrupt speed constraints
@ triggers software originated interrupt in the EXTI line specified in r1
@ assumes r1, contains EXTI number to be set (0..18, 21, 22)
@-------------------------------------------------------------------
  .global _swi_exti
  .type _swi_exti, %function   @ Define _swi_exti as a function
_swi_exti:
  LDR   r0, =EXTI_SWIER_BB    @ Load base address of EXTI_SWIER_BB into r0
  ADD   r1, r1, r1, LSL #2    @ Calculate offset: r1 * 4
  ADD   r1, r0, r1            @ Add base address and offset
  MOV   r2, #1                @ Prepare value to write (always 1 in your case)
  STR   r2, [r1]              @ Store the value to the calculated address
  BX    r14                   @ Return from function
  .size _swi_exti, .-_swi_exti

@-------------------------------------------------------------------
@ checks if EXTI line specified in r1 is pending
@ assumes r1, contains the EXTIs to be tested: (0b1100) checks for EXTI2 and EXTI3
@ r2 will contain the result: (0b1000) only EXTI3 is pending
@-------------------------------------------------------------------
  .global _check_pending_exti
  .type _check_pending_exti, %function
_check_pending_exti:
  LDR   r0, =EXTI_BASE       @ Load base address of EXTI registers into r0
  LDR   r2, [r0, #0x14]      @ Load EXTI_PR register value into r2 (assuming EXTI_PR is at offset 0x14)
  AND   r2, r2, r1           @ Perform bitwise AND between EXTI_PR and r1 to check pending lines
  BX    r14                    @ Return from function
  .size _check_pending_exti, .-_check_pending_exti

@----------------------------------------------
  .section .rodata.st_regs, "a", %progbits
@----------------------------------------------
  .equ EXTI_BASE, 0x40013C00
  .equ EXTI_SWIER_BB, 0x42278200