/*
 Author: Amjad Yousef Majid
 Date: 06/feb/2017
*/
#include <msp430.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

#include <libmsp/clock.h>
#include <libmsp/gpio.h>
#include <libmsp/periph.h>
#include <libmsp/watchdog.h>

#ifdef CONFIG_EDB
#include <libedb/edb.h>
#endif

#ifdef TEST_EIF_PRINTF
#include <libio/printf.h>
#endif // TEST_EIF_PRINTF

#include "pins.h"

#include <stdint.h>

#define SECOND 31250
#define beta 0.0001f
#define tau 1.0f

_attribute_((section(".infoA"))) float f_w = 0.0f;

uint16_t t_f = 0;

void wisp_sync(uint16_t c_w) {
  float error = (float)c_w - ((float)t_f + tau * (1.0f + f_w));
  f_w += beta * error;
}

static void init_hw() {
  msp_watchdog_disable();
  msp_gpio_unlock();
  msp_clock_setup();
}

int main() {
  init_hw();
#ifdef CONFIG_EDB
  edb_init();
#endif

  uint16_t i;
  WATCHPOINT(0);
  for (i = 0; i < 10; i++) {
    wisp_sync(i);
  }
  WATCHPOINT(1);

  return 0;
}
