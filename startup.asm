@ 
@ startup file (interrupt vector table, reset handler->entry point)
@ 

.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16 // HARDWARE FLOATING POINT UNIT
.thumb

  .global reset_handler
  .global default_handler
  .extern _start

@-------------------------------------------

// system interrupt vector table for stm32F401xx
  .section .isr_vectors, "a", %progbits
  .type  g_pfnVectors, %object
 
g_pfnVectors:
  .word  _estack
  .word  reset_handler
  .word  NMI_Handler
  .word  HardFault_Handler
  .word  MemManage_Handler
  .word  BusFault_Handler
  .word  UsageFault_Handler
  .word  0
  .word  0
  .word  0
  .word  0
  .word  SVC_Handler
  .word  DebugMon_Handler
  .word  0
  .word  PendSV_Handler
  .word  SysTick_Handler
  
  /* External Interrupts */
  .word     WWDG_IRQHandler
  .word     PVD_IRQHandler
  .word     TAMP_STAMP_IRQHandler
  .word     RTC_WKUP_IRQHandler
  .word     FLASH_IRQHandler                  
  .word     RCC_IRQHandler                    
  .word     EXTI0_IRQHandler
  .word     EXTI1_IRQHandler 
  .word     EXTI2_IRQHandler 
  .word     EXTI3_IRQHandler 
  .word     EXTI4_IRQHandler 
  .word     DMA1_Stream0_IRQHandler 
  .word     DMA1_Stream1_IRQHandler 
  .word     DMA1_Stream2_IRQHandler 
  .word     DMA1_Stream3_IRQHandler 
  .word     DMA1_Stream4_IRQHandler 
  .word     DMA1_Stream5_IRQHandler 
  .word     DMA1_Stream6_IRQHandler 
  .word     ADC_IRQHandler
  .word     0
  .word     0
  .word     0
  .word     0
  .word     EXTI9_5_IRQHandler
  .word     TIM1_BRK_TIM9_IRQHandler
  .word     TIM1_UP_TIM10_IRQHandler
  .word     TIM1_TRG_COM_TIM11_IRQHandler
  .word     TIM1_CC_IRQHandler
  .word     TIM2_IRQHandler
  .word     TIM3_IRQHandler
  .word     TIM4_IRQHandler
  .word     I2C1_EV_IRQHandler
  .word     I2C1_ER_IRQHandler
  .word     I2C2_EV_IRQHandler
  .word     I2C2_ER_IRQHandler
  .word     SPI1_IRQHandler
  .word     SPI2_IRQHandler
  .word     USART1_IRQHandler
  .word     USART2_IRQHandler
  .word     0
  .word     EXTI15_10_IRQHandler
  .word     RTC_Alarm_IRQHandler
  .word     OTG_FS_WKUP_IRQHandler
  .word     0
  .word     0
  .word     0
  .word     0
  .word     DMA1_Stream7_IRQHandler
  .word     0
  .word     SDIO_IRQHandler
  .word     TIM5_IRQHandler
  .word     SPI3_IRQHandler
  .word     0
  .word     0
  .word     0
  .word     0
  .word     DMA2_Stream0_IRQHandler
  .word     DMA2_Stream1_IRQHandler
  .word     DMA2_Stream2_IRQHandler
  .word     DMA2_Stream3_IRQHandler
  .word     DMA2_Stream4_IRQHandler
  .word     0  
  .word     0
  .word     0
  .word     0
  .word     0
  .word     0
  .word     OTG_FS_IRQHandler
  .word     DMA2_Stream5_IRQHandler 
  .word     DMA2_Stream6_IRQHandler 
  .word     DMA2_Stream7_IRQHandler 
  .word     USART6_IRQHandler
  .word     I2C3_EV_IRQHandler
  .word     I2C3_ER_IRQHandler
  .word     0
  .word     0
  .word     0
  .word     0
  .word     0
  .word     0
  .word     0
  .word     FPU_IRQHandler
  .word     0
  .word     0
  .word     SPI4_IRQHandler


  .size  g_pfnVectors, .-g_pfnVectors

