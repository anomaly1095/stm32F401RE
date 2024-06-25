AS = arm-none-eabi-as
LD = arm-none-eabi-ld
OBJDUMP = arm-none-eabi-objdump
OBJCOPY = arm-none-eabi-objcopy

# Compiler and linker flags
DBG_FLAGS = -g -Wall
ASM_FLAGS = -mcpu=cortex-m4 -mthumb $(DBG_FLAGS)
LD_FLAGS = --script linker-script.ld -e reset_handler -Map=$(MAP2)

# Directories
SRC = src
BIN = bin
DOC = docs

# Source files and objects
SRCS = $(wildcard $(SRC)/*.asm)
OBJS = $(patsubst $(SRC)/%.asm,$(BIN)/%.o,$(SRCS))
ELF = $(BIN)/firmware.elf
MAP1 = $(DOC)/firmware1.map
MAP2 = $(DOC)/firmware2.map
BIN_FILE = $(BIN)/firmware.bin

# Default target
all: $(ELF) dump $(BIN_FILE)

# Linking step
$(ELF): $(OBJS) | $(BIN)
	$(LD) $(LD_FLAGS) -o $@ $^

# Assembly compilation step
$(BIN)/%.o: $(SRC)/%.asm | $(BIN)
	$(AS) $(ASM_FLAGS) -o $@ $<

# Create output directory if it doesn't exist
$(BIN):
	mkdir -p $(BIN)

# Generate memory map
dump: $(ELF)
	$(OBJDUMP) -h $< > $(MAP1)

# Flash firmware to STM32 using OpenOCD
flash:
	sudo openocd -f openocd.cfg -d -c "program $(ELF) verify reset exit"

# Create binary file
$(BIN_FILE): $(ELF)
	$(OBJCOPY) -O binary $< $@

# Clean up
clean:
	rm -f $(OBJS) $(ELF) $(MAP) $(BIN_FILE)

# Phony targets
.PHONY: all dump clean flash
