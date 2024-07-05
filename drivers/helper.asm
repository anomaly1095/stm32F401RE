
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
  .macro PUSH_R0_R5
  .endm
  .macro POP_R0_R5
  .endm
#endif