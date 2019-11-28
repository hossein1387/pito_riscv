# This code is mostly taken from SERV project by Olof Kindgren
# Please take a look at the project: https://github.com/olofk/serv

%.elf: %.S
	riscv32-unknown-elf-gcc -nostartfiles -march=rv32i -mabi=ilp32 -Tlink.ld -o$@ $<
%.bin: %.elf
	riscv32-unknown-elf-objcopy -O binary $< $@
%.hex: %.bin
	python3 makehex.py $< 2048 > $@
%.txt: %.elf
	riscv32-unknown-elf-objdump -D $< > $@
clean:
	rm -f *.elf *.bin *.hex
