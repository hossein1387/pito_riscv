#=================================================================================
# Global Variables
#=================================================================================
ROOT_DIR := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
PROJ = $(shell basename $(ROOT_DIR))
SRC_ASM := $(PROJ).S
SRC_OBJ := $(PROJ).obj
#=================================================================================
# Making GCC Acronyms
#=================================================================================

LDFLAGS = -nostartfiles  -nostdlib  -Tlink.ld -Map=$(PROJ).map
CCFLAGS = -march=rv32i -DTEST_FUNC_NAME=$(PROJ) -DTEST_FUNC_RET=$(PROJ)_ret -DTEST_FUNC_TXT='"$(PROJ)"' -Wa,-mno-relax

#=================================================================================
# GCC Acronyms
#=================================================================================
CROSS = riscv32-unknown-elf
CC  = $(CROSS)-gcc
AS  = $(CROSS)-as
LD  = $(CROSS)-ld
OC  = $(CROSS)-objcopy
OD  = $(CROSS)-objdump
CPP = $(CROSS)-cpp

#=================================================================================
# Targets and Rules
#=================================================================================
%.hex:
	$(CC) $(CCFLAGS) -c $(SRC_ASM) -o $(SRC_OBJ)
	$(LD) $(LDFLAGS) -o $(PROJ).elf $(SRC_OBJ)
	$(OD) -D $(PROJ).elf > $(PROJ).obj
	$(OC) -O binary $(PROJ).elf $(PROJ).text --only-section .init --only-section .text
	python3 makehex.py $(PROJ).text 8192 > $(PROJ)_text.hex
	$(OC) -O binary $(PROJ).elf $(PROJ).data --only-section .data --only-section .rodata
	python3 makehex.py $(PROJ).data 8192 > $(PROJ)_data.hex

.PHONY: clean
clean:
	rm -f *.elf *.bin *.hex *.o *.obj *.data *.text *.map
