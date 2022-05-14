CC=i686-elf-gcc
LD=i686-elf-ld
AS=nasm

OBJ=\
	l16r.o\
	l32p.o\
	cga.o\
	print.o\
	main.o\

TARG=\
	kernel

all: $(TARG)

kernel: kernel.ld $(OBJ)
	$(LD) -T kernel.ld $(OBJ) --oformat binary -o kernel

%.o: %.asm
	$(AS) -f elf $<

%.o: %.c
	$(CC) -c $< -o $@

clean:
	rm -f $(OBJ) kernel
