.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

#ifdef C_INTEGRATION
.macro PUSH_R0_R3
  PUSH {r0-r3}
.endm
.macro POP_R0_R3
  POP {r0-r3}
.endm
.macro PUSH_R0_R4
  PUSH {r0-r4}
.endm
.macro POP_R0_R4
  POP {r0-r4}
.endm
.macro PUSH_R0_R5
  PUSH {r0-r5}
.endm
.macro POP_R0_R5
  POP {r0-r5}
.endm
#else
.macro PUSH_R0
.endm
.macro POP_R0
.endm
.macro PUSH_R0_R1
.endm
.macro POP_R0_R1
.endm
.macro PUSH_R0_R2
.endm
.macro POP_R0_R2
.endm
.macro PUSH_R0_R3
.endm
.macro POP_R0_R3
.endm
.macro PUSH_R0_R4
.endm
.macro POP_R0_R4
.endm
.macro PUSH_R0_R5
.endm
.macro POP_R0_R5
.endm
#endif

.macro GPIO_CMP_LDR_PORT port_char, port_addr
  CMP     r0, #\port_char
  IT      EQ
  LDREQ   r0, =\port_addr
.endm
