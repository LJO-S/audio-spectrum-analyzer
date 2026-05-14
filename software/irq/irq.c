/********************************************************************************************
 * Setup interrupt controllers & handles
 *******************************************************************************************/

/***************************** Include Files **********************************/
#include "irq.h"
#include "xparameters.h"
#include "xgpio.h"
#include "xscugic.h"
#include "xil_exception.h"
#include "xil_types.h"
#include "xil_printf.h"

/************************** Constant Definitions ******************************/
#define GPIO_IN_DEVICE_ID XPAR_GPIO_1_DEVICE_ID
#define INTC_DEVICE_ID XPAR_PS7_SCUGIC_0_DEVICE_ID
#define INTC_GPIO_INTERRUPT_ID XPAR_FABRIC_AXI_GPIO_1_IP2INTC_IRPT_INTR

#define GPIO_OUT_DEVICE_ID XPAR_GPIO_3_DEVICE_ID

#define GPIO_INT_CH_MASK XGPIO_IR_CH1_MASK
#define GPIO_INPUT_MASK 0xF

/************************** Variable Definitions ******************************/
// - volatile hinders the compiler from optimizing the variable away
// - static contains the variable to the current file
volatile u32 event_flags = 0;
static XGpio GpioIn, GpioOut;
static XScuGic Intc;

/******************************************************************************/
/**
 *
 * GPIO Interrupt Service Routine.
 * Reads gpio register, clears interrupt and sets global variable.
 *
 *
 * @return	None
 *
 *
 */
static void gpio_isr(void *InstancePtr)
{
    // 1) Disable interrupt for GPIO that will be serviced now
    XGpio_InterruptDisable(&GpioIn, GPIO_INT_CH_MASK);

    uint32_t status = XGpio_InterruptGetStatus(&GpioIn);
    if ((status & GPIO_INT_CH_MASK) != GPIO_INT_CH_MASK)
    {
        xil_printf("Interrupt triggered, but wrong channel!\n");
        XGpio_InterruptEnable(&GpioIn, GPIO_INT_CH_MASK);
        return;
    }

    // Read lower 4-bits (1 bit for each btn)
    uint32_t data = XGpio_DiscreteRead(&GpioIn, 1) & GPIO_INPUT_MASK;

    // 2) Send request ACK to PL
    XGpio_DiscreteWrite(&GpioOut, 1, 0x1);
    (void)XGpio_DiscreteRead(&GpioOut, 1);
    XGpio_DiscreteWrite(&GpioOut, 1, 0);

    // 3) Clear channel interrupt & ACK
    (void)XGpio_InterruptClear(&GpioIn, GPIO_INT_CH_MASK);

    // 4) Set flags for main to handle
    if (data == 0)
    {
        // Nothing to do, clear interrupt
        xil_printf("Interrupt triggered, but empty trigger!\n");
        XGpio_InterruptEnable(&GpioIn, GPIO_INT_CH_MASK);
        return;
    }
    else
    {
        event_flags |= data;
    }
}
/******************************************************************************/
/**
 *
 * Reenable GPIO interrupts
 *
 *
 * @return	XST_SUCCESS if successful, XST_FAILURE if unsuccessful.
 *
 *
 */
int fir_interrupt_reenable(void)
{
    XGpio_InterruptEnable(&GpioIn, GPIO_INT_CH_MASK);
    return XST_SUCCESS;
}
/******************************************************************************/
/**
 *
 * Setup interrupt requests.
 *
 *
 * @return	XST_SUCCESS if successful, XST_FAILURE if unsuccessful.
 *
 *
 */
int irq_init(void)
{
    int status;

    // Initialize GpioOut
    status = XGpio_Initialize(&GpioOut, GPIO_OUT_DEVICE_ID);
    if (status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }
    XGpio_SetDataDirection(&GpioOut, 1, 0x00); // ACK signal

    // Initialize GpioIn
    status = XGpio_Initialize(&GpioIn, GPIO_IN_DEVICE_ID);
    if (status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }
    XGpio_SetDataDirection(&GpioIn, 1, 0xF); // FIR CTRL signal

    // Initialize GIC
    XScuGic_Config *intc_cfg = XScuGic_LookupConfig(INTC_DEVICE_ID);
    status = XScuGic_CfgInitialize(&Intc, intc_cfg, intc_cfg->CpuBaseAddress);
    if (status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    // Register handler for SCU GIC
    Xil_ExceptionInit(); // not really needed, is legacy
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
                                 (Xil_ExceptionHandler)XScuGic_InterruptHandler,
                                 &Intc);
    Xil_ExceptionEnable();

    // Connect GPIO interrupt to handler
    // XScuGic_Connect(&Intc, INTC_GPIO_INTERRUPT_ID, (Xil_ExceptionHandler)gpio_isr, (void *)&GpioIn);
    status = XScuGic_Connect(&Intc,
                             INTC_GPIO_INTERRUPT_ID,
                             (Xil_ExceptionHandler)gpio_isr,
                             (void *)&GpioIn);
    if (status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    // Enable everything
    XGpio_InterruptEnable(&GpioIn, GPIO_INT_CH_MASK);
    XGpio_InterruptGlobalEnable(&GpioIn);
    XScuGic_Enable(&Intc, INTC_GPIO_INTERRUPT_ID);

    return XST_SUCCESS;
}
/******************************************************************************/