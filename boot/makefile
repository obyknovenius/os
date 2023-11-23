AS=nasm

TARG=\
	vbr

all: $(TARG)

%: %.asm
	$(AS) -f bin $<

clean:
	rm -f vbr

.PHONY: all clean