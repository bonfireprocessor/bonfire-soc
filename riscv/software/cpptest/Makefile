
.PHONY: all clean

TARGET_PREFIX ?= riscv32-unknown-elf
TARGET_CC := $(TARGET_PREFIX)-gcc
TARGET_LD := $(TARGET_PREFIX)-gcc
TARGET_SIZE := $(TARGET_PREFIX)-size
TARGET_OBJCOPY := $(TARGET_PREFIX)-objcopy
HEXDUMP ?= hexdump

TARGET_CFLAGS += -m32 -march=RV32I -Wall -Os -fomit-frame-pointer \
          -msoft-float\
	-ffreestanding -fno-builtin  \
	-Wall -Werror=implicit-function-declaration

TARGET_LDFLAGS += -m32 -march=RV32I -nostartfiles \
	-Wl,-m,elf32lriscv --specs=nosys.specs -Wl,-Tlxp.ld \
	-Wl,--gc-sections

all:
	hello.hex mult.hex


%.o : %.S
	$(TARGET_CC) $(TARGET_CFLAGS) -c $<

%.o : %.c
	$(TARGET_CC) $(TARGET_CFLAGS) -c $<



%.hex : %.elf
	$(TARGET_OBJCOPY) -j .text -j .data -O binary $< $(basename $@).bin
	$(HEXDUMP) -v -e '1/4 "%08x\n"' $(basename $@).bin >$@	
	$(TARGET_PREFIX)-objdump -d $< >$(basename $@).lst
	$(TARGET_PREFIX)-objdump -s $< >$(basename $@).dmp 
	$(TARGET_PREFIX)-size  $<



hello.elf: start.o hello.o
	$(TARGET_LD) -o $@ $(TARGET_LDFLAGS) start.o hello.o


mult.elf: start.o mult.o
	$(TARGET_LD) -o $@ $(TARGET_LDFLAGS) start.o mult.o

	
