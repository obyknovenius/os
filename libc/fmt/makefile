include $(ROOT)/$(ARCH)/makefile

LIB=$(ROOT)/$(ARCH)/lib/libc.a

OBJ=\
	dofmt.o\
	vseprint.o\

all: $(LIB)

$(LIB): $(OBJ)
	ar rcs $@ $?

clean:
	rm -f $(LIB) $(OBJ)

.PHONY: all clean
