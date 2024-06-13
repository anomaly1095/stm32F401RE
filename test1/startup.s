.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16 // HARDWARE FLOATING POINT UNIT
.thumb

.extern _start // firmware entry point
.extern sys_init // system inits function 
.global g_pfnVectors // vector table
.global default_handler // default interrupt handler

.word _sidata // start address in FLASH of .data
.word _sdata  // start address in RAM of .data
.word _edata  // end address in RAM of .data
.word _sbss   // start address of .bss in RAM
.word _ebss   // end address of .bss in RAM

/**
*  reset handler (entry point)
*/
.section .text.reset_handler, "ax", %progbits
.global reset_handler
.type reset_handler, %function

reset_handler:
  LDR sp, =_estack

  // SYSTEM INIT
  BL sys_init
  
  // Initialize .data section
  LDR r0, =_sidata
  LDR r1, =_sdata
  LDR r2, =_edata

copy_data: // copy .data section from flash to RAM
  CMP r1, r2
  BEQ zero_bss
  LDR r3, [r0], #4
  STR r3, [r1], #4
  B copy_data

zero_bss: // zero out .bss section
  LDR r3, =_sbss
  LDR r4, =_ebss
  MOV r5, #0x0

zero_bss_loop:
  CMP r3, r4
  BEQ main_program
  STR r5, [r3], #4
  ADD r3, r3, #4
  B zero_bss_loop

main_program:
  // Jump to main firmware entry point
  BL _start

.size reset_handler, .-reset_handler

/**
*   default reset handler
*/
.section .text.default_handler, "ax", %progbits

default_handler:
  B default_handler

.size default_handler, .-default_handler


