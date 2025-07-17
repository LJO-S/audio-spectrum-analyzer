
/******************************************************************************
* Header file for SSM2603 registers.
*******************************************************************************/

#ifndef SSM_2603_H
#define SSM_2603_H

#ifdef __cplusplus
extern "C" {
#endif

/* Left Channel ADC Vol 0x00 */
#define LINMUTE 7
#define LRINBOTH 8

/* Right Channel ADC Vol 0x01 */
#define RINMUTE 7
#define RLINBOTH 8

/* Left Channel DAC Vol 0x02 */
#define LRHPBOTH 8

/* Right Channel DAC Vol 0x03 */
#define RLHPBOTH 8

/* Analog Audio Path 0x04 */
#define MICBOOST 0
#define MUTEMIC 1
#define INSEL 2
#define BYPASS 3
#define DACSEL 4
#define SIDETONE_EN 5
#define SIDETONE_ATT 7

/* Digital Audio Path 0x05 */
#define ADCHPF 0
#define DEEPMPH 1
#define DACMU 3
#define HPOR 4

/* Power Management 0x06 */
#define LINEIN 0
#define MIC 1
#define ADC 2
#define DAC 3
#define OUT 4
#define OSC 5
#define CLKOUT 6
#define PWROFF 7

/* Digital audio I/F 0x07 */
#define FORMAT 0
#define WL 2
#define LRP 4
#define LRSWAP 5
#define MS 6
#define BCLKINV 7

/* Sampling Rate 0x08 */
#define USB 0
#define BOSR 1
#define SR 2
#define CLKDIV2 6
#define CLKODIV2 7

/* Active 0x09 */
#define ACTIVE 0

/* Software Reset 0x0F */
#define RESET 0

/* ALC Control 1 0x10 */
#define ALCL 0
#define MAXGAIN 4
#define ALCSEL 7

/* ALC Control 2 0x11 */
#define ATK 0
#define DCY 4

/* Noise Gate 0x12 */
#define NGAT 0
#define NGG 1
#define NGTH 3


#ifdef __cplusplus
}
#endif
#endif	/* end of protection macro */