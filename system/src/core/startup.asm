
.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb
@-------------------------------------------

// system interrupt vector table for stm32F401xx
  .section .isr_vectors, "a", %progbits
  .type  g_pfnVectors, %object
 
g_pfnVectors:
  .word  _estack  
  .word  _reset_handler
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
  .thumb_set NMI_Handler, _default_handler

  .weak      HardFault_Handler
  .thumb_set HardFault_Handler, _default_handler

  .weak      MemManage_Handler
  .thumb_set MemManage_Handler, _default_handler

  .weak      BusFault_Handler
  .thumb_set BusFault_Handler, _default_handler

  .weak      UsageFault_Handler
  .thumb_set UsageFault_Handler, _default_handler

  .weak      SVC_Handler
  .thumb_set SVC_Handler, _default_handler

  .weak      DebugMon_Handler
  .thumb_set DebugMon_Handler, _default_handler

  .weak      PendSV_Handler
  .thumb_set PendSV_Handler, _default_handler

  .weak      SysTick_Handler
  .thumb_set SysTick_Handler, _default_handler

  .weak      WWDG_IRQHandler
  .thumb_set WWDG_IRQHandler, _default_handler
                
  .weak      PVD_IRQHandler
  .thumb_set PVD_IRQHandler, _default_handler
            
  .weak      TAMP_STAMP_IRQHandler
  .thumb_set TAMP_STAMP_IRQHandler, _default_handler
          
  .weak      RTC_WKUP_IRQHandler
  .thumb_set RTC_WKUP_IRQHandler, _default_handler
          
  .weak      FLASH_IRQHandler
  .thumb_set FLASH_IRQHandler, _default_handler
                
  .weak      RCC_IRQHandler
  .thumb_set RCC_IRQHandler, _default_handler
                
  .weak      EXTI0_IRQHandler
  .thumb_set EXTI0_IRQHandler, _default_handler
                
  .weak      EXTI1_IRQHandler
  .thumb_set EXTI1_IRQHandler, _default_handler
                  
  .weak      EXTI2_IRQHandler
  .thumb_set EXTI2_IRQHandler, _default_handler
              
  .weak      EXTI3_IRQHandler
  .thumb_set EXTI3_IRQHandler, _default_handler
                      
  .weak      EXTI4_IRQHandler
  .thumb_set EXTI4_IRQHandler, _default_handler
                
  .weak      DMA1_Stream0_IRQHandler
  .thumb_set DMA1_Stream0_IRQHandler, _default_handler
      
  .weak      DMA1_Stream1_IRQHandler
  .thumb_set DMA1_Stream1_IRQHandler, _default_handler
                
  .weak      DMA1_Stream2_IRQHandler
  .thumb_set DMA1_Stream2_IRQHandler, _default_handler
                
  .weak      DMA1_Stream3_IRQHandler
  .thumb_set DMA1_Stream3_IRQHandler, _default_handler
              
  .weak      DMA1_Stream4_IRQHandler
  .thumb_set DMA1_Stream4_IRQHandler, _default_handler
                
  .weak      DMA1_Stream5_IRQHandler
  .thumb_set DMA1_Stream5_IRQHandler, _default_handler
                
  .weak      DMA1_Stream6_IRQHandler
  .thumb_set DMA1_Stream6_IRQHandler, _default_handler
                
  .weak      ADC_IRQHandler
  .thumb_set ADC_IRQHandler, _default_handler
          
  .weak      EXTI9_5_IRQHandler
  .thumb_set EXTI9_5_IRQHandler, _default_handler
          
  .weak      TIM1_BRK_TIM9_IRQHandler
  .thumb_set TIM1_BRK_TIM9_IRQHandler, _default_handler
          
  .weak      TIM1_UP_TIM10_IRQHandler
  .thumb_set TIM1_UP_TIM10_IRQHandler, _default_handler
    
  .weak      TIM1_TRG_COM_TIM11_IRQHandler
  .thumb_set TIM1_TRG_COM_TIM11_IRQHandler, _default_handler
    
  .weak      TIM1_CC_IRQHandler
  .thumb_set TIM1_CC_IRQHandler, _default_handler
                
  .weak      TIM2_IRQHandler
  .thumb_set TIM2_IRQHandler, _default_handler
                
  .weak      TIM3_IRQHandler
  .thumb_set TIM3_IRQHandler, _default_handler
                
  .weak      TIM4_IRQHandler
  .thumb_set TIM4_IRQHandler, _default_handler
                
  .weak      I2C1_EV_IRQHandler
  .thumb_set I2C1_EV_IRQHandler, _default_handler
                  
  .weak      I2C1_ER_IRQHandler
  .thumb_set I2C1_ER_IRQHandler, _default_handler
                  
  .weak      I2C2_EV_IRQHandler
  .thumb_set I2C2_EV_IRQHandler, _default_handler
                
  .weak      I2C2_ER_IRQHandler
  .thumb_set I2C2_ER_IRQHandler, _default_handler
                        
  .weak      SPI1_IRQHandler
  .thumb_set SPI1_IRQHandler, _default_handler
                      
  .weak      SPI2_IRQHandler
  .thumb_set SPI2_IRQHandler, _default_handler
                
  .weak      USART1_IRQHandler
  .thumb_set USART1_IRQHandler, _default_handler
                  
  .weak      USART2_IRQHandler
  .thumb_set USART2_IRQHandler, _default_handler

  .weak      EXTI15_10_IRQHandler
  .thumb_set EXTI15_10_IRQHandler, _default_handler

  .weak      RTC_Alarm_IRQHandler
  .thumb_set RTC_Alarm_IRQHandler, _default_handler
          
  .weak      OTG_FS_WKUP_IRQHandler
  .thumb_set OTG_FS_WKUP_IRQHandler, _default_handler
          
  .weak      DMA1_Stream7_IRQHandler
  .thumb_set DMA1_Stream7_IRQHandler, _default_handler
                  
  .weak      SDIO_IRQHandler
  .thumb_set SDIO_IRQHandler, _default_handler
                  
  .weak      TIM5_IRQHandler
  .thumb_set TIM5_IRQHandler, _default_handler
                  
  .weak      SPI3_IRQHandler
  .thumb_set SPI3_IRQHandler, _default_handler
                  
  .weak      DMA2_Stream0_IRQHandler
  .thumb_set DMA2_Stream0_IRQHandler, _default_handler
            
  .weak      DMA2_Stream1_IRQHandler
  .thumb_set DMA2_Stream1_IRQHandler, _default_handler
                
  .weak      DMA2_Stream2_IRQHandler
  .thumb_set DMA2_Stream2_IRQHandler, _default_handler
          
  .weak      DMA2_Stream3_IRQHandler
  .thumb_set DMA2_Stream3_IRQHandler, _default_handler
          
  .weak      DMA2_Stream4_IRQHandler
  .thumb_set DMA2_Stream4_IRQHandler, _default_handler
          
  .weak      OTG_FS_IRQHandler
  .thumb_set OTG_FS_IRQHandler, _default_handler
                  
  .weak      DMA2_Stream5_IRQHandler
  .thumb_set DMA2_Stream5_IRQHandler, _default_handler
                
  .weak      DMA2_Stream6_IRQHandler
  .thumb_set DMA2_Stream6_IRQHandler, _default_handler
                
  .weak      DMA2_Stream7_IRQHandler
  .thumb_set DMA2_Stream7_IRQHandler, _default_handler
                
  .weak      USART6_IRQHandler
  .thumb_set USART6_IRQHandler, _default_handler

  .weak      I2C3_EV_IRQHandler
  .thumb_set I2C3_EV_IRQHandler, _default_handler

  .weak      I2C3_ER_IRQHandler   
  .thumb_set I2C3_ER_IRQHandler, _default_handler

  .weak      FPU_IRQHandler
  .thumb_set FPU_IRQHandler, _default_handler

  .weak      SPI4_IRQHandler
  .thumb_set SPI4_IRQHandler, _default_handler


@-------------------------------------------

  .section .text.default_handler, "ax", %progbits
  .type _default_handler, %function
  .weak _default_handler
  .global _default_handler
_default_handler:
  B _default_handler
  .size _default_handler, .-_default_handler

@-------------------------------------------

  .section .text.reset_handler, "ax", %progbits
  .type _reset_handler, %function
  .global _reset_handler
  .extern _sysinit
  .extern _start

_reset_handler:
  LDR   sp, =_msp

  @ copy kernel .data section from FLASH to SRAM
  LDR   r0, =_si_k_data
  LDR   r1, =_s_k_data
  LDR   r2, =_e_k_data
__copy_k_data:
  CMP   r1, r2
  LDRNE r3, [r0], #0x04
  STRNE r3, [r1], #0x04
  BNE   __copy_data

  @ initialize kernel .bss section with zeross
  LDR   r0, =_s_k_bss
  LDR   r1, =_e_k_bss
  MOV   r2, #0
__zero_k_bss:
  CMP   r0, r1
  STRNE r2, [r0], #4
  BNE   __zero_k_bss

  @ transition to system initialization
  BL    _sysinit

@ APP INITIALIZATION SECTION
  @ copy app .data section from FLASH to SRAM
  LDR   r0, =_si_app_data
  LDR   r1, =_s_app_data
  LDR   r2, =_e_app_data
__copy_app_data:
  CMP   r1, r2
  LDRNE r3, [r0], #0x04
  STRNE r3, [r1], #0x04
  BNE   __copy_data

  @ initialize app .bss section with zeros
  LDR   r0, =_s_app_bss
  LDR   r1, =_e_app_bss
  MOV   r2, #0
__zero_app_bss:
  CMP   r0, r1
  STRNE r2, [r0], #4
  BNE   __zero_app_bss

  @ set sp to PSP
  MOVW  r2, #0b10
  ORR   control, control, r2
  LDR   sp, =_psp
  @ set execution mode to unprivileged thumb mode
  MOVW  r2, #0b011
  ORR   control, control, r2
  @ branch to application firmware
  BL    _start

  @ if execution ever returns from firmware: branch to _default_handler
  B     _default_handler
  
  .size _reset_handler, .-_reset_handler

@-------------------------------------------

  .section .rodata, "a", %progbits
  .word _si_k_data   @ start of kernel .data section in FLASH
  .word _s_k_data    @ start of kernel .data section in SRAM
  .word _e_k_data    @ end   of kernel .data section in SRAM
  .word _s_k_bss     @ start of kernel .bss  section in SRAM
  .word _e_k_bss     @ end   of kernel .bss  section in SRAM
  .word _si_app_data @ start of kernel .data section in FLASH
  .word _s_app_data  @ start of app    .data section in SRAM
  .word _e_app_data  @ end   of app    .data section in SRAM
  .word _s_app_bss   @ start of app    .bss  section in SRAM
  .word _e_app_bss   @ end   of app    .bss  section in SRAM
