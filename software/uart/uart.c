/********************************************************************************************
 * Setup UART for comms
 *******************************************************************************************/

/***************************** Include Files **********************************/
#include "uart.h"
#include "xparameters.h"
#include "xuartps.h"
#include "xgpio.h"
#include <string.h>
#include <stdarg.h>
#include <stdio.h>

/************************** Constant Definitions ******************************/
#define UART_DEVICE_ID XPAR_XUARTPS_0_DEVICE_ID
#define LINE_MAX 64
#define BAUD_RATE 115200

#define GPIO_OUT_DEVICE_ID XPAR_GPIO_5_DEVICE_ID

/************************** Variable Definitions ******************************/
static XUartPs Uart;
static char line_buf[LINE_MAX];
static size_t line_len = 0;
static XGpio GpioOut;

/******************************************************************************/
/**
 *
 * UART init
 * Sets up UART
 *
 *
 * @return	Status
 *
 *
 */
int uart_init(void)
{
    /* ----------- UART ------------ */

    // Lookup configuration
    XUartPs_Config *cfg = XUartPs_LookupConfig(UART_DEVICE_ID);
    if (cfg == NULL)
        return XST_FAILURE;

    // Initialize
    int status = XUartPs_CfgInitialize(&Uart, cfg, cfg->BaseAddress);
    if (status != XST_SUCCESS)
        return XST_FAILURE;

    // Set baud rate
    status = XUartPs_SetBaudRate(&Uart, BAUD_RATE);
    if (status != XST_SUCCESS)
        return XST_FAILURE;

    XUartPs_SetOperMode(&Uart, XUARTPS_OPER_MODE_NORMAL);

    /* ----------- GPIO ------------ */
    // Initialize GpioOut
    status = XGpio_Initialize(&GpioOut, GPIO_OUT_DEVICE_ID);
    if (status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }
    XGpio_SetDataDirection(&GpioOut, 1, 0x00000000);

    return XST_SUCCESS;
}

/******************************************************************************/
/**
 *
 * UART poll line
 *
 * Polls the UART line. Fills it when less than max buffer size. Drains it on detection
 * of newline.
 *
 *
 * @return	Status
 *
 *
 */
int uart_poll_line(char **a_line_out)
{
    u8 c;
    // Drain the FIFO
    while (XUartPs_Recv(&Uart, &c, 1) == 1)
    {
        if ((c == '\r') || (c == '\n'))
        {

            // Ignore empty lines
            if (line_len == 0)
            {
                continue;
            }
            // Buffer done
            line_buf[line_len] = '\0';
            *a_line_out = line_buf;
            line_len = 0;
            uart_print("\r\n");
            return 1;
        }
        else if ((c == '\x7f') || (c == '\x08'))
        {
            if (line_len > 0)
            {
                line_len--;
                uart_print("\x08 \x08");
            }
            continue;
        }
        if (line_len < LINE_MAX - 1)
        {
            line_buf[line_len++] = (char)c;
            XUartPs_Send(&Uart, &c, 1); // echo back to terminal
        }
    }
    return 0;
}

/******************************************************************************/
/**
 *
 * UART print
 *
 * Replaces xil_print()
 *
 *
 * @return	Status
 *
 *
 */
void uart_print(const char *s)
{
    size_t len = strlen(s);
    XUartPs_Send(&Uart, (u8 *)s, len);
}

/******************************************************************************/
/**
 *
 * UART printf
 *
 * Replaces xil_printf()
 *
 * @return	Status
 *
 *
 */
void uart_printf(const char *fmt, ...)
{
    char buf[128];
    va_list args;
    va_start(args, fmt);
    vsnprintf(buf, sizeof(buf), fmt, args);
    va_end(args);
    uart_print(buf);
}

/******************************************************************************/
/**
 *
 * UART set oscilloscope
 *
 * Set oscilloscope
 *
 * @return	Status
 *
 *
 */
void uart_set_osc(int on)
{
    XGpio_DiscreteWrite(&GpioOut, 1, on ? 0x1 : 0x0);
}