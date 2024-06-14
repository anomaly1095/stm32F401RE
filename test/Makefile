AS = arm-none-eabi-as
LD = arm-none-eabi-ld
OBJDUMP = arm-none-eabi-objdump
OBJCOPY = arm-none-eabi-objcopy
DBG_FLAGS = -g -Wall
ASM_FLAGS = -mcpu=cortex-m4 -mthumb $(DBG_FLAGS)
LD_FLAGS = --script linker-script.ld -e reset_handler

SRC = src
BIN = bin

SRCS = $(wildcard $(SRC)/*.s)
OBJS = $(patsubst $(SRC)/%.s,$(BIN)/%.o,$(SRCS))
ELF = $(BIN)/firmware.elf
MAP = $(BIN)/firmware.map
BIN_FILE = $(BIN)/firmware.bin

all: $(ELF) dump $(BIN_FILE)

$(ELF): $(OBJS) | $(BIN)
	$(LD) $(LD_FLAGS) -o $@ $^
	clear

$(BIN)/%.o: $(SRC)/%.s | $(BIN)
	$(AS) $(ASM_FLAGS) -o $@ $<

$(BIN):
	mkdir -p $(BIN)

dump: $(ELF)
	$(OBJDUMP) -h $< > $(MAP)

$(BIN_FILE): $(ELF)
	$(OBJCOPY) -O binary $< $@

clean:
	rm -f $(OBJS) $(ELF) $(MAP) $(BIN_FILE)

.PHONY: all dump clean
