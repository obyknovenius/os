all: kernel

kernel: kernel.ld l16r.o l32p.o
	i686-elf-ld -T kernel.ld l16r.o l32p.o --oformat binary -o kernel

l16r.o: l16r.asm
	nasm -f elf $<

l32p.o: l32p.asm
	nasm -f elf $<

clean:
	rm -f l16r.o l32p.o kernel