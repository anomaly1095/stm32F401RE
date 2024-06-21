MEMORY
{
  ROM (rx): ORIGIN = 0x08000000, LENGTH = 512K
  RAM (rw): ORIGIN = 0x20000000, LENGTH = 96K
}

ENTRY(reset_handler)

_estack = ORIGIN(RAM) + LENGTH(RAM)

min_stack_len = 0x200
min_heap_len = 0x200

SECTIONS 
{
  .isr_vector : 
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector))
    . = ALIGN(4);
  } > ROM

  .text :
  {
    . = ALIGN(4);
    *(.text)
    *(.text.default_handler)
    *(.text.reset_handler)
    *(.text.sys_config)
    *(.text.periph_config)
    *(.text.firmware)
    *(.text.*)
    *(.glue_7)         /* glue arm to thumb code */
    *(.glue_7t)        /* glue thumb to arm code */
    *(.eh_frame)
    . = ALIGN(4);
  } > ROM

  .rodata :
  {
    . = ALIGN(4);
    *(.rodata)
    *(.rodata.*)
    . = ALIGN(4);
  } > ROM

  .ARM :
  {
    . = ALIGN(4);
    __exidx_start = .;
    *(.ARM)
    *(.ARM.exidx*)
    *(.ARM.*)
    __exidx_end = .;
    . = ALIGN(4);
  } > ROM

  _sidata = LOADADDR(.data);
  .data :
  {
    . = ALIGN(4);
    _sdata = .;

    /* Define a label for the end of the .data section in ROM */
    _edata_rom = .; /* This will be the end of .data in ROM */
    . = ALIGN(4);
  } > RAM AT> ROM

  .bss (NOLOAD):
  {
    . = ALIGN(4);
    _sbss = .;
    
    _ebss = .; /* Corrected label for end of .bss in RAM */
    . = ALIGN(4);
  } > RAM

  .heap :
  {
    . = ALIGN(4);
    PROVIDE(end) = .;
    PROVIDE(_end) = .;
    . = . + min_heap_len;
    . = ALIGN(4);
  } > RAM
  
  .stack :
  {
    . = ALIGN(4);
    . = . + min_stack_len;
    . = ALIGN(4);    
  } > RAM

  /* Asserts for memory boundaries */
  ASSERT(_estack >= ORIGIN(RAM) + LENGTH(RAM), "Error: _estack is beyond RAM boundary")
  ASSERT(_sidata >= ORIGIN(ROM) && _sidata < ORIGIN(ROM) + LENGTH(ROM), "Error: _sidata is not in ROM boundary")
  ASSERT(_edata_rom <= ORIGIN(ROM) + LENGTH(ROM), "Error: End of .data in ROM exceeds ROM boundary")
  
  .ARM.attributes 0 : { *(.ARM.attributes) }
}
