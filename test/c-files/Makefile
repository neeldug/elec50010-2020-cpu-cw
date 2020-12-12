# Example usage:
# If you have testbench/my_test.c, you can execute the following to create a MIPS binary
# make testbench/my_test.mips.bin

# For simulator
CC = g++
CPPFLAGS = -W -Wall

# For MIPS binaries. Turn on all warnings, enable all optimisations and link everything statically
MIPS_CC = mipsel-linux-gnu-gcc
MIPS_OBJCOPY = mipsel-linux-gnu-objcopy
MIPS_OBJDUMP = mipsel-linux-gnu-objdump
MIPS_CPPFLAGS = -W -Wall -O3 -fno-builtin -march=mips1 -mfp32
MIPS_LDFLAGS = -nostdlib -Wl,-melf32btsmip -march=mips1 -nostartfiles -mno-check-zero-division -Wl,--gpsize=0 -static -Wl,-Bstatic -Wl,--build-id=none

# Compile C file (.c) into MIPS object file (.o)
%.mips.o: %.c
	$(MIPS_CC) $(MIPS_CPPFLAGS) -c $< -o $@


%.c:
	@echo "Invalid output"
# Assemble MIPS assembly file (.s) into MIPS object file (.o)
%.mips.o: %.s
	$(MIPS_CC) $(MIPS_CPPFLAGS) -c $< -o $@


%.s: %.c
	$(MIPS_CC) $(MIPS_CPPFLAGS) -S $< -o $@

%.asm.txt: %.s
	mv $< ../assembly/$@
# Link MIPS object file (.o), producing .elf, using memory locations specified in spec
%.mips.elf: %.mips.o
	$(MIPS_CC) $(MIPS_CPPFLAGS) $(MIPS_LDFLAGS) -T linker.ld $< -o $@

# Extract binary instructions only from linked object file (.elf)
%.mips.bin: %.mips.elf
	$(MIPS_OBJCOPY) -O binary --only-section=.text $< $@

%.mips.data.bin: %.mips.elf
	$(MIPS_OBJCOPY) -O binary --only-section=.data $< $@

# Disassemble linked object file (.elf), pulling out instructions as MIPS assembly file (.s)
%.mips.s : %.mips.elf
	$(MIPS_OBJDUMP) -j .text -D $< > $@

%.hex.txt : %.mips.bin
	od -An -w1 --endian=little -v -t x1 $< > ../binary/$@; sed -i '1 s/^/@BFC00000\n/' ../binary/$@

%.hex.data.txt : %.mips.data.bin
	od -An -w1 --endian=little -v -t x1 $< > ../data/$@; sed -i '1 s/^/@10000000\n/' ../data/$@

%.bin: %.c
	$(MIPS_CC) $(MIPS_CPPFLAGS) $< -o $@

%.ref.txt : %.bin
	qemu-mipsel -L /usr/mipsel-linux-gnu $<; echo $$? > ../reference/$@

clean :
	rm -rf ../data/* ../binary/* ../assembly/* ../reference/*

## Build simulator
#bin/mips_simulator: src/simulator.cpp
#	mkdir -p bin
#	$(CC) $(CPPFLAGS) src/simulator.cpp -o bin/mips_simulator
#
## Dummy for build simulator to conform to spec
#simulator: bin/mips_simulator
#
## Dummy for build testbench to conform to spec. Could do nothing
#testbench:
#	@echo "Nothing to do"

