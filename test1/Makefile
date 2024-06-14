CC=arm-none-eabi-gcc
AS=arm-none-eabi-as
LD=arm-none-eabi-ld
DBG_FLAGS=-g -Wall
ASM_FLAGS=-mcpu=cortex-m4 -mthumb $(DBG_FLAGS)
LD_FLAGS=--script linker-script.ld -e reset_handler

firmware.elf: firmware.o startup.o sysconf.o
	$(LD) $(LD_FLAGS) -o $@ firmware.o startup.o sysconf.o

startup.o: startup.s
	$(AS) $(ASM_FLAGS) -o $@ $< 

sysconf.o: sysconf.s
	$(AS) $(ASM_FLAGS) -o $@ $< 

firmware.o: firmware.s
	$(AS) $(ASM_FLAGS) -o $@ $< 

clean:
	rm -f *.o *.elf
