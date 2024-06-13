CC= arm-none-eabi-gcc
AS= arm-none-eabi-as
LD= arm-none-eabi-ld
ASM_FLAGS= -mcpu=cortex-m4 -mthumb 
LD_FLAGS= --script linker-script.ld -e reset_handler

SRC_FILES := $(wildcard *.c)
ASM_FILES := $(wildcard *.s)
OBJ_FILES := $(SRC_FILES:.c=.o) $(ASM_FILES:.s=.o)

TARGET = output.elf

all: $(TARGET)

$(TARGET): $(OBJ_FILES)
    $(LD) $(LD_FLAGS) -o $@ $^

%.o: %.c
    $(CC) $(ASM_FLAGS) -c $< -o $@

%.o: %.s
    $(AS) $(ASM_FLAGS) $< -o $@

assemble: $(OBJ_FILES)

clean:
    rm -rf *.o *.elf *.map

.PHONY: all assemble clean
