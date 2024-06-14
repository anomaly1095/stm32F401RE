CC=arm-none-eabi-gcc
AS=arm-none-eabi-as
LD=arm-none-eabi-ld
OBJDUMP=arm-none-eabi-objdump
DBG_FLAGS=-g -Wall
ASM_FLAGS=-mcpu=cortex-m4 -mthumb $(DBG_FLAGS)
LD_FLAGS=--script linker-script.ld -e reset_handler

SRCS = firmware.s startup.s sysconf.s
OBJS = $(SRCS:.s=.o)
ELF = firmware.elf

firmware.elf: $(OBJS)
	$(LD) $(LD_FLAGS) -o $@ $(OBJS)
	clear

%.o: %.s
	$(AS) $(ASM_FLAGS) -o $@ $<

dump: firmware.elf
	$(OBJDUMP) -h $< > firmware.map

clean:
	rm -f *.o *.elf *.map
