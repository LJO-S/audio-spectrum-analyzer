#ifndef BRAM_H
#define BRAM_H

#include <stdint.h>

#define N_TAPS 101

#define MAX_CUTOFF_FREQ_KHZ 23
#define MIN_CUTOFF_FREQ_KHZ 1

#define BRAM_LPF_ID XPAR_BRAM_0_DEVICE_ID
#define BRAM_LPF_BASEADDR XPAR_BRAM_0_BASEADDR

#define BRAM_HPF_ID XPAR_BRAM_1_DEVICE_ID
#define BRAM_HPF_BASEADDR XPAR_BRAM_1_BASEADDR

int bram_write_coeffs_lpf(const uint32_t *coeffs, size_t n_taps);
int bram_write_coeffs_hpf(const uint32_t *coeffs, size_t n_taps);
int bram_init(void);

#endif // BRAM_H