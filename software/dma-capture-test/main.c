/*
* Zynq PS-PL DMA communications test & Audio Codec Setup
* Steps:
* 1. Setup DMA and verify that it is working by looping back write/reads with itself via AXI4Stream FIFO.
* 2. Setup Audio Codec using example code from Zynq book tutorial.
*/

#include <stdio.h>
#include "xil_printf.h"
#include "xil_types.h"
#include "xil_cache.h"
#include "xparameters.h"
#include "xaxidma.h"

#define DMA_DEVICE_ID XPAR_AXI_DMA_0_DEVICE_ID
#define DMA_TRANSFER_SIZE 16

static XAxiDma dma_ctrl;
static XAxiDma_Config *dma_cfg;

int main()
{
    s32 status;
    u32 data_dma_to_device[DMA_TRANSFER_SIZE]; // DMA-read moves this data buffer to AXIS FIFO in PL
    u32 data_device_to_dma[DMA_TRANSFER_SIZE]; // DMA-write moves this data buffer from AXIS FIFO in PL to data buffer
    u32 dma_transfer_size_total = DMA_TRANSFER_SIZE * 4;

    Xil_DCacheDisable();

    print("\n -- Hello world! - Initializing Zynq SoC DMA PS/PL -- \n\r");

    // Lookup AXI DMA driver configuration
    xil_printf("Lookup AXI DMA driver configuration\n\r");
    dma_cfg = XAxiDma_LookupConfig(DMA_DEVICE_ID);
    if (dma_cfg == NULL)
    {
        return XST_FAILURE;
    }

    // Init AXI DMA driver
    xil_printf("Init DMA driver\n\r");
    status = XAxiDma_CfgInitialize(&dma_ctrl, dma_cfg);
    if (status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    // Init DMA read data buffer with 32-bit incr counter data
    xil_printf("Init DMA read buffer driver\n\r");
    for (u32 i = 0; i < DMA_TRANSFER_SIZE; i++)
    {
        data_dma_to_device[i] = i;
    }
    
    // Move data to AXIS FIFO in PL
    xil_printf("Move data to AXIS FIFO in PL\n\r");
    status = XAxiDma_SimpleTransfer(&dma_ctrl, (UINTPTR)data_dma_to_device, DMA_TRANSFER_SIZE * sizeof(u32), XAXIDMA_DMA_TO_DEVICE);
    if (status != XST_SUCCESS)
    {
    	xil_printf("ERROR! \n\r");
        return XST_FAILURE;
    }

    // Check to see if we got stuck
    xil_printf("Check to see if we got stuck:");
    usleep(1);
    xil_printf("All good!\n\r");
    if (XAxiDma_Busy(&dma_ctrl, XAXIDMA_DMA_TO_DEVICE))
    {
    	xil_printf("ERROR! \n\r");
        return XST_FAILURE;
    }

    xil_printf("Move data from AXIS FIFO in PL\n\r");
    status = XAxiDma_SimpleTransfer(&dma_ctrl, (UINTPTR)data_device_to_dma, DMA_TRANSFER_SIZE * sizeof(u32), XAXIDMA_DEVICE_TO_DMA);
    if (status != XST_SUCCESS)
    {
    	xil_printf("ERROR! \n\r");
        return XST_FAILURE;
    }
    
    // Check to see if we got stuck
    xil_printf("Check to see if we got stuck:\r");
    usleep(1);
    xil_printf("All good!\n\r");
    if (XAxiDma_Busy(&dma_ctrl, XAXIDMA_DEVICE_TO_DMA))
    {
    	xil_printf("ERROR! \n\r");
        return XST_FAILURE;
    }
    
    // Verify data read in PS is the data we sent to PL
    xil_printf("Received data after DMA round-trip loop: \n\r");
    for (u32 i = 0; i < DMA_TRANSFER_SIZE; i++)
    {
        xil_printf("%u", data_device_to_dma[i]);
    }

    return XST_SUCCESS;
}
