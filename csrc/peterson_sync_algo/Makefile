# This code is mostly taken from SERV project by Olof Kindgren
# Please take a look at the project: https://github.com/olofk/serv

%.elf: %.c
	riscv32-unknown-elf-gcc -nostartfiles -march=rv32i -Tlink.ld -DTEST_FUNC_NAME=$(notdir $(basename $<)) \
		-DTEST_FUNC_TXT='"$(notdir $(basename $<))"' -DTEST_FUNC_RET=$(notdir $(basename $<))_ret $< -c crt0.S -nostdlib -std=gnu99 -ffast-math -fno-common -fno-builtin-printf
	riscv32-unknown-elf-gcc -nostartfiles -march=rv32i -Tlink.ld -DTEST_FUNC_NAME=$(notdir $(basename $<)) \
		-DTEST_FUNC_TXT='"$(notdir $(basename $<))"' -DTEST_FUNC_RET=$(notdir $(basename $<))_ret $< crt0.o -o $(notdir $(basename $<)).elf
	riscv32-unknown-elf-objdump -D $(notdir $(basename $<)).elf > $(notdir $(basename $<)).obj
%.elf: %.S
	riscv32-unknown-elf-gcc -nostartfiles -march=rv32i -Tlink.ld -DTEST_FUNC_NAME=$(notdir $(basename $<)) \
		-DTEST_FUNC_TXT='"$(notdir $(basename $<))"' -DTEST_FUNC_RET=$(notdir $(basename $<))_ret $< -o $(notdir $(basename $<)).elf
%.defs: %.S
	riscv32-unknown-elf-gcc -E -nostartfiles -march=rv32i -mabi=ilp32 -Tlink.ld -DTEST_FUNC_NAME=$(notdir $(basename $<)) \
		-DTEST_FUNC_TXT='"$(notdir $(basename $<))"' -DTEST_FUNC_RET=$(notdir $(basename $<))_ret $< > $(notdir $(basename $<)).i
%.obj: %.elf
	riscv32-unknown-elf-objdump -D $(notdir $(basename $<)).elf > $(notdir $(basename $<)).obj
%.test: %.S
	riscv32-unknown-elf-gcc -nostartfiles -march=rv32i -Tlink.ld -DTEST_FUNC_NAME=$(notdir $(basename $<)) \
		-DTEST_FUNC_TXT='"$(notdir $(basename $<))"' -DTEST_FUNC_RET=$(notdir $(basename $<))_ret $< -o $(notdir $(basename $<)).elf
	riscv32-unknown-elf-objdump -D $(notdir $(basename $<)).elf > $(notdir $(basename $<)).obj
	python3 makehex.py $(notdir $(basename $<)).elf 2048 > $(notdir $(basename $<)).hex
%.bin: %.elf
	riscv32-unknown-elf-objcopy -O binary $< $@
%.hex: %.bin
	python3 makehex.py $< 8192 > $@
clean:
	rm -f *.elf *.bin *.hex *.o *.obj 
