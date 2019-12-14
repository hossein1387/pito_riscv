# This code is mostly taken from SERV project by Olof Kindgren
# Please take a look at the project: https://github.com/olofk/serv

%.elf: %.S
	riscv32-unknown-elf-gcc -c -nostartfiles -march=rv32i -mabi=ilp32 -Tlink.ld $< -DTEST_FUNC_NAME=$(notdir $(basename $<)) \
		-DTEST_FUNC_TXT='"$(notdir $(basename $<))"' -DTEST_FUNC_RET=$(notdir $(basename $<))_ret $<
%.bin: %.o
	riscv32-unknown-elf-objcopy -O binary $< $@
%.hex: %.bin
	python3 makehex.py $< 2048 > $@
	python3 add_intr_text.py -i $@
%.txt: %.o
	riscv32-unknown-elf-objdump -D $< > $@

all: %.elf 

clean:
	rm -f *.elf *.bin *.hex *.o 
