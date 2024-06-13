#include "../STM32F401RE.h"

#define LED_PIN     5U
#define DELAY_US    1000000UL // delay in microseconds

static volatile unsigned long int *p_portA = (unsigned long *)ADDR_GPIOA;
static volatile unsigned long int *rcc_ahb1enr = (unsigned long *)RCC_AHB1ENR;

static inline void delay(unsigned long int u_seconds)
{
  // Number of cycles for 1 microsecond delay
  const unsigned int cycles_per_us = 84U;
  // Calculate total cycles to delay
  unsigned int total_cycles = u_seconds * cycles_per_us;
  __asm__ volatile (
    "1: subs %[total_cycles], %[total_cycles], #1\n"
    "   bne 1b\n"
    : [total_cycles] "+r" (total_cycles)
    :
    : "cc"
  );
}

int main(int argc, char const **argv)
{
  // Enable the clock for GPIOA
  *rcc_ahb1enr |= (1 << 0);

  // Configure the LED_PIN (PA5) as output
  GPIO_SET_OUTPUT(p_portA, LED_PIN);
  GPIO_SET_PUSH_PULL(p_portA, LED_PIN);
  GPIO_SET_LOW_SPEED(p_portA, LED_PIN);
  GPIO_SET_PULL_UP_DOWN_NONE(p_portA, LED_PIN);

  for (;;)
  {
    // Set PA5 high
    *(p_portA + GPIO_OFFSET_ODR) |= (1 << LED_PIN);
    delay(DELAY_US); 
    
    // Set PA5 low
    *(p_portA + GPIO_OFFSET_ODR) &= ~(1 << LED_PIN);
    delay(DELAY_US);
  }

  return 0;
}
