#ifndef PAPRO_PLATFORM_H
#define PAPRO_PLATFORM_H


#define UART_BASE 0x08000000
#define SPIFLASH_BASE 0x08000100
#define GPIO_BASE 0x04000000
#define MTIME_BASE 0x0FFFF0000

#define DRAM_BASE 0x0
#define DRAM_SIZE (8192*1024) // 8 Megabytes
#define DRAM_TOP  (DRAM_BASE+DRAM_SIZE-1)
#define SRAM_BASE 0x0C000000
#define SRAM_SIZE 16384
#define SRAM_TOP  (SRAM_BASE+SRAM_SIZE-1)

#define SYSCLK 96000000

#define CLK_PERIOD (1e+9 / SYSCLK)  // in ns...


// Parameters for SPI Flash 

#define FLASHSIZE (8192*1024)
#define MAX_FLASH_IMAGESIZE (1024*512) // Max 512KB of flash used for boot image
#define FLASH_IMAGEBASE (1024*512)  // Boot Image starts at 512KB in Flash

#endif
