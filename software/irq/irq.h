#ifndef IRQ_H
#define IRQ_H

#include <stdint.h>

int irq_init(void);
int fir_interrupt_reenable(void);
extern volatile uint32_t event_flags;

#endif // IRQ_H