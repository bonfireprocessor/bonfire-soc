#ifndef __SPI_DRIVER_H
#define __SPI_DRIVER_H

#include <stdbool.h>
#include "spiflash.h"

bool spiflash_test();
spiflash_t* flash_init();

int flash_print_spiresult(int code);
int flash_Overwrite(spiflash_t *spi, uint32_t addr, uint32_t len, const uint8_t *buf);

#endif
