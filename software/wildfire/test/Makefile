
.PHONY: all clean

PLATFORM=PAPRO
LINKDEF=wildfboot.ld

TARGET_PREFIX ?= riscv32-unknown-elf
TARGET_CC := $(TARGET_PREFIX)-gcc
TARGET_LD := $(TARGET_PREFIX)-gcc
TARGET_SIZE := $(TARGET_PREFIX)-size
TARGET_OBJCOPY := $(TARGET_PREFIX)-objcopy
HEXDUMP ?= hexdump


TARGET_CFLAGS += -m32 -march=RV32IM -Wall -Os -g  -fomit-frame-pointer \
          -msoft-float\
	-ffreestanding -fno-builtin  \
	-Wall -Werror=implicit-function-declaration \
	-D$(PLATFORM)

TARGET_LDFLAGS += -m32 -march=RV32I -nostartfiles  \
	-Wl,-m,elf32lriscv --specs=nosys.specs -Wl,-T$(LINKDEF) \
	-Wl,--gc-sections

all: ledslow.hex counter.hex memtest.hex ledsim.hex mult.hex



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



ledslow.elf: start.o ledslow.o
	$(TARGET_LD) -o $@ $(TARGET_LDFLAGS) start.o ledslow.o

ledsim.elf: start.o ledsim.o
	$(TARGET_LD) -o $@ $(TARGET_LDFLAGS) start.o ledsim.o


counter.elf: start.o uart.o counter.o
	$(TARGET_LD) -o $@ $(TARGET_LDFLAGS) start.o counter.o uart.o

memtest.elf: start.o memtest.o uart.o
	$(TARGET_LD) -o $@ $(TARGET_LDFLAGS) start.o memtest.o uart.o

mult.elf : start.o mult.o uart.o
	$(TARGET_LD) -o $@ $(TARGET_LDFLAGS) start.o mult.o uart.o


