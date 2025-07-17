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
#include "ssm2603.h"
#include "sleep.h"
/************************** Constant Definitions ******************************/
#define IIC_DEVICE_ID XPAR_PS7_I2C_0_DEVICE_ID

/*
 * The slave address is specified in the data-sheet to be 0x1A or 0x1B, depending
 * on if the CSB is '0' or '1', respectively. Looking at the Zybo Z7-10 PCB schematic,
 * we find CSB to be hard-wired to GND.
 */
#define IIC_SLAVE_ADDR 0x1A

/*
 * The audio codec has a max of 526 kHz, so we can safely choose 100 kHz.
 * Another common frequency is fast mode, in 400 kHz.
 */
#define IIC_SCLK_RATE 100000

/************************** Variable Definitions ******************************/
XIicPs iic; /* i2c device */

/*
 * The following buffers are used in this example to send and receive data
 * with the IIC. They are defined as global so that they are not on the stack.
 */
u8 recvBuffer[2]; /* Buffer for Receiving Data */

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
        xil_printf("-- IIC Audio Codec configuration failed! --\r\n");
        return XST_FAILURE;
    }
    xil_printf("-- Successfully ran IIC Audio Codec configuration! --\r\n");
    return XST_SUCCESS;
}

/******************************************************************************/
/**
 *
 * Configuration function.
 * Sends configurations over to Audio Codec via I2C.
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
    u32 temp;
    u8 u8RegAddr;
    u16 u16Data;
    XIicPs_Config *iicConfig;

    /* Look up IIC driver configuration. */
    iicConfig = XIicPs_LookupConfig(deviceId);
    if (NULL == iicConfig)
    {
        xil_printf("FAILURE: iic lookup\r\n");
        return XST_FAILURE;
    }

    /* Initialize IIC driver. */
    xil_printf("Configuring IIC driver...\r\n");
    status = XIicPs_CfgInitialize(&iic, iicConfig, iicConfig->BaseAddress);
    if (status != XST_SUCCESS)
    {
        xil_printf("FAILURE: iic cfg\r\n");
        return XST_FAILURE;
    }

    /* Perform self-test to ensure that HW was built correctly. */
    xil_printf("Running IIC self-test...\r\n");
    status = XIicPs_SelfTest(&iic);
    if (status != XST_SUCCESS)
    {
        xil_printf("FAILURE: iic self-test\r\n");
        return XST_FAILURE;
    }

    /* Set I2C SCLK rate */
    xil_printf("Setting IIC SCLK...\r\n");
    status = XIicPs_SetSClk(&iic, IIC_SCLK_RATE);
    if (status != XST_SUCCESS)
    {
        xil_printf("FAILURE: iic set sclk\r\n");
        return XST_FAILURE;
    }
    temp = XIicPs_GetSClk(&iic);
    xil_printf("Actual registered SCLK: %d Hz\r\n", temp);

    /*
     * All done configuring I2C.
     * Now start configuring codec registers. The sequence is the following:
     *
     * 1. Enable necessary power mgmt registers in R6, except bit B4.
     *
     * 2. Configure the rest of the necessary control registers, except R9B0.
     *    R9B0 should be held at '0' until end of ctrl register setup.
     *
     * 3. Sleep for ~100 ms to allow decoupling capacitors to charge (VMID pin on schematic)
     *
     * 4. Enable R9B0 to activate codec.
     *
     * 5. Enable R6B4 to activate output.
     *
     */

    /* Configure PWR MGMT */
    u8RegAddr = R6_POWER_MANAGEMENT;
    u16Data = 0x0000;
    u16Data |= (0 << PWROFF); /* Power up */
    u16Data |= (0 << CLKOUT); /* Power up */
    u16Data |= (1 << OSC);    /* Power up */
    u16Data |= (1 << OUT);    /* Power down */
    u16Data |= (1 << DAC);    /* Power down */
    u16Data |= (0 << ADC);    /* Power up */
    u16Data |= (1 << MIC);    /* Power down */
    u16Data |= (0 << LINEIN); /* Power up */

    xil_printf("Sending PWR MGMT A...\r\n");
    // int status = XIicPs_MasterSendPolled(&iic, sendBuffer, 2, IIC_SLAVE_ADDR);
    status = AudioWriteToReg(u8RegAddr, u16Data);
    if (status != XST_SUCCESS)
    {
        xil_printf("FAILURE: iic send PWR MGMT A\r\n");
        return XST_FAILURE;
    }

    /* Leave 0x00-0x05, 0x0F-0x12 as is, defaults are good. */

    /* Digital Audio I/F */
    u8RegAddr = R7_DIGITAL_AUDIO_I_F;
    u16Data = 0x0000;
    u16Data |= (0 << BCLKINV);   /* Not inv */
    u16Data |= (0 << MS);        /* Slave mode */
    u16Data |= (0 << LRSWAP);    /* Swap DAC data off */
    u16Data |= (0 << LRP);       /* Pol control */
    u16Data |= (0b00 << WL);     /* Set data-word length to 16 bits */
    u16Data |= (0b10 << FORMAT); /* Set to I2S mode (0b10) */

    xil_printf("Sending Digital Audio I/F...\r\n");
    // int status = XIicPs_MasterSendPolled(&iic, sendBuffer, 2, IIC_SLAVE_ADDR);
    status = AudioWriteToReg(u8RegAddr, u16Data);
    if (status != XST_SUCCESS)
    {
        xil_printf("FAILURE: iic send Digital Audio I/F\r\n");
        return XST_FAILURE;
    }

    /* Sampling Rate 0x08 */
    u8RegAddr = R8_SAMPLING_RATE;
    u16Data = 0x0000;
    u16Data |= (0 << USB);      /* Normal mode */
    u16Data |= (0 << BOSR);     /* Base oversampling support for 256*f_s */
    u16Data |= (0b0111 << SR);  /* If MCLK=12.288 MHz then
                                 * 0b0111=96kHz and 0b0000=48kHz
                                 */
    u16Data |= (0 << CLKDIV2);  /* Core CLK is MCLK */
    u16Data |= (0 << CLKODIV2); /* CLKOUT is core CLK */

    xil_printf("Sending Sampling Rate...\r\n");
    // int status = XIicPs_MasterSendPolled(&iic, sendBuffer, 2, IIC_SLAVE_ADDR);
    status = AudioWriteToReg(u8RegAddr, u16Data);
    if (status != XST_SUCCESS)
    {
        xil_printf("FAILURE: iic send Sampling Rate A\r\n");
        return XST_FAILURE;
    }

    /* Sleep for 99 ms waiting for VMID 10 uF caps */
    usleep(99000);

    /* Configure ACTIVE */
    u8RegAddr = R9_ACTIVE;
    u16Data = 0x0000;
    u16Data |= (1 << ACTIVE); /* Activate digital core */

    xil_printf("Sending Activate Digital Core...\r\n");
    // int status = XIicPs_MasterSendPolled(&iic, sendBuffer, 2, IIC_SLAVE_ADDR);
    status = AudioWriteToReg(u8RegAddr, u16Data);
    if (status != XST_SUCCESS)
    {
        xil_printf("FAILURE: iic send Activate Digital Core\r\n");
        return XST_FAILURE;
    }

    /* Configure PWR MGMT */
    u8RegAddr = R6_POWER_MANAGEMENT;
    u16Data = 0x0000;
    u16Data |= (0 << PWROFF); /* Power up */
    u16Data |= (0 << CLKOUT); /* Power up */
    u16Data |= (0 << OSC);    /* Power up */
    u16Data |= (0 << OUT);    /* Power up */
    u16Data |= (1 << DAC);    /* Power down */
    u16Data |= (0 << ADC);    /* Power up */
    u16Data |= (1 << MIC);    /* Power down */
    u16Data |= (0 << LINEIN); /* Power up */

    xil_printf("Sending PWR MGMT B...\r\n");
    // int status = XIicPs_MasterSendPolled(&iic, sendBuffer, 2, IIC_SLAVE_ADDR);
    status = AudioWriteToReg(u8RegAddr, u16Data);
    if (status != XST_SUCCESS)
    {
        xil_printf("FAILURE: iic send PWR MGMT B\r\n");
        return XST_FAILURE;
    }
    return XST_SUCCESS;
}

/* ---------------------------------------------------------------------------- *
 *         						AudioWriteToReg									*
 * ---------------------------------------------------------------------------- */

/** Function to write to one of the registers from the audio
 * controller.
 *
 * @param u8Regaddr 8-bit register address
 *
 * @param u16Data 16-bit data constitutes of 5 zeros followed by 9-bit data
 *
 * @return XST_SUCCESS or XST_FAILURE
 *
 * @note Hard-coded to support SSM2603 I2C data TX/RX structure
 *
 * ---------------------------------------------------------------------------- */
int AudioWriteToReg(u8 u8RegAddr, u16 u16Data)
{
    int status;
    unsigned char u8TxData[2];

    u8TxData[0] = u8RegAddr << 1;
    u8TxData[0] = u8TxData[0] | ((u16Data >> 8) & 0b1);

    u8TxData[1] = u16Data & 0xFF;

    status = XIicPs_MasterSendPolled(&iic, u8TxData, 2, IIC_SLAVE_ADDR);
    if (status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }
    while (XIicPs_BusIsBusy(&iic))
    {
        /* NOP */
    }
    return XST_SUCCESS;
}