# Compiler
CC = arm-none-eabi-gcc

# Compiler flags
CFLAGS = -std=c99 -Wall -Wextra -Werror -mcpu=cortex-m4 -mthumb -O2
CFLAGS += -I.

# Source files
SRCS = main.c

# Object files
OBJS = $(SRCS:.c=.o)

# Output binary
TARGET = main.elf

# Rule to build the executable
$(TARGET): $(OBJS)
    $(CC) $(CFLAGS) $^ -o $@

# Rule to compile source files
%.o: %.c
    $(CC) $(CFLAGS) -c $< -o $@

# Rule to clean the build directory
clean:
    rm -f $(OBJS) $(TARGET)
