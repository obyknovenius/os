include $(ROOT)/$(ARCH)/makefile

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
	$(LD) $(LDFLAGS) -T kernel.ld $(OBJ) $(LIBCC) -lc -o kernel

clean:
	rm -f $(OBJ) kernel

.PHONY: all clean
