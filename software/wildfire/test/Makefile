
.PHONY: all clean

PLATFORM=PAPRO

BOOTLINK=wildfboot.ld

#LINKDEF=wildfboot.ld
LINKDEF=wildfdram.ld

TARGET_PREFIX ?= riscv32-unknown-elf
TARGET_CC := $(TARGET_PREFIX)-gcc
TARGET_LD := $(TARGET_PREFIX)-gcc
TARGET_SIZE := $(TARGET_PREFIX)-size
TARGET_OBJCOPY := $(TARGET_PREFIX)-objcopy
HEXDUMP ?= hexdump
DATA2MEM = /opt/Xilinx/14.7/ISE_DS/ISE/bin/lin64/data2mem

PROJROOT = ../../..
TOPLEVEL = ~/riscv/ise/bonfire/papilio_pro_dram_toplevel.bit
PLATFORMDIR=../platform


TARGET_CFLAGS += -m32 -march=RV32IM -Wall -Os -g  -fomit-frame-pointer \
          -msoft-float\
	-ffreestanding -fno-builtin  \
	-Wall -Werror=implicit-function-declaration \
	-D$(PLATFORM) -I$(PLATFORMDIR) -I$(PLATFORMDIR)/$(PLATFORM) 

TARGET_LDFLAGS += -m32 -march=RV32I -nostartfiles  \
	-Wl,-m,elf32lriscv --specs=nosys.specs -Wl,-T$(LINKDEF) \
	-Wl,--gc-sections

all: ledslow.hex counter.hex memtest.hex ledsim.hex mult.hex memsim.hex sim_hello.hex dram_codesim.hex

%.bit: %.elf
	$(DATA2MEM) -bm $(PROJROOT)/platform/wildfire_papro/soc_bd.bmm  -bd $< -bt $(TOPLEVEL)  -o hb $(basename $@)

%.o : %.S
	$(TARGET_CC) $(TARGET_CFLAGS) -c $<

%.o : %.c
	$(TARGET_CC) $(TARGET_CFLAGS) -c $<



%.hex : %.elf
	$(TARGET_OBJCOPY) -j .text  -j .eh_frame -j .rodata -j .data -O binary $< $(basename $@).bin
	$(HEXDUMP) -v -e '1/4 "%08x\n"' $(basename $@).bin >$@
	$(TARGET_PREFIX)-objdump -S -d $< >$(basename $@).lst
	$(TARGET_PREFIX)-objdump -s $< >$(basename $@).dmp
	$(TARGET_PREFIX)-size  $<



ledslow.elf: start.o ledslow.o
	$(TARGET_LD) -o $@ $(TARGET_LDFLAGS) start.o ledslow.o

ledsim.elf: start.o ledsim.o
	$(TARGET_LD) -o $@ $(TARGET_LDFLAGS) start.o ledsim.o


counter.elf: start.o uart.o counter.o
	$(TARGET_LD) -o $@ $(TARGET_LDFLAGS) start.o counter.o uart.o

memtest.elf: start.o memtest.o uart.o mempattern.o
	$(TARGET_LD) -o $@ $(TARGET_LDFLAGS) start.o memtest.o uart.o mempattern.o

mult.elf : start.o mult.o uart.o snprintf.o console.o
	$(TARGET_LD) -o $@ $(TARGET_LDFLAGS) start.o mult.o uart.o snprintf.o console.o
	
memsim.elf: start.o memsim.o  mempattern.o
	$(TARGET_LD) -o $@ $(TARGET_LDFLAGS) start.o memsim.o  mempattern.o
	
sim_hello.elf: start.o uart.o sim_hello.o
	$(TARGET_LD) -o $@ $(TARGET_LDFLAGS) start.o uart.o sim_hello.o
	
dram_codesim.elf : start.o dram_codesim.o
	$(TARGET_LD) -o $@ $(TARGET_LDFLAGS) start.o dram_codesim.o

jump0.elf : jump0.S
	$(TARGET_LD) -o $@ -march=RV32IM -nostartfiles   -Wl,-T$(BOOTLINK)	$<
	
	

