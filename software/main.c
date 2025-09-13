/*******************************************************************************
 * Main
/***************************** Include Files **********************************/
// Own
#include "irq.h"
#include "bram.h"
#include "i2c.h"
#include "fir_coeffs.h"
// Xilinx
#include "xparameters.h"
#include "xgpio.h"
#include "xscugic.h"
#include "xil_exception.h"
#include "xil_types.h"
#include "xil_printf.h"

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
                size_t index = (size_t)(current_hpf_cutoff - 1);
                if (index < HPF_SETS)
                {
                    status = bram_write_coeffs_hpf(hpf_coeffs[index], HPF_LEN);
                    xil_printf("HPF coeffs written: %u kHz\n", current_hpf_cutoff);
                }
                else
                {
                    xil_printf("HPF index OOB: %u\n", (unsigned)index);
                    status = XST_FAILURE;
                }
            }
            else
            {
                xil_printf("HPF at max: %u\n", current_hpf_cutoff);
            }
        }
        else if (b == 2)
        {
            // HPF decrement
            if (current_hpf_cutoff > MIN_CUTOFF_FREQ_KHZ)
            {
                current_hpf_cutoff--;
                size_t index = (size_t)(current_hpf_cutoff - 1);
                if (index < HPF_SETS)
                {
                    status = bram_write_coeffs_hpf(hpf_coeffs[index], HPF_LEN);
                    xil_printf("HPF coeffs written: %u kHz\n", current_hpf_cutoff);
                }
                else
                {
                    xil_printf("HPF index OOB: %u\n", (unsigned)index);
                    status = XST_FAILURE;
                }
            }
            else
            {
                xil_printf("HPF at min: %u\n", current_hpf_cutoff);
            }
        }
        else if (b == 1)
        {
            // LPF increment
            if (current_lpf_cutoff < MAX_CUTOFF_FREQ_KHZ)
            {
                current_lpf_cutoff++;
                size_t index = (size_t)(current_lpf_cutoff - 1);
                if (index < LPF_SETS)
                {
                    status = bram_write_coeffs_lpf(lpf_coeffs[index], LPF_LEN);
                    xil_printf("LPF coeffs written: %u kHz\n", current_lpf_cutoff);
                }
                else
                {
                    xil_printf("LPF index OOB: %u\n", (unsigned)index);
                    status = XST_FAILURE;
                }
            }
            else
            {
                xil_printf("LPF at max: %u\n", current_lpf_cutoff);
            }
        }
        else if (b == 0)
        {
            // LPF decrement
            if (current_lpf_cutoff > MIN_CUTOFF_FREQ_KHZ)
            {
                current_lpf_cutoff--;
                size_t index = (size_t)(current_lpf_cutoff - 1);
                if (index < LPF_SETS)
                {
                    status = bram_write_coeffs_lpf(lpf_coeffs[index], LPF_LEN);
                    xil_printf("LPF coeffs written: %u kHz\n", current_lpf_cutoff);
                }
                else
                {
                    xil_printf("LPF index OOB: %u\n", (unsigned)index);
                    status = XST_FAILURE;
                }
            }
            else
            {
                xil_printf("LPF at min: &u\n", current_lpf_cutoff);
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
        xil_printf("-- Fail! I2C codec setup --\n");
        return XST_FAILURE;
    }

    // 2) FIR Coeff BRAM init
    status = bram_init();
    if (status != XST_SUCCESS)
    {
        xil_printf("-- Fail! BRAM setup --\n");
        return XST_FAILURE;
    }

    // 3) Setup IRQ
    status = irq_init();
    if (status != XST_SUCCESS)
    {
        xil_printf("-- Fail! IRQ setup --\n");
        return XST_FAILURE;
    }

    // 4) Start polling....

    while (1)
    {
        if (event_flags)
        {
            status = service_event();
            if (status != XST_SUCCESS)
            {
                xil_printf("-- Fail! Service Event Poll --");
                return XST_FAILURE;
            }
        }
    }
    return XST_SUCCESS;
}
/******************************************************************************/