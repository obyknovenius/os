CC=i686-elf-gcc
LD=i686-elf-ld
AS=nasm

OBJ=\
	l16r.o\
	l32p.o\
	l32v.o\
	l.o\
	cga.o\
	print.o\
	trap.o\
	i8259.o\
	kbd.o\
	main.o

LIBCC=\
	${shell $(CC) --print-libgcc-file-name}

TARG=\
	kernel

all: $(TARG)

kernel: kernel.ld $(OBJ)
	$(LD) -T kernel.ld $(OBJ) $(LIBCC) -o kernel

%.o: %.asm
	$(AS) -f elf $<

%.o: %.S
	i686-elf-gcc -c $< -o $@

%.o: %.c
	$(CC) -c $< -o $@

clean:
	rm -f $(OBJ) kernel

.PHONY: all clean
