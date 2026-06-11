/*******************************************************************************
 * Main
/***************************** Include Files **********************************/
// Standard
#include <stdio.h>
#include <string.h>
// Own
#include "irq.h"
#include "bram.h"
#include "i2c.h"
#include "fir_coeffs.h"
#include "uart.h"
// Xilinx
#include "xparameters.h"
#include "xgpio.h"
#include "xscugic.h"
#include "xil_exception.h"
#include "xil_types.h"
#include "xil_printf.h" // used for pre-uart-init error messages only
#include "sleep.h"

/************************** Constant Definitions ******************************/

/************************** Variable Definitions ******************************/
extern volatile uint32_t event_flags;
static uint32_t current_hpf_cutoff = 10;
static uint32_t current_lpf_cutoff = 10;
/******************************************************************************/
/**
 *
 * ISR Service.
 *
 * @return	None
 *
 *
 */
int service_event(void)
{
    // Service each bit independently
    // (Bit 3 = HPF++)
    // (Bit 2 = HPF--)
    // (Bit 1 = LPF++)
    // (Bit 0 = LPF--)

    // Procedure:
    // 0. Check if within F_co limits
    // 1. Incr/decr F_co
    // 2. Update index
    // 3. Fetch coeffs using index
    // 4. Write coeffs to BRAM
    // 5. Re-enable interrupts

    int overall_status = XST_SUCCESS;

    // Snapshot 'event_flags' and clear
    uint32_t flags = event_flags;
    event_flags = 0;

    for (int b = 0; b < 4; b++)
    {
        uint32_t mask = (1u << b);
        if (!(flags & mask))
        {
            continue;
        }

        int status = XST_SUCCESS;

        // Compute which set and call BRAM writer
        if (b == 3)
        {
            // HPF increment
            if (current_hpf_cutoff < MAX_CUTOFF_FREQ_KHZ)
            {
                current_hpf_cutoff++;
            }
            else
            {
                uart_print("HPF at max!\r\n");
            }
            size_t index = (size_t)(current_hpf_cutoff - 1);
            if (index < HPF_SETS)
            {
                status = bram_write_coeffs_hpf(hpf_coeffs[index], HPF_LEN);
            }
            else
            {
                uart_printf("HPF index OOB: %u\r\n", (unsigned)index);
                status = XST_FAILURE;
            }
        }

        else if (b == 2)
        {
            // HPF decrement
            if (current_hpf_cutoff > MIN_CUTOFF_FREQ_KHZ)
            {
                current_hpf_cutoff--;
            }
            else
            {
                uart_print("HPF at min!\r\n");
            }
            size_t index = (size_t)(current_hpf_cutoff - 1);
            if (index < HPF_SETS)
            {
                status = bram_write_coeffs_hpf(hpf_coeffs[index], HPF_LEN);
            }
            else
            {
                uart_printf("HPF index OOB: %u\r\n", (unsigned)index);
                status = XST_FAILURE;
            }
        }

        else if (b == 1)
        {
            // LPF increment
            if (current_lpf_cutoff < MAX_CUTOFF_FREQ_KHZ)
            {
                current_lpf_cutoff++;
            }
            else
            {
                uart_print("LPF at max!\r\n");
            }
            size_t index = (size_t)(current_lpf_cutoff - 1);
            if (index < LPF_SETS)
            {
                status = bram_write_coeffs_lpf(lpf_coeffs[index], LPF_LEN);
            }
            else
            {
                uart_printf("LPF index OOB: %u\r\n", (unsigned)index);
                status = XST_FAILURE;
            }
        }
        else if (b == 0)
        {
            // LPF decrement
            if (current_lpf_cutoff > MIN_CUTOFF_FREQ_KHZ)
            {
                current_lpf_cutoff--;
            }
            else
            {
                uart_print("LPF at min!\r\n");
            }
            size_t index = (size_t)(current_lpf_cutoff - 1);
            if (index < LPF_SETS)
            {
                status = bram_write_coeffs_lpf(lpf_coeffs[index], LPF_LEN);
            }
            else
            {
                uart_printf("LPF index OOB: %u\r\n", (unsigned)index);
                status = XST_FAILURE;
            }
        }

        if (status != XST_SUCCESS && overall_status == XST_SUCCESS)
        {
            overall_status = status;
        }
        // After handling event_flags re-enable interrupts
        fir_interrupt_reenable();
    }
    return overall_status;
}
/******************************************************************************/
/**
 *
 * UART Event
 * 1)
 *
 * @return	None
 *
 *
 */
