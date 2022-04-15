# This code was inspired by SERV 

PROJ  =$(notdir $(basename $<))
LDFLAGS = -Tlink.ld #-Map=$(basename $<).map
CCFLAGS = -nostartfiles -march=rv32i -DTEST_FUNC_NAME=$(PROJ) -DTEST_FUNC_RET=$(PROJ)_ret -DTEST_FUNC_TXT='"$(PROJ)"'


CROSS = riscv32-unknown-elf
CC  = $(CROSS)-gcc
AS  = $(CROSS)-as
LD  = $(CROSS)-ld
OC  = $(CROSS)-objcopy
OD  = $(CROSS)-objdump
CPP = $(CROSS)-cpp

%.elf: %.S
	$(CC) $(CCFLAGS) $(LDFLAGS) $< -o $(PROJ).elf
%.defs: %.S
	$(CC) -E $(CCFLAGS) $(LDFLAGS) -mabi=ilp32 $< > $(PROJ).i
%.obj: %.elf
	$(OD) -D $(PROJ).elf > $(PROJ).obj
%.test: %.S
	$(CC) $(CCFLAGS) $(LDFLAGS) $< -o $(PROJ).elf
	$(OD) -D $(PROJ).elf > $(PROJ).obj
	python3 makehex.py $(PROJ).elf 2048 > $(PROJ).hex
%.bin: %.elf
	$(OC) -O binary $< $@
%.hex: %.bin
	python3 makehex.py $< 8192 > $@
clean:
	rm -f *.elf *.bin *.hex *.o *.obj 
