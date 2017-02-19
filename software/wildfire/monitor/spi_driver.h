#ifndef __SPI_DRIVER_H
#define __SPI_DRIVER_H

#include <stdbool.h>
#include "spiflash.h"

bool spiflash_test();
spiflash_t* flash_init();

#endif
