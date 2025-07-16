/*
 * Settings up Audio Codec using I2C PS Peripheral.
 * Verify on some kind of read functionality? The codec should have some sort of readback no?
 */

/***************************** Include Files **********************************/
#include <stdio.h>
#include "xil_printf.h"
#include "xil_types.h"
#include "xil_cache.h"
#include "xparameters.h"
#include "xiicps.h"
/************************** Constant Definitions ******************************/
#define IIC_DEVICE_ID XPAR_PS7_I2C_0_DEVICE_ID

/* The slave address is specified in the data-sheet to be 0x1A or 0x1B, depending
 * on if the CSB is '0' or '1', respectively. Looking at the Zybo Z7-10 PCB schematic,
 * we find CSB to be hard-wired to GND.
 */
#define IIC_SLAVE_ADDR 0x1A

/* The audio codec has a max of 526 kHz, so we can safely choose 100 kHz.
 * Another common frequency is fast mode, in 400 kHz.
 */
#define IIC_SCLK_RATE 100000

/************************** Function Prototypes *******************************/
int IicPsAudioCodecSetup(u16 DeviceId);

/************************** Variable Definitions ******************************/
XIicPs iic; /* i2c device */
/*
 * The following buffers are used in this example to send and receive data
 * with the IIC. They are defined as global so that they are not on the stack.
 */
u8 SendBuffer[2]; /* Buffer for Transmitting Data */
u8 RecvBuffer[2]; /* Buffer for Receiving Data */

/*
 * The following counters are used to determine when the entire buffer has
 * been sent and received.
 */
volatile u32 SendComplete;
volatile u32 RecvComplete;
volatile u32 TotalErrorCount;

/******************************************************************************/
/**
 *
 * Main function.
 * Configures the Audio Codec SSM2603.
 *
 *
 * @return	XST_SUCCESS if successful, XST_FAILURE if unsuccessful.
 *
 * @note		None.
 *
 *******************************************************************************/
int main(void)
{
    int status;
    xil_printf("Configuring Audio Codec... \r\n");

    status = IicPsAudioCodecSetup(IIC_DEVICE_ID);
    if (status != XST_SUCCESS)
    {
        xil_printf("IIC Audio Codec configuration failed!\r\n");
        return XST_FAILURE;
    }
    xil_printf("Successfully ran IIC Audio Codec configuration!\r\n");
    return XST_SUCCESS;
}

/******************************************************************************/
/**
 *
 * Configuration function.
 * Sends configurations over to AC (Audio Codec) via I2C.
 *
 *
 * @param	DeviceId is the Device ID of the IicPs Device and is the
 *		XPAR_<IICPS_instance>_DEVICE_ID value from xparameters.h
 *
 * @return   XST_SUCCESS if successful, XST_FAILURE if unsuccessful.
 *
 * @note
 *
 *******************************************************************************/
int IicPsAudioCodecSetup(u16 deviceId)
{
    int status;
    XIicPs_Config *iicConfig;

    /* Look up IIC driver configuration. */
    iicConfig = XIicPs_LookupConfig(DeviceId);
    if (NULL == Config)
    {
        xil_printf("FAILURE: iic lookup\r\n");
        return XST_FAILURE;
    }

    /* Initialize IIC driver. */
    status = XIicPs_CfgInitialize(&iic, iicConfig, iicConfig->BaseAddress);
    if (status != XST_SUCCESS)
    {
        xil_printf("FAILURE: iic cfg\r\n");
        return XST_FAILURE;
    }

    /* Perform self-test to ensure that HW was built correctly. */
    status = XIicPs_SelfTest(&iic);
    if (status != XST_SUCCESS)
    {
        xil_printf("FAILURE: iic self-test\r\n");
        return XST_FAILURE;
    }

    /* Set I2C SCLK rate */
    status = XIicPs_SetSClk(IIC_SCLK_RATE);
    if (status != XST_SUCCESS)
    {
        xil_printf("FAILURE: iic set sclk\r\n");
        return XST_FAILURE;
    }

    /*
     * All done configuring I2C. 
     * Now start configuring codec registers. The sequence is the following:
     * 1. Enable necessary power mgmt registers in R6, except bit B4.
     * 2. Configure the rest of the necessary control registers, except R9B0.
     *    R9B0 should be held at '1' until end of ctrl register setup.
     * 3. Sleep for ~100 ms to allow decouple capacitors to charge (VMID pin)
     * 4. Enable R9B0 to activate codec.
     * (5.) If DAC is needed enable R6B0 here.
     */


}