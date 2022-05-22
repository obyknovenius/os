CC=i686-elf-gcc
LD=i686-elf-ld
AS=nasm

OBJ=\
	l16r.o\
	l32p.o\
	cga.o\
	print.o\
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

%.o: %.c
	$(CC) -c $< -o $@

clean:
	rm -f $(OBJ) kernel

.PHONY: all clean