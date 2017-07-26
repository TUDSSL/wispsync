#include <in430.h>
#include <inttypes.h>
#include <msp430.h>
#include <stdint.h>
#include <stdlib.h>

/* to compile
  msp430-gcc -lm -mmcu=msp430fr5969 wisp-sync.c
*/

#define port_init(port, bit)                                                   \
  P##port##DIR |= BIT##bit;                                                    \
  P##port##OUT &= ~BIT##bit;

#define port_on(port, bit) P##port##OUT |= BIT##bit;
#define port_off(port, bit) P##port##OUT &= ~BIT##bit;
#define port_toggle(port, bit) P##port##OUT ^= BIT##bit;

#define LED1 BIT6
#define LED1_OUT P4OUT
#define LED1_DIR P4DIR

#define LED2 BIT0
#define LED2_OUT P1OUT
#define LED2_DIR P1DIR

/* Macros for easy access to the LEDs on the evaulation board. */
#define led_init(led)                                                          \
  led##_DIR |= led;                                                            \
  led##_OUT &= ~led;

#define led_on(led) led##_OUT |= led;
#define led_off(led) led##_OUT &= ~led;
#define led_toggle(led) led##_OUT ^= led;

#define SECOND 31250
#define beta 0.0001f
#define tau 1.0f

__attribute__((section(".infoA"))) float f_w = 0.0f;

uint8_t even = 0;
uint16_t t_f;

void wisp_sync(uint16_t c_w) {
  float error = (float)c_w - ((float)t_f + tau * (1.0f + f_w));
  f_w += beta * error;
}

int main() {
  WDTCTL = WDTPW | WDTHOLD; // Stop watchdog timer
  PM5CTL0 &= ~LOCKLPM5; // Disable the GPIO power-on default high-impedance mode

  // Disable FRAM wait cycles to allow clock operation over 8MHz
  FRCTL0 = 0xA500 | ((1) << 4); // FRCTLPW | NWAITS_1;
  __delay_cycles(3);

  /* init FRAM */
  FRCTL0_H |= (FWPW) >> 8;
  __delay_cycles(3);

  /* stop timer */
  TA2CCTL0 = 0x00;
  TA2CTL = 0;
  led_init(LED1);
  port_init(1, 5);

  /* start timer */
  TA2CCR0 = SECOND; // Take current count + desired count
  TA2CCTL0 = CCIE;  // Enable Interrupts on Comparator register
  TA2CTL = TASSEL__ACLK | MC__UP | TACLR; // start timer

  __enable_interrupt();

  while (1)
    ;
}

/* the timer interrupt handler */
__attribute__((interrupt(TIMER2_A0_VECTOR))) void timer_isr() {
  /* stop timer */
  TA2CCTL0 = 0x00;
  TA2CTL = 0;
  led_toggle(LED1);

  if (even) {
    port_toggle(1, 5);
    wisp_sync(TA2CCR0);
    port_toggle(1, 5);
    even = 0;
  } else {
    t_f = TA2CCR0;
    even++;
  }

  /* start timer again */
  TA2CCR0 += SECOND; // Take current count + desired count
  TA2CCTL0 = CCIE;   // Enable Interrupts on Comparator register
  TA2CTL = TASSEL__ACLK | MC__UP | TACLR; // start timer
}
