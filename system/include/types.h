
#ifndef CORTEXM4_TYPES_H
#define CORTEXM4_TYPES_H      1

  /* .byte */
  typedef signed char int8_t;
  typedef unsigned char uint8_t;

  /* .short */
  typedef signed short int16_t;
  typedef unsigned short uint16_t;

  /* .word */
  typedef signed int int32_t;
  typedef unsigned int uint32_t;

  /* .quad */
  typedef signed long long int64_t;
  typedef unsigned long long uint64_t;

  /* single presition floating point arithmetics 
    supported by the cortex-M4 hardware FPU*/
  typedef float float32_t;
  /* double peersition floating point arithmetic 
    not supported by the cortex-M4 hardware FPU
    but emulted by software*/
  typedef float float64_t;



#endif // !CORTEXM4_TYPES_H   1