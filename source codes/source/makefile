# Target MCU GCC and FLASHER
MSP430_PATH     = /Users/sinanyil81/myti/msp430_gcc
MSP430_FET      = /Users/sinanyil81/MSPFlasher_1.3.11/MSP430Flasher

# MSP430 Platform Compiler Configuration
DEVICE  	= msp430fr5969
CC      	= $(MSP430_PATH)/bin/msp430-elf-gcc
GDB       = $(MSP430_PATH)/bin/msp430-elf-gdb -tui
OBJCOPY 	= $(MSP430_PATH)/bin/msp430-elf-objcopy
CFLAGS 		= -mmcu=$(DEVICE) -O1 -g -std=c99 -Wall
INCLUDES	+= -I$(MSP430_PATH)/include/
LFLAGS		= -L $(MSP430_PATH)/include/

# MSP430 Programmer Command
FET			= $(MSP430_FET) -v -g -z [VCC]

TARGET	:=$(DEVICE)
BUILDDIR	= build

_SOURCES	:= toggle.c
_OBJECTS	:= $(_SOURCES:%.c=%.o)

.PHONY=clean

app:$(_OBJECTS)
	@echo .......Generating $@.hex
	$(CC) $(CFLAGS) $(LFLAGS) $(addprefix $(BUILDDIR)/,$(notdir $(_OBJECTS))) -lm -o $(BUILDDIR)/$(TARGET).out
	$(OBJCOPY) -O ihex $(BUILDDIR)/$(TARGET).out $(BUILDDIR)/$(TARGET).hex

%.o: %.c
	@mkdir -p $(BUILDDIR)/
	@echo .......Compiling $(notdir $@)
	$(CC) $(CFLAGS) $(LFLAGS) $(INCLUDES)  -c $< -o $(BUILDDIR)/$(notdir $@)

install:
	$(FET) -w $(BUILDDIR)/$(TARGET).hex -v -g -z [VCC]

# Run ./gdb_agent_console ../msp430.dat before calling and use target remote :55000
debug:
	$(GDB) $(BUILDDIR)/$(TARGET).out

clean:
	@echo ........Cleaning $(BUILDDIR)/
	@clear
	@rm -f $(BUILDDIR)/*
	@rmdir $(BUILDDIR)
