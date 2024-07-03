
MEMORY
{
  /* 512KB of FLASH memory */
  FLASH (rx)     : ORIGIN = 0x08000000, LENGTH = 512K   /* full FLASH */
  K_FLASH (rx)   : ORIGIN = 0x08000000, LENGTH = 128K   /* sectors 0..4*/
  APP_FLASH (rx) : ORIGIN = 0x08020000, LENGTH = 384K   /* sectors 5..7*/
  
  /* 96KB of volatile memory */
  SRAM (rw)     : ORIGIN = 0x20000000, LENGTH = 96K   /* FULL SRAM */
  APP_SRAM (rw) : ORIGIN = 0x20000000, LENGTH = 64K   /* Application space */
  K_SRAM (rw)   : ORIGIN = 0x20010000, LENGTH = 32K   /* Kernel space */
}

ENTRY(_reset_handler)                                 /* initial pc address */
_msp = ORIGIN(K_SRAM) + LENGTH(K_SRAM)                /* Main stack pointer */
_psp = ORIGIN(APP_SRAM) + LENGTH(APP_SRAM)            /* Program stack pointer */

/* we configure these values post dev */
min_k_stack = 0x400
min_k_heap = 0x400
min_app_stack = 0x400
min_app_heap = 0x400

SECTIONS
{
  /*-----------------------------------------------*/
  /*-------------KERNEL sections-------------------*/
  /*-----------------------------------------------*/

  /* Interrupt vector table */
  .isr_vector : 
  {
    ALIGN(4);
    KEEP(*(.isr_vector))
    ALIGN(4);
  } > K_FLASH

  /* Kernel code section */
  .k_text :
  {
    ALIGN(4);
    *(.text._reset_handler)
    *(.text._sysinit)
    *(.text.drivers)
    ALIGN(4);
  } > K_FLASH

  /* Kernel read-only data section */
  .k_rodata : 
  {
    ALIGN(4);
    *(.rodata.sys_regs)
    *(.rodata.st_periphs)
    *(.rodata.masks)
    *(.rodata.keys)
    ALIGN(4);
  } > K_FLASH

  _si_k_data = LOADADDR(.k_data);

  /* Kernel data section */
  .k_data : 
  {
    ALIGN(4);
    _s_k_data = .;
    /*add sections*/
    _e_k_data = .;
    ALIGN(4);
  } > K_SRAM AT> K_FLASH

  .k_bss (NOLOAD): 
  {
    ALIGN(4);
    _s_k_bss = .;
    *(COMMON)
    _e_k_bss = .;
    ALIGN(4);
  } > K_SRAM

  .k_heap (NOLOAD): 
  {
    ALIGN(4);
    PROVIDE (_s_k_heap = .);
    . = . + min_k_heap;
    PROVIDE (_e_k_heap = .);
    ALIGN(4);
  } > K_SRAM

  .k_stack (NOLOAD): 
  {
    ALIGN(4);
    PROVIDE (_s_k_stack = .);
    . = . + min_k_stack;
    PROVIDE (_e_k_stack = .);    
    ALIGN(4);
  } > K_SRAM

  /*-----------------------------------------------*/
  /*-------------APP sections-------------------*/
  /*-----------------------------------------------*/

  /* Application code section */
  .app_text : 
  {
    ALIGN(4);
    *(.text.main)
    /*add sections*/
    *(.glue_7)         /* glue arm to thumb code */
    *(.glue_7t)        /* glue thumb to arm code */
    *(.eh_frame)
    ALIGN(4);
  } > APP_FLASH

  /* Application read-only data section */
  .app_rodata : 
  {
    ALIGN(4);
    /*add sections*/
    ALIGN(4);
  } > APP_FLASH

  .ARM :
  {
    . = ALIGN(4);
    __exidx_start = .;
    *(.ARM.exidx*)
    __exidx_end = .;
    . = ALIGN(4);
  } > APP_FLASH

  _si_app_data = LOADADDR(.app_data);

  /* Application data section */
  .app_data : 
  {
    ALIGN(4);
    _s_app_data = .;
    /*add sections*/
    _e_app_data = .;
    ALIGN(4);
  } > APP_SRAM AT> APP_FLASH

  .app_bss (NOLOAD): 
  {
    ALIGN(4);
    _s_app_bss = .;
    /*add sections*/
    _e_app_bss = .;
    ALIGN(4);
  } > APP_SRAM

  .app_heap (NOLOAD): 
  {
    ALIGN(4);
    PROVIDE (_s_app_heap = .);    
    /*add sections*/
    . = . + min_app_heap;
    PROVIDE (_e_app_heap = .);    
    ALIGN(4);
  } > APP_SRAM

  .app_stack (NOLOAD): 
  {
    ALIGN(4);
    PROVIDE (_s_app_stack = .);    
    /*add sections*/
    . = . + min_app_stack;
    PROVIDE (_e_app_stack = .);    
    ALIGN(4);
  } > APP_SRAM

  /* Assertions to ensure memory allocations are within limits */
  ASSERT(_e_app_data  <= ORIGIN(APP_FLASH)+ LENGTH(APP_FLASH),"Not enough application data space")
  ASSERT(_e_app_bss   <= ORIGIN(APP_SRAM) + LENGTH(APP_SRAM), "Not enough application BSS space")
  ASSERT(_e_app_heap  <= ORIGIN(APP_SRAM) + LENGTH(APP_SRAM), "Not enough application heap space")
  ASSERT(_e_app_stack <= ORIGIN(APP_SRAM) + LENGTH(APP_SRAM), "Not enough application stack space")

  ASSERT(_e_k_data    <= ORIGIN(K_FLASH)  + LENGTH(K_FLASH),  "Not enough kernel data space")
  ASSERT(_e_k_bss     <= ORIGIN(K_SRAM)   + LENGTH(K_SRAM),   "Not enough kernel BSS space")
  ASSERT(_e_k_heap    <= ORIGIN(K_SRAM)   + LENGTH(K_SRAM),   "Not enough kernel heap space")
  ASSERT(_e_k_stack   <= ORIGIN(K_SRAM)   + LENGTH(K_SRAM),   "Not enough kernel stack space")

  /* Ensure total allocation within APP_SRAM and K_SRAM limits */
  ASSERT(_e_app_data  <= ORIGIN(APP_SRAM) + LENGTH(APP_SRAM), "Total application SRAM allocation exceeded")
  ASSERT(_e_k_data    <= ORIGIN(K_SRAM)   + LENGTH(K_SRAM),   "Total kernel SRAM allocation exceeded")

  .ARM.attributes 0 : { *(.ARM.attributes) }
}
