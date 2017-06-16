
.PHONY: all clean run

ARCH ?= rv32im
ABI=ilp32
PLATFORM ?= PAPRO


TARGET_PREFIX ?= riscv32-unknown-elf
TARGET_CC := $(TARGET_PREFIX)-gcc
TARGET_LD := $(TARGET_PREFIX)-gcc
TARGET_SIZE := $(TARGET_PREFIX)-size
TARGET_OBJCOPY := $(TARGET_PREFIX)-objcopy
HEXDUMP ?= hexdump
DATA2MEM ?= /opt/Xilinx/14.7/ISE_DS/ISE/bin/lin64/data2mem
PROG?=papilio-prog -v -f

SOFTROOT = ../..
PROJROOT = $(SOFTROOT)/..

TOPLEVEL = ~/riscv/ise/bonfire/papilio_pro_dram_toplevel.bit
PLATFORMDIR=../platform
LINKDEF=$(PLATFORMDIR)/$(PLATFORM)/firmware.ld

TARGET_NAME=$(PLATFORM)_monitor


TARGET_CFLAGS += -march=$(ARCH) -mabi=$(ABI)   -Wall -Os -g -fomit-frame-pointer \
	-ffreestanding -fno-builtin   \
	-Wall -Werror=implicit-function-declaration \
	-D$(PLATFORM) -I$(PLATFORMDIR) -I$(PLATFORMDIR)/$(PLATFORM) -I./spiflash_driver/src -I../riscv  -I.

TARGET_LDFLAGS += -march=$(ARCH) -mabi=$(ABI) -nostartfiles  \
	-Wl,-m,elf32lriscv --specs=nosys.specs -Wl,-T$(LINKDEF) \
	-Wl,--gc-sections


OBJECTS = start.o monitor.o uart.o snprintf.o string.o console.o mempattern.o xm.o spiflash.o syscall.o spi_driver.o

run: $(TARGET_NAME).bit
	$(PROG) $<

all: $(TARGET_NAME).hex $(TARGET_NAME).bin

%.bit: %.elf $(TOPLEVEL)
	$(DATA2MEM) -bm $(PROJROOT)/platform/wildfire_papro/soc_bd.bmm  -bd $< -bt $(TOPLEVEL)  -o hb $(basename $@)
	$(TARGET_PREFIX)-objdump -S -d $< >$(basename $@).lst
	$(TARGET_PREFIX)-size  $<

%.o : %.S
	$(TARGET_CC) $(TARGET_CFLAGS) -c $<

%.o : %.c
	$(TARGET_CC) $(TARGET_CFLAGS) -c $<



%.hex : %.elf
	$(TARGET_OBJCOPY) -j .text -j .data -O binary $< $(basename $@).bin
	$(HEXDUMP) -v -e '1/4 "%08x\n"' $(basename $@).bin >$@
	$(TARGET_PREFIX)-objdump -S -d $< >$(basename $@).lst
	$(TARGET_PREFIX)-objdump -s $< >$(basename $@).dmp
	$(TARGET_PREFIX)-size  $<


spiflash.o : spiflash_driver/src/spiflash.c 
	$(TARGET_CC) $(TARGET_CFLAGS) -c $<


	
$(TARGET_NAME).elf : $(OBJECTS) $(LINKDEF)
	$(TARGET_LD) -o $@ $(TARGET_LDFLAGS)  $(OBJECTS)


