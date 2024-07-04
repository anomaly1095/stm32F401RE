#include "../../../include/types.h"

/**************************************************************************************
 *                               EXTI interrupts 
 *************************************************************************************/

extern void _mask_unmask_exti(uint8_t EXTI_num, uint8_t mask, uint8_t new_state);

void mask_unmask_exti(uint8_t EXTI_num, uint8_t mask, uint8_t new_state)
{
  // Save registers r0-r3, r14 (lr) onto the stack
  __asm__ volatile (
    "PUSH {r0-r3, r14} \n\t"
  );

  // Call the assembly function
  _mask_unmask_exti(EXTI_num, mask, new_state);

  // Restore registers r0-r3, r14 (lr) from the stack
  __asm__ volatile (
    "POP {r0-r3, r14} \n\t"
  );
}
