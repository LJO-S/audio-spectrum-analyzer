/*******************************************************************************
 * Main
/***************************** Include Files **********************************/
// Own
#include "irq.h"
#include "bram.h"
#include "i2c.h"
// Xilinx
#include "xparameters.h"
#include "xgpio.h"
#include "xscugic.h"
#include "xil_exception.h"
#include "xil_types.h"
#include "xil_printf.h"

/************************** Constant Definitions ******************************/


/************************** Variable Definitions ******************************/


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
    
    // Setup Audio Codec over I2C
    status = IicInitialize();
    if (status != XST_SUCCESS)
    {
        xil_printf("-- Fail! I2C codec setup --\n");
        return XST_FAILURE;
    }

    // FIR Coeff BRAM init
    status = bram_init();
    if (status != XST_SUCCESS)
    {
        xil_printf("-- Fail! BRAM setup --\n");
        return XST_FAILURE;
    }

    // Setup IRQ
    status = irq_init();
    if (status != XST_SUCCESS)
    {
        xil_printf("-- Fail! IRQ setup --\n");
        return XST_FAILURE;
    }

    // Start polling....

    // After handling event_flags, REENABLE INTERRUPT


    
}
/******************************************************************************/