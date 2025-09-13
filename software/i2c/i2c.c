/*
 * Settings up Audio Codec using I2C PS Peripheral.
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
#include "xgpio.h"
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

#define GPIO_DEVICE_ID XPAR_GPIO_0_DEVICE_ID

/************************** Variable Definitions ******************************/
XIicPs iic;     /* i2c device */
XGpio gpioInst; /* gpio instance */
/*
 * The following buffers are used in this example to send and receive data
 * with the IIC. They are defined as global so that they are not on the stack.
 */
u8 recvBuffer[2]; /* Buffer for Receiving Data */

/*------------------------------------------------------------------------------*/
/* 1) Error check helper macro                                                  */
/*------------------------------------------------------------------------------*/
#define CHECK(x)                           \
    do                                     \
    {                                      \
        int st = (x);                      \
        if (st != XST_SUCCESS)             \
        {                                  \
            xil_printf("Failed at %s\r\n", \
                       #x);                \
            return XST_FAILURE;            \
        }                                  \
    } while (0)

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
int iic_init(void)
{
    int status;
    xil_printf("Configuring GPIO... \r\n");
    status = XGpio_Initialize(&gpioInst, GPIO_DEVICE_ID);
    if (status != XST_SUCCESS)
    {
        xil_printf("-- GPIO configuration failed! --\r\n");
        return XST_FAILURE;
    }
    XGpio_SetDataDirection(&gpioInst, 1, 0x00); // Set to output
    XGpio_DiscreteClear(&gpioInst, 1, 0x01); // clear GPIO(0) 
    xil_printf("GPIO configured & zeroed!\r\n");

    xil_printf("Configuring Audio Codec... \r\n");
    status = IicPsAudioCodecSetup(IIC_DEVICE_ID);
    if (status != XST_SUCCESS)
    {
        xil_printf("-- IIC Audio Codec configuration failed! --\r\n");
        return XST_FAILURE;
    }
    xil_printf("-- Successfully ran IIC Audio Codec configuration! --\r\n");
    XGpio_DiscreteWrite(&gpioInst, 1, 0x1);
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
static int IicPsAudioCodecSetup(u16 deviceId)
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
     * 0. Software reset.
     * 
     * 1. Sleep for 75 ms.
     *
     * 2. Enable necessary power mgmt registers in R6, except bit B4.
     *
     * 3. Configure the rest of the necessary control registers, except R9B0.
     *    R9B0 should be held at '0' until end of ctrl register setup.
     *
     * 4. Sleep for ~100 ms to allow decoupling capacitors to charge (VMID pin on schematic)
     *
     * 5. Enable R9B0 to activate codec.
     *
     * 6. Enable R6B4 to activate output.
     *
     */
    /* -------------- Software Reset -------------- */
    u8RegAddr = R15_SOFTWARE_RESET;
    u16Data = 0x0000;
    WriteReg(u8RegAddr, u16Data, "SOFTWARE RESET");
    usleep(75000);

    /* -------------- Configure PWR MGMT START -------------- */
    u8RegAddr = R6_POWER_MANAGEMENT;
    u16Data = 0x0000;
    u16Data |= (0 << PWROFF); /* Power up */
    u16Data |= (0 << CLKOUT); /* Power up */
    u16Data |= (1 << OSC);    /* Power down */
    u16Data |= (1 << OUT);    /* Power down */
    u16Data |= (1 << DAC);    /* Power down */
    u16Data |= (0 << ADC);    /* Power up */
    u16Data |= (0 << MIC);    /* Power down */
    u16Data |= (0 << LINEIN); /* Power up */
    WriteReg(u8RegAddr, u16Data, "PWR MGMT A");

    /* -------------- Left-Ch ADC input vol -------------- */
    u8RegAddr = R0_LEFT_CHANNEL_ADC_INPUT_VOLUME;
    u16Data = 0x0000;
    u16Data |= (0 << LINMUTE); /* Disable mute */
    u16Data |= (0b010111 << 0); /* Default volume (0 dB) */
    WriteReg(u8RegAddr, u16Data, "Left Ch ADC Vol");

    /* -------------- Right-Ch ADC input vol -------------- */
    u8RegAddr = R1_RIGHT_CHANNEL_ADC_INPUT_VOLUME;
    u16Data = 0x0000;
    u16Data |= (0 << RINMUTE); /* Disable mute */
    u16Data |= (0b010111 << 0); /* Default volume (0 dB) */
    WriteReg(u8RegAddr, u16Data, "Right Ch ADC Vol");

    /* ------------------------------------------------*/
    // Skipping R2-R3 (DAC Volumes)
    /* ------------------------------------------------*/

    /* -------------- Analog Audio Path -------------- */
    u8RegAddr = R4_ANALOG_AUDIO_PATH;
    u16Data = 0x0000;
    u16Data |= (0 << BYPASS); /* Disable bypass  */
    u16Data |= (0 << INSEL); /* Select line input */
    u16Data |= (1 << MUTEMIC); /* Enable mute mic */
    u16Data |= (0 << MICBOOST); /* Disable mic boost */
    WriteReg(u8RegAddr, u16Data, "Analog Audio Path");

    /* ------------------------------------------------*/
    // Skipping R5 (DAC Audio Path)
    /* ------------------------------------------------*/

    /* -------------- Digital Audio I/F -------------- */
    u8RegAddr = R7_DIGITAL_AUDIO_I_F;
    u16Data = 0x0000;
    u16Data |= (0 << BCLKINV); /* BCLK not inverted */
    u16Data |= (0 << MS);  /* Enable slave mode */
    u16Data |= (0 << LRSWAP);  /* Normal L&R DAC data */
    u16Data |= (0 << LRP); /* Normal PBLRC and RECLRC */
    u16Data |= (0b00 << WL);  /* 16-bit data */
    u16Data |= (0b10 << FORMAT); /* I2S mode */
    WriteReg(u8RegAddr, u16Data, "Digital Audio I/F");

    /* -------------- Sampling Rate 0x08 -------------- */
    u8RegAddr = R8_SAMPLING_RATE;
    u16Data = 0x0000;
    u16Data |= (0 << USB);      /* Normal mode */
    u16Data |= (0 << BOSR);     /* Base oversampling support for 256*f_s */
    u16Data |= (0b0000 << SR);  /* With MCKLK= 12.5 MHz then
                                 * 0b0111=98 kHz and 0b0000 = 49kHz
                                 */
    u16Data |= (1 << CLKDIV2);  /* Core CLK is MCLK/2 */
    u16Data |= (0 << CLKODIV2); /* CLKOUT is core CLK */
    WriteReg(u8RegAddr, u16Data, "Sampling Rate");

    /* ------------------------------------------
     * Sleep for 75 ms waiting for VMID 10 uF caps
     * ------------------------------------------ */
    usleep(75000);

    /* -------------- Configure ACTIVE -------------- */
    u8RegAddr = R9_ACTIVE;
    u16Data = 0x0000;
    u16Data |= (1 << ACTIVE); /* Activate digital core */
    WriteReg(u8RegAddr, u16Data, "Active");

    /* -------------- Configure PWR MGMT END -------------- */
    u8RegAddr = R6_POWER_MANAGEMENT;
    u16Data = 0x0000;
    u16Data |= (0 << PWROFF); /* Power up */
    u16Data |= (0 << CLKOUT); /* Power up */
    u16Data |= (1 << OSC);    /* Power down */
    u16Data |= (0 << OUT);    /* Power up */
    u16Data |= (1 << DAC);    /* Power down */
    u16Data |= (0 << ADC);    /* Power up */
    u16Data |= (1 << MIC);    /* Power down */
    u16Data |= (0 << LINEIN); /* Power up */
    WriteReg(u8RegAddr, u16Data, "PWR MGMT B");

    /* Return statement */
    return XST_SUCCESS;
}

/*------------------------------------------------------------------------------*/
/*                   Simplified register‑write wrapper                          */
/*------------------------------------------------------------------------------*/

/**
 *
 * Function wrapper of AudioWriteToReg. Calls upon macro to give check status
 * of write return.
 *
 * @param u8Regaddr 8-bit register address
 *
 * @param u16Data 16-bit data constitutes of 5 zeros followed by 9-bit data
 *
 * @return None.
 *
 * @note
 *
 */
static void WriteReg(u8 u8RegAddr, u16 u16Data, const char *name)
{
    xil_printf("Sending %s (0x%02X <-- 0x%03X) ... \r\n", name, u8RegAddr, u16Data);
    CHECK(AudioWriteToReg(u8RegAddr, u16Data));
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
static int AudioWriteToReg(u8 u8RegAddr, u16 u16Data)
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