/**
*  weak to be able to be overriden 
*/
  .weak      NMI_Handler
  .thumb_set NMI_Handler,default_handler

  .weak      HardFault_Handler
  .thumb_set HardFault_Handler,default_handler

  .weak      MemManage_Handler
  .thumb_set MemManage_Handler,default_handler

  .weak      BusFault_Handler
  .thumb_set BusFault_Handler,default_handler

  .weak      UsageFault_Handler
  .thumb_set UsageFault_Handler,default_handler

  .weak      SVC_Handler
  .thumb_set SVC_Handler,default_handler

  .weak      DebugMon_Handler
  .thumb_set DebugMon_Handler,default_handler

  .weak      PendSV_Handler
  .thumb_set PendSV_Handler,default_handler

  .weak      SysTick_Handler

  .weak      WWDG_IRQHandler
  .thumb_set WWDG_IRQHandler,default_handler
                
  .weak      PVD_IRQHandler
  .thumb_set PVD_IRQHandler,default_handler
            
  .weak      TAMP_STAMP_IRQHandler
  .thumb_set TAMP_STAMP_IRQHandler,default_handler
          
  .weak      RTC_WKUP_IRQHandler
  .thumb_set RTC_WKUP_IRQHandler,default_handler
          
  .weak      FLASH_IRQHandler
  .thumb_set FLASH_IRQHandler,default_handler
                
  .weak      RCC_IRQHandler
  .thumb_set RCC_IRQHandler,default_handler
                
  .weak      EXTI0_IRQHandler
  .thumb_set EXTI0_IRQHandler,default_handler
                
  .weak      EXTI1_IRQHandler
  .thumb_set EXTI1_IRQHandler,default_handler
                  
  .weak      EXTI2_IRQHandler
  .thumb_set EXTI2_IRQHandler,default_handler 
              
  .weak      EXTI3_IRQHandler
  .thumb_set EXTI3_IRQHandler,default_handler
                      
  .weak      EXTI4_IRQHandler
  .thumb_set EXTI4_IRQHandler,default_handler
                
  .weak      DMA1_Stream0_IRQHandler
  .thumb_set DMA1_Stream0_IRQHandler,default_handler
      
  .weak      DMA1_Stream1_IRQHandler
  .thumb_set DMA1_Stream1_IRQHandler,default_handler
                
  .weak      DMA1_Stream2_IRQHandler
  .thumb_set DMA1_Stream2_IRQHandler,default_handler
                
  .weak      DMA1_Stream3_IRQHandler
  .thumb_set DMA1_Stream3_IRQHandler,default_handler 
              
  .weak      DMA1_Stream4_IRQHandler
  .thumb_set DMA1_Stream4_IRQHandler,default_handler
                
  .weak      DMA1_Stream5_IRQHandler
  .thumb_set DMA1_Stream5_IRQHandler,default_handler
                
  .weak      DMA1_Stream6_IRQHandler
  .thumb_set DMA1_Stream6_IRQHandler,default_handler
                
  .weak      ADC_IRQHandler
  .thumb_set ADC_IRQHandler,default_handler
          
  .weak      EXTI9_5_IRQHandler
  .thumb_set EXTI9_5_IRQHandler,default_handler
          
  .weak      TIM1_BRK_TIM9_IRQHandler
  .thumb_set TIM1_BRK_TIM9_IRQHandler,default_handler
          
  .weak      TIM1_UP_TIM10_IRQHandler
  .thumb_set TIM1_UP_TIM10_IRQHandler,default_handler
    
  .weak      TIM1_TRG_COM_TIM11_IRQHandler
  .thumb_set TIM1_TRG_COM_TIM11_IRQHandler,default_handler
    
  .weak      TIM1_CC_IRQHandler
  .thumb_set TIM1_CC_IRQHandler,default_handler
                
  .weak      TIM2_IRQHandler
  .thumb_set TIM2_IRQHandler,default_handler
                
  .weak      TIM3_IRQHandler
  .thumb_set TIM3_IRQHandler,default_handler
                
  .weak      TIM4_IRQHandler
  .thumb_set TIM4_IRQHandler,default_handler
                
  .weak      I2C1_EV_IRQHandler
  .thumb_set I2C1_EV_IRQHandler,default_handler
                  
  .weak      I2C1_ER_IRQHandler
  .thumb_set I2C1_ER_IRQHandler,default_handler
                  
  .weak      I2C2_EV_IRQHandler
  .thumb_set I2C2_EV_IRQHandler,default_handler
                
  .weak      I2C2_ER_IRQHandler
  .thumb_set I2C2_ER_IRQHandler,default_handler
                        
  .weak      SPI1_IRQHandler
  .thumb_set SPI1_IRQHandler,default_handler
                      
  .weak      SPI2_IRQHandler
  .thumb_set SPI2_IRQHandler,default_handler
                
  .weak      USART1_IRQHandler
  .thumb_set USART1_IRQHandler,default_handler
                  
  .weak      USART2_IRQHandler
  .thumb_set USART2_IRQHandler,default_handler
                                
  .weak      EXTI15_10_IRQHandler
  .thumb_set EXTI15_10_IRQHandler,default_handler
            
  .weak      RTC_Alarm_IRQHandler
  .thumb_set RTC_Alarm_IRQHandler,default_handler
          
  .weak      OTG_FS_WKUP_IRQHandler
  .thumb_set OTG_FS_WKUP_IRQHandler,default_handler
          
  .weak      DMA1_Stream7_IRQHandler
  .thumb_set DMA1_Stream7_IRQHandler,default_handler
                  
  .weak      SDIO_IRQHandler
  .thumb_set SDIO_IRQHandler,default_handler
                  
  .weak      TIM5_IRQHandler
  .thumb_set TIM5_IRQHandler,default_handler
                  
  .weak      SPI3_IRQHandler
  .thumb_set SPI3_IRQHandler,default_handler
                  
  .weak      DMA2_Stream0_IRQHandler
  .thumb_set DMA2_Stream0_IRQHandler,default_handler
            
  .weak      DMA2_Stream1_IRQHandler
  .thumb_set DMA2_Stream1_IRQHandler,default_handler
                
  .weak      DMA2_Stream2_IRQHandler
  .thumb_set DMA2_Stream2_IRQHandler,default_handler
          
  .weak      DMA2_Stream3_IRQHandler
  .thumb_set DMA2_Stream3_IRQHandler,default_handler
          
  .weak      DMA2_Stream4_IRQHandler
  .thumb_set DMA2_Stream4_IRQHandler,default_handler
          
  .weak      OTG_FS_IRQHandler
  .thumb_set OTG_FS_IRQHandler,default_handler
                  
  .weak      DMA2_Stream5_IRQHandler
  .thumb_set DMA2_Stream5_IRQHandler,default_handler
                
  .weak      DMA2_Stream6_IRQHandler
  .thumb_set DMA2_Stream6_IRQHandler,default_handler
                
  .weak      DMA2_Stream7_IRQHandler
  .thumb_set DMA2_Stream7_IRQHandler,default_handler
                
  .weak      USART6_IRQHandler
  .thumb_set USART6_IRQHandler,default_handler
                      
  .weak      I2C3_EV_IRQHandler
  .thumb_set I2C3_EV_IRQHandler,default_handler
                      
  .weak      I2C3_ER_IRQHandler   
  .thumb_set I2C3_ER_IRQHandler,default_handler
                      
  .weak      FPU_IRQHandler
  .thumb_set FPU_IRQHandler,default_handler  

  .weak      SPI4_IRQHandler
  .thumb_set SPI4_IRQHandler,default_handler 