static int service_uart_line(const char *line)
{
    if (!strcmp(line, "osc on"))
    {
        uart_set_osc(1);
        return XST_SUCCESS;
    }
    if (!strcmp(line, "osc off"))
    {
        uart_set_osc(0);
        return XST_SUCCESS;
    }
    unsigned factor, freq_khz;
    if (sscanf(line, "zoom %u %u", &factor, &freq_khz) == 2)
    {
        if (factor != 0 && factor != 2 && factor != 4)
        {
            uart_print("zoom: factor must be 0, 2, 4 \r\n");
            return XST_SUCCESS;
        }
        if (factor == 0 && freq_khz > 0)
        {
            uart_print("zoom: freq shift requires decimation factor > 0\r\n");
            return XST_SUCCESS;
        }
        if (freq_khz > 24)
        {
            uart_print("zoom: freq must be 0-24 kHz\r\n");
            return XST_SUCCESS;
        }
        uint8_t dec_enc = (factor == 2) ? 0x1 : (factor == 4) ? 0x2
                                                              : 0x0;
        uart_set_zoom(dec_enc, (uint16_t)freq_khz);
        uart_printf("zoom: x%u @ %u kHz\r\n", factor, freq_khz);
        return XST_SUCCESS;
    }
    if (!strcmp(line, "zoom off"))
    {
        uart_set_zoom(0, 0);
        uart_print("zoom: off\r\n");
        return XST_SUCCESS;
    }
    uart_print("?\r\n");
    return XST_SUCCESS;
}
/******************************************************************************/

/**
 *
 * Main.
 * 1) Call on I2C init
 * 2) Setup IRQ etc
 * 3) Start infinite poll loop waiting for GPIO interrupt
 *
 * @return	None
 *
 *
 */
int main(void)
{
    int status;

    // 1) Setup Audio Codec over I2C
    status = iic_init();
    if (status != XST_SUCCESS)
    {
        xil_printf("-- Fail! I2C codec setup --\r\n");
        return XST_FAILURE;
    }

    // 2) FIR Coeff BRAM init
    status = bram_init();
    if (status != XST_SUCCESS)
    {
        xil_printf("-- Fail! BRAM setup --\r\n");
        return XST_FAILURE;
    }

    // 3) Setup IRQ
    status = irq_init();
    if (status != XST_SUCCESS)
    {
        xil_printf("-- Fail! IRQ setup --\r\n");
        return XST_FAILURE;
    }

    // 4) Setup UART
    status = uart_init();
    if (status != XST_SUCCESS)
    {
        xil_printf("-- Fail! UART setup --\r\n");
        return XST_FAILURE;
    }
    // 5) Start polling....
    uart_print("\r\n > ");
    while (1)
    {
        if (event_flags)
        {
            status = service_event();
            if (status != XST_SUCCESS)
            {
                uart_print("-- Fail! Service Event Poll --\r\n");
                return XST_FAILURE;
            }
            uart_print("\r\n > Filter update... ");
            uart_print("\r\n > ");
        }

        char *line;
        if (uart_poll_line(&line))
        {
            service_uart_line(line);
            uart_print(" > ");
        }
    }
    return XST_SUCCESS;
}
/******************************************************************************/