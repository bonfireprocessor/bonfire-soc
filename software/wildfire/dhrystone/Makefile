
.PHONY: all clean

PLATFORM=PAPRO
ARCH=rv32i
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
	-ffreestanding -fno-builtin  \
	-Wall \
	-D$(PLATFORM) -I$(PLATFORMDIR) -I$(PLATFORMDIR)/$(PLATFORM)  -DTIME



TARGET_LDFLAGS_SYSCALL += -march=$(ARCH) -mabi=$(ABI)   \
	 -Wl,--gc-sections  -Wl,-T$(LINKDEF_DRAM)




all: dhrystone.bin

clean:
	rm *.o
	rm *.bin
	rm *.lst




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




dhrystone.elf :  dhry_1.o  dhry_2.o dhry_stubs.o
	$(TARGET_LD)  -o $@ $(TARGET_LDFLAGS_SYSCALL)  -Wl,--wrap=scanf   dhry_1.o  dhry_2.o dhry_stubs.o


