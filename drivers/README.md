# Driver abstraction library

  Each driver will have a file.
  Each driver has sections in the file (.text, .rodata).
  Some have .data and .bss

  Functions that start with one underscore are globally accessible and are callable the others are mearly helpers.
  