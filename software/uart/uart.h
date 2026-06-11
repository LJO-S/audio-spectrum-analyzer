#ifndef UART_H
#define UART_H
#include <stdint.h>
#include <stddef.h>

int uart_init(void);
int uart_poll_line(char **a_line_out);
void uart_print(const char *s);
void uart_printf(const char *fmt, ...);
void uart_set_osc(int on);
void uart_set_zoom(uint8_t a_dec_enc, uint16_t a_freq_khz);

#endif