@-------------------------------------------

  .section .text.default_handler, "ax", %progbits
  .type default_handler, %function
  .weak default_handler
default_handler:
  B default_handler
  .size default_handler, .-default_handler

@-------------------------------------------

  .section .text.reset_handler, "ax", %progbits
  .type reset_handler, %function

reset_handler:
  LDR     sp, =_estack
  BL      sys_config      @ setup system clocks, prescalers, timers
  LDR     r0, =_sidata
  LDR     r1, =_sdata
  LDR     r2, =_edata
copy_data:
  CMP     r1, r2
  LDRNE   r3, [r0], #0x04 @ load word from FLASH
  STRNE   r3, [r1], #0x04 @ store word in RAM
  BNE     copy_data

  LDR     r0, =_sbss
  LDR     r1, =_ebss
  MOV     r2, #0 
zero_bss:
  CMP     r0, r1
  STRNE   r2, [r0], #0x04 @ store a zero in bss
  BNE     zero_bss

  BL      periph_config
  BL      _start
  BL      default_handler

  .size reset_handler, .-reset_handler

@----------------------------------------

  .section .text.sys_config, "ax", %progbits
  .type sys_config, %function
  
sys_config:
  LDR     r0, =RCC_BASE

HSI_enable:
  LDR     r1, [r0, #0x00] @ RCC_CR
  MOVW    r2, #0b1
  ORR     r1, r1, r2
  STR     r1, [r0, #0x00] @ RCC_CR

  LSL     r2, r2, #1      @ shift to ready bits
HSI_rdy_wait:
  LDR     r1, [r0, #0x00] @ RCC_CR
  TST     r1, r2
  BEQ     wait_rdy_HSI

  @ set pll at 84Mhz
PLL_config:
  LDR     r1, [r0, #0x04] @ RCC_PLLCFGR
  @ PLLN
  MOVW    r2, #336
  LSL     r2, r2, #6
  ORR     r1, r1, r2
  @ PLLM
  MOVW    r2, #16
  ORR     r1, r1, r2
  @ PLLP
  MOVW    r2, #01
  LSL     r2, r2, #16
  ORR     r1, r1, r2
  @ PLLSRC
  MOVW    r2, #0b1
  LSL     r2, r2, #22
  ORR     r1, r1, r2
  @ save changes
  STR     r1, [r0, #0x04] @ RCC_PLLCFGR

PLL_enable:
  LDR     r1, [r0, #0x00] @ RCC_CR
  MOV     r2, #0b1
  LSL     r2, r2, #24
  ORR     r1, r1, r2
  STR     r1, [r0, #0x00] @ RCC_CR

  LSL     r2, r2, #1      @ shift to ready bits
PLL_rdy_wait:
  LDR     r1, [r0, #0x00] @ RCC_CR
  TST     r1, r2
  BEQ     PLL_rdy_wait

SYSCLK_set:
  LDR     r1, [r0, #0x08] @ RCC_CFGR
  MOV     r2, #0b10
  ORR     r1, r1, r2
  STR     r1, [r0, #0x08] @ RCC_CFGR

  LSL     r2, #2          @ shift to ready bits
SYSCLK_rdy_wait: 
  LDR     r1, [r0, #0x08] @ RCC_CFGR
  TST     r1, r2
  BEQ     SYSCLK_rdy_wait

  @ set HCLK at 84Mhz
HPRE:
  LDR     r1, [r0, #0x08] @ RCC_CFGR
  MOVW    r2, #(0b1 << 4)
  BIC     r1, r1, r2
  STR     r1, [r0, #0x08] @ RCC_CFGR

  @ set PCLK1 at AHB/2 = 42Mhz
PPRE1:
  LDR     r1, [r0, #0x08] @ RCC_CFGR
  MOVW    r2, #(0b100 << 10)
  ORR     r1, r1, r2
  STR     r1, [r0, #0x08] @ RCC_CFGR

  @

  @ setting the processor timer to generate 1 interrupt each millisecond
systick_config:
  LDR     r0, =SYSTICK_BASE
  @ set reload val
  LDR     r1, [r0, #0x04] @ SYST_RVR
  MOVW    r2, #10499      @ set reload val to 10500 ticks/ms
  ORR     r1, r1, r2
  STR     r1, [r0, #0x04] @ SYST_RVR
  @ reset counter
  MOV     r2, #0x0
  STR     r2, [r0, #0x08] @ SYST_CVR
  @ enable systick & systick interrupt (1 intr.ms⁻¹) & set HCLK 
  LDR     r1, [r0, #0x00] @ SYST_CSR
  MOV     r2, #0b111
  ORR     r1, r1, r2
  STR     r1, [r0, #0x00] @ SYST_CSR
  @ return
  BX      lr 
  .size sysconfig, .-sysconfig

@----------------------------------------

  .section .rodata, "a", %progbits
  .global RCC_BASE
    
  .equ RCC_BASE, 0x40023800
  .equ SYSTICK_BASE, 0xE000E010
  
  .word _sidata
  .word _sdata
  .word _edata
  .word _sbss
  .word _ebss

@-------------------------------------------
