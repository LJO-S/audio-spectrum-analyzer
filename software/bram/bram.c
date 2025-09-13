/********************************************************************************************
 * Setup interrupt controllers & handles
 *******************************************************************************************/

/***************************** Include Files **********************************/
#include "bram.h"
#include "xparameters.h"
#include "fir_coeffs.h"
// #include "xil_types.h"
#include "xil_cache.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xgpio.h"
#include "sleep.h"
#include <stddef.h>
/************************** Constant Definitions ******************************/
#define GPIO_LPF_STROBE XPAR_GPIO_2_DEVICE_ID
#define GPIO_HPF_STROBE XPAR_GPIO_4_DEVICE_ID

static XGpio LPFStrobe, HPFStrobe;

/************************** Variable Definitions ******************************/

/******************************************************************************/
/**
 *
 *
 * Write down coefficients to PL BRAM
 *
 * @return	XST_SUCCESS if successful, XST_FAILURE if unsuccessful.
 *
 *
 */
int bram_write_coeffs(uint32_t bram_base_addr,
                      const uint32_t *coeffs,
                      size_t n_taps)
{

    // 1) Sanity check
    if (!coeffs || n_taps == 0)
    {
        xil_printf("Empty coefficients or 0 taps specified!\n");
        return XST_FAILURE;
    }

    // 2) Write down coefficients
    for (uint32_t i = 0; i < n_taps; i++)
    {
        Xil_Out32((UINTPTR)bram_base_addr + i * 4, coeffs[i]);
    }

    // 3) Flush the written range
    Xil_DCacheFlushRange((UINTPTR)bram_base_addr, n_taps * sizeof(uint32_t));

    return XST_SUCCESS;
}
/******************************************************************************/
/**
 *
 *
 * Write down LPF coefficients to BRAM
 *
 * @return	XST_SUCCESS if successful, XST_FAILURE if unsuccessful.
 *
 *
 */
int bram_write_coeffs_lpf(const uint32_t *coeffs, size_t n_taps)
{
    // 1) Write down coefficients
    int status = bram_write_coeffs(BRAM_LPF_BASEADDR, coeffs, n_taps);
    if (status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }
    // 2) Signal filter that new data is available
    XGpio_DiscreteWrite(&LPFStrobe, 1, 0x1);
    (void) XGpio_DiscreteRead(&LPFStrobe, 1);
    XGpio_DiscreteWrite(&LPFStrobe, 1, 0x0);
    return XST_SUCCESS;
}
/******************************************************************************/
/**
 *
 *
 * Write down HPF coefficients to BRAM
 *
 * @return	XST_SUCCESS if successful, XST_FAILURE if unsuccessful.
 *
 *
 */
int bram_write_coeffs_hpf(const uint32_t *coeffs, size_t n_taps)
{
    // 1) Write down coefficients
    int status = bram_write_coeffs(BRAM_HPF_BASEADDR, coeffs, n_taps);
    if (status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }
    // 2) Signal filter that new data is available
    XGpio_DiscreteWrite(&HPFStrobe, 1, 0x1);
    (void) XGpio_DiscreteRead(&HPFStrobe, 1);
    XGpio_DiscreteWrite(&HPFStrobe, 1, 0x0);
    return XST_SUCCESS;
}
/******************************************************************************/
/**
 *
 *
 * Initialize BRAM by storing default FIR 10 kHz cutoff values for both filters.
 *
 * @return	XST_SUCCESS if successful, XST_FAILURE if unsuccessful.
 *
 *
 */
int bram_init(void)
{
    size_t index = 9; // cutoff 10khz
    int status;

    // 1A) Initialize LPF data strobe
    status = XGpio_Initialize(&LPFStrobe, GPIO_LPF_STROBE);
    if (status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }
    XGpio_SetDataDirection(&LPFStrobe, 1, 0x00);
    XGpio_DiscreteWrite(&LPFStrobe, 1, 0x0);

    // 1B) Initialize HPF data strobe
    status = XGpio_Initialize(&HPFStrobe, GPIO_HPF_STROBE);
    if (status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }
    XGpio_SetDataDirection(&HPFStrobe, 1, 0x00);
    XGpio_DiscreteWrite(&HPFStrobe, 1, 0x0);

    // 2) Write down LPF coefficients
    status = bram_write_coeffs_lpf(lpf_coeffs[index], LPF_LEN);
    if (status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    // 3) Write down HPF coefficients
    status = bram_write_coeffs_hpf(hpf_coeffs[index], HPF_LEN);
    if (status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    return XST_SUCCESS;
}
