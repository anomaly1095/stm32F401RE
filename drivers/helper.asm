
@ macro needs to be defined when the functions
@ are going to be called by c functions 
  #define C_INTEGRATION
#ifdef C_INTEGRATION
  .macro PUSH_R0_R3
    PUSH {r0-r3}
  .endm
  .macro POP_R0_R3
    POP {r0-r3}
  .endm
  .macro PUSH_R0_R44
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