


MEMORY
{
  FLASH(rx): ORIGIN = 0X08000000, LENGTH = 512K
  RAM(rw): ORIGIN = 0X20000000, LENGTH = 96K
}

ENTRY(reset_handler)
_estack = ORIGIN(RAM) + LENGTH(RAM)

min_stack_size = 0x400 
min_heap_size = 0x400

SECTIONS
{
  .isr_vectors :
  {
    .ALIGN(4);
    KEEP(*(isr_vectors));
    .ALIGN(4);
  }

  .text : 
  {
    .ALIGN(4);
    *(.text.default_handler)  /* default interrupt handler */
    *(.text.reset_handler)    /* code entry point */
    *(.text.sys_config)       /* SYSCLK clock configs */
    *(.text.periph_config)    /* peripheral config */
    *(.text.main)             /* firmware entry point */
    *(.glue_7)                /* glue arm to thumb code */
    *(.glue_7t)               /* glue thumb to arm code */
    *(.eh_frame)
    .ALIGN(4);
  } > FLASH

  .rodata : 
  {
    .ALIGN(4);
    *(.rodata)
    *(.rodata.*)
    .ALIGN(4);
  } > FLASH
  
  .ARM :
  {
    . = ALIGN(4);
    __exidx_start = .;
    *(.ARM.exidx*)
    __exidx_end = .;
    . = ALIGN(4);
  } > FLASH
  
  _sidata = LOADADDR(.data);
  .data : 
  {
    .ALIGN(4);
    _sdata = .;
    *(.data)
    *(.data.*)
    _edata = .;
    .ALIGN(4);
  } > RAM AT> FLASH

  .bss (NOLOAD): 
  {
    .ALIGN(4);
    _sbss = .;
    *(.bss)
    *(.bss.*)
    *(COMMON)
    _ebss = .;
    .ALIGN(4);
  } > RAM

  .heap :
  {
    .ALIGN(8);
    PROVIDE (_end = .);
    PROVIDE (end = .);
    . = . + min_heap_size;
    .ALIGN(8);
  } > RAM

  .stack : 
  {
    .ALIGN(8);
    . = . + min_stack_size;
    .ALIGN(8);
  } > RAM

  ASSERT(_estack >= _edata + (_ebss - _sbss) + min_heap_size + min_stack_size, "Warning: Not enough memory")
  .ARM.attributes 0 : { *(.ARM.attributes) }
}