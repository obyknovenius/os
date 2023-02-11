CC=i686-elf-gcc
LD=i686-elf-ld

ASFLAGS=-Wa,--divide

OBJ=\
	l16r.o\
	l32p.o\
	l32v.o\
	l.o\
	cga.o\
	print.o\
	mmap.o\
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

clean:
	rm -f $(OBJ) kernel

.PHONY: all clean