/**
* interrupt vector table
*/
   .section  .isr_vector, "a", %progbits
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
  .word     WWDG_IRQHandler                   /* Window WatchDog              */                                        
  .word     PVD_IRQHandler                    /* PVD through EXTI Line detection */                        
  .word     TAMP_STAMP_IRQHandler             /* Tamper and TimeStamps through the EXTI line */            
  .word     RTC_WKUP_IRQHandler               /* RTC Wakeup through the EXTI line */                      
  .word     FLASH_IRQHandler                  /* FLASH                        */                                          
  .word     RCC_IRQHandler                    /* RCC                          */                                            
  .word     EXTI0_IRQHandler                  /* EXTI Line0                   */                        
  .word     EXTI1_IRQHandler                  /* EXTI Line1                   */                          
  .word     EXTI2_IRQHandler                  /* EXTI Line2                   */                          
  .word     EXTI3_IRQHandler                  /* EXTI Line3                   */                          
  .word     EXTI4_IRQHandler                  /* EXTI Line4                   */                          
  .word     DMA1_Stream0_IRQHandler           /* DMA1 Stream 0                */                  
  .word     DMA1_Stream1_IRQHandler           /* DMA1 Stream 1                */                   
  .word     DMA1_Stream2_IRQHandler           /* DMA1 Stream 2                */                   
  .word     DMA1_Stream3_IRQHandler           /* DMA1 Stream 3                */                   
  .word     DMA1_Stream4_IRQHandler           /* DMA1 Stream 4                */                   
  .word     DMA1_Stream5_IRQHandler           /* DMA1 Stream 5                */                   
  .word     DMA1_Stream6_IRQHandler           /* DMA1 Stream 6                */                   
  .word     ADC_IRQHandler                    /* ADC1, ADC2 and ADC3s         */                   
  .word     0               				  /* Reserved                      */                         
  .word     0              					  /* Reserved                     */                          
  .word     0                                 /* Reserved                     */                          
  .word     0                                 /* Reserved                     */                          
  .word     EXTI9_5_IRQHandler                /* External Line[9:5]s          */                          
  .word     TIM1_BRK_TIM9_IRQHandler          /* TIM1 Break and TIM9          */         
  .word     TIM1_UP_TIM10_IRQHandler          /* TIM1 Update and TIM10        */         
  .word     TIM1_TRG_COM_TIM11_IRQHandler     /* TIM1 Trigger and Commutation and TIM11 */
  .word     TIM1_CC_IRQHandler                /* TIM1 Capture Compare         */                          
  .word     TIM2_IRQHandler                   /* TIM2                         */                   
  .word     TIM3_IRQHandler                   /* TIM3                         */                   
  .word     TIM4_IRQHandler                   /* TIM4                         */                   
  .word     I2C1_EV_IRQHandler                /* I2C1 Event                   */                          
  .word     I2C1_ER_IRQHandler                /* I2C1 Error                   */                          
  .word     I2C2_EV_IRQHandler                /* I2C2 Event                   */                          
  .word     I2C2_ER_IRQHandler                /* I2C2 Error                   */                            
  .word     SPI1_IRQHandler                   /* SPI1                         */                   
  .word     SPI2_IRQHandler                   /* SPI2                         */                   
  .word     USART1_IRQHandler                 /* USART1                       */                   
  .word     USART2_IRQHandler                 /* USART2                       */                   
  .word     0               				  /* Reserved                       */                   
  .word     EXTI15_10_IRQHandler              /* External Line[15:10]s        */                          
  .word     RTC_Alarm_IRQHandler              /* RTC Alarm (A and B) through EXTI Line */                 
  .word     OTG_FS_WKUP_IRQHandler            /* USB OTG FS Wakeup through EXTI line */                       
  .word     0                                 /* Reserved     				  */         
  .word     0                                 /* Reserved       			  */         
  .word     0                                 /* Reserved 					  */
  .word     0                                 /* Reserved                     */                          
  .word     DMA1_Stream7_IRQHandler           /* DMA1 Stream7                 */                          
  .word     0                                 /* Reserved                     */                   
  .word     SDIO_IRQHandler                   /* SDIO                         */                   
  .word     TIM5_IRQHandler                   /* TIM5                         */                   
  .word     SPI3_IRQHandler                   /* SPI3                         */                   
  .word     0                                 /* Reserved                     */                   
  .word     0                                 /* Reserved                     */                   
  .word     0                                 /* Reserved                     */                   
  .word     0                                 /* Reserved                     */
  .word     DMA2_Stream0_IRQHandler           /* DMA2 Stream 0                */                   
  .word     DMA2_Stream1_IRQHandler           /* DMA2 Stream 1                */                   
  .word     DMA2_Stream2_IRQHandler           /* DMA2 Stream 2                */                   
  .word     DMA2_Stream3_IRQHandler           /* DMA2 Stream 3                */                   
  .word     DMA2_Stream4_IRQHandler           /* DMA2 Stream 4                */                   
  .word     0                    			  /* Reserved                     */                   
  .word     0              					  /* Reserved                     */                     
  .word     0              					  /* Reserved                     */                          
  .word     0             					  /* Reserved                     */                          
  .word     0              					  /* Reserved                     */                          
  .word     0              					  /* Reserved                     */                          
  .word     OTG_FS_IRQHandler                 /* USB OTG FS                   */                   
  .word     DMA2_Stream5_IRQHandler           /* DMA2 Stream 5                */                   
  .word     DMA2_Stream6_IRQHandler           /* DMA2 Stream 6                */                   
  .word     DMA2_Stream7_IRQHandler           /* DMA2 Stream 7                */                   
  .word     USART6_IRQHandler                 /* USART6                       */                    
  .word     I2C3_EV_IRQHandler                /* I2C3 event                   */                          
  .word     I2C3_ER_IRQHandler                /* I2C3 error                   */                          
  .word     0                                 /* Reserved                     */                   
  .word     0                                 /* Reserved                     */                   
  .word     0                                 /* Reserved                     */                         
  .word     0                                 /* Reserved                     */                   
  .word     0                                 /* Reserved                     */                   
  .word     0                                 /* Reserved                     */                   
  .word     0                                 /* Reserved                     */
  .word     FPU_IRQHandler                    /* FPU                          */
  .word     0                                 /* Reserved                     */                   
  .word     0                                 /* Reserved                     */
  .word     SPI4_IRQHandler                   /* SPI4                         */     
                    

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
  .thumb_set SysTick_Handler,default_handler              

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
