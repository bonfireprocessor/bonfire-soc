
.PHONY: all clean

PLATFORM=PAPRO
ARCH=rv32im
ABI=ilp32

UPLOAD_DIR?=~/upload

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

#LINKDEF?=wildfboot.ld
LINKDEF_DRAM=bonfire_dram.ld
LINKDEF?=$(PLATFORMDIR)/$(PLATFORM)/firmware.ld
BOOTLINK=wildfboot.ld

TARGET_CFLAGS +=  -march=$(ARCH) -mabi=$(ABI) -Wall -O2 -g  -fomit-frame-pointer \
	-ffreestanding -fno-builtin  -fno-builtin-printf    \
	-Wall \
	-D$(PLATFORM) -I$(PLATFORMDIR) -I$(PLATFORMDIR)/$(PLATFORM) -I../riscv  -DTIME



TARGET_LDFLAGS_SYSCALL += -march=$(ARCH) -mabi=$(ABI)   \
	 -Wl,--gc-sections  -Wl,-T$(LINKDEF_DRAM)


TARGET_LDFLAGS_BRAM += -march=$(ARCH) -mabi=$(ABI) -nostartfiles   \
	-Wl,-m,elf32lriscv --specs=nosys.specs -Wl,-T$(LINKDEF) \
	-Wl,--gc-sections

all: dhrystone.bin dhrystone_bram.bit

clean:
	rm *.o
	rm *.bin
	rm *.lst

%.bit: %.elf $(TOPLEVEL)
	$(DATA2MEM) -bm $(PROJROOT)/platform/wildfire_papro/soc_bd.bmm  -bd $< -bt $(TOPLEVEL)  -o hb $(basename $@)
	$(TARGET_PREFIX)-objdump -S -d $< >$(basename $@).lst
	$(TARGET_PREFIX)-objdump -s $< >$(basename $@).dmp
	$(TARGET_PREFIX)-size  $<


%.o : %.S
	$(TARGET_CC) $(TARGET_CFLAGS) -c $<

%.o : %.c
	$(TARGET_CC) $(TARGET_CFLAGS) -c $<


%.bin : %.elf
		$(TARGET_OBJCOPY) -S -O binary $<  $@
		cp $@ $(UPLOAD_DIR)
		$(TARGET_PREFIX)-objdump -S -d $< >$(basename $@).lst
		$(TARGET_PREFIX)-objdump -s $< >$(basename $@).dmp
		$(TARGET_PREFIX)-size  $<

%.hex : %.elf
	$(TARGET_OBJCOPY) -S -O $< $(basename $@).bin
	$(HEXDUMP) -v -e '1/4 "%08x\n"' $(basename $@).bin >$@
	$(TARGET_PREFIX)-objdump -S -d $< >$(basename $@).lst
	$(TARGET_PREFIX)-objdump -s $< >$(basename $@).dmp
	$(TARGET_PREFIX)-size  $<


uart.o : ../monitor/uart.c
	$(TARGET_CC) $(TARGET_CFLAGS) -c $<

malloc.o : libwrap/malloc.c
	$(TARGET_CC) $(TARGET_CFLAGS) -c $<

sbrk.o : libwrap/sbrk.c
	$(TARGET_CC) $(TARGET_CFLAGS) -c $<

write.o : libwrap/write.c
	$(TARGET_CC) $(TARGET_CFLAGS) -c $<


dhrystone.elf :  dhry_1.o  dhry_2.o dhry_stubs.o dhry_printf.o malloc.o sbrk.o
	$(TARGET_LD)  -o $@ $(TARGET_LDFLAGS_SYSCALL)  -Wl,--wrap=scanf,--wrap=printf,--wrap=malloc,--wrap=sbrk \
	  dhry_1.o  dhry_2.o dhry_stubs.o dhry_printf.o malloc.o sbrk.o


dhrystone_bram.elf :  dhry_1.o  dhry_2.o dhry_stubs.o dhry_printf.o uart.o  malloc.o sbrk.o  write.o start.o
	$(TARGET_LD)  -o $@ $(TARGET_LDFLAGS_BRAM)  -Wl,--wrap=scanf,--wrap=printf,--wrap=malloc,--wrap=sbrk,--wrap=write \
	 dhry_1.o  dhry_2.o dhry_stubs.o dhry_printf.o uart.o malloc.o sbrk.o write.o   start.o



