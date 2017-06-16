#ifndef ARTY_AXI_PLATFORM_H
#define ARTY_AXI_PLATFORM_H


#define WISHBONE_IO_SPACE 0x40000000

#define UART_BASE (WISHBONE_IO_SPACE)
#define SPIFLASH_BASE (WISHBONE_IO_SPACE+0x100)
#define GPIO_BASE (WISHBONE_IO_SPACE+0x200)
#define MTIME_BASE 0x0FFFF0000

//#define DRAM_BASE 0x0
#define DRAM_BASE 0x80000000
#define DRAM_SIZE (32*1024) // "Fake" DRAM  32 KBytes
#define DRAM_TOP  (DRAM_BASE+DRAM_SIZE-1)
#define SRAM_BASE 0xC0000000
#define SRAM_SIZE (32*1024)
#define SRAM_TOP  (SRAM_BASE+SRAM_SIZE-1)

#define SYSCLK 96000000

#define CLK_PERIOD (1e+9 / SYSCLK)  // in ns...


// Parameters for SPI Flash 

#define FLASHSIZE (8192*1024)
#define MAX_FLASH_IMAGESIZE (1024*512) // Max 512KB of flash used for boot image
#define FLASH_IMAGEBASE (1024*512)  // Boot Image starts at 512KB in Flash

#endif
