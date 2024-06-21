/**
 * Custom linker script
 */
OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)

MEMORY
{
  FLASH(rx) : ORIGIN = 0x08000000, LENGTH = 512K
  RAM(rw)  : ORIGIN = 0x20000000, LENGTH = 96K
}

ENTRY(reset_handler)

_estack = ORIGIN(RAM) + LENGTH(RAM);

min_heap_size = 0x200;
min_stack_size = 0x400;

SECTIONS
{
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector))
    . = ALIGN(4);
  } > FLASH

  .text :
  {
    . = ALIGN(4);
    *(.text.default_handler)
    *(.text.reset_handler)
    *(.text.sys_conf)
    *(.text.periphconf)
    *(.text.firmware)
    *(.glue_7)         /* glue arm to thumb code */
    *(.glue_7t)        /* glue thumb to arm code */
    *(.eh_frame)
    . = ALIGN(4);
  } > FLASH
  
  .rodata :
  {
    . = ALIGN(4);
    *(.rodata)         /* .rodata sections (reegister addresses) */
    . = ALIGN(4);
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
    . = ALIGN(4);
    _sdata = .;
    *(.data)
    *(.data*)
    . = ALIGN(4);  /* .data section not used */
    _edata = .;
  } > RAM AT > FLASH
  
  .bss (NOLOAD) :
  {
    . = ALIGN(4);
    _sbss = .;
    *(.bss*)
    *(COMMON)
    . = ALIGN(4); /* .bss section not used */
    _ebss = .;
  } > RAM

  /* User_heap_stack section, used to check that there is enough "RAM" memory left */
  
  .user_heap :
  {
    . = ALIGN(8);
    PROVIDE ( end = . );
    PROVIDE ( _end = . );
    . = . + min_heap_size; /* .heap section not used */
    . = ALIGN(8);
  } > RAM

  .user_stack :
  {
    . = ALIGN(8);
    . = . + min_stack_size; /* .stack section not used */
    . = ALIGN(8);
  } > RAM

  /* Adjusted ASSERT to ensure stack and heap fit in RAM */
  ASSERT(_estack >= _edata + (_ebss - _sbss) + min_heap_size + min_stack_size, "Not enough memory")
  
  .ARM.attributes 0 : { *(.ARM.attributes) }
}
