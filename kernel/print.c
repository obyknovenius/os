#include "stdarg.h"
#include "cga.h"

enum {
	MaxIntWidth = 64
};

typedef struct Fmt	Fmt;
struct Fmt {
	va_list	args;	/* args passed to dofmt */
	int c;		/* % format char */
};

/* fmt an integer */
void ifmt(Fmt *f) {
	char buf[MaxIntWidth], *p, *conv;
	unsigned long u;
	int base, i, n, rem;

	u = va_arg(f->args, int);

	conv = "0123456789abcdef";
	switch(f->c) {
	case 'd':
		base = 10;
		break;
	case 'x':
		base = 16;
		break;
	}

	p = buf + sizeof(buf) - 1;
	n = 0;
	while(u) {
		i = u % base;
		u /= base;
		*p-- = conv[i];
		n++;
	}

	if(n == 0) {
		*p-- = '0';
		n = 1;
	}

	if(base == 16) {
		n += 2;
		*p-- = f->c;
		*p-- = '0';
	}
	
	p = p + 1;
	for(;n > 0; n--) {
		cgaputc(*p++);
	}
}

char*
fmtdispatch(Fmt *f, char *fmt) {
	char c;

	for(;;) {
		c = *fmt;
		fmt = fmt + 1;
		
		f->c = c;
		switch(c) {
		case 'd':
		case 'x':
			ifmt(f);
			return fmt;
		}
	}
}

void
dofmt(Fmt *f, char *fmt) {
	char c;

	for(;;) {
		while((c = *fmt) && c != '%') {
			cgaputc(c);
			fmt++;
		}
		fmt++;
		if(!c)
			return;
		fmt = fmtdispatch(f, fmt);
	}
}

void
vfprint(char *fmt, va_list args) {
	Fmt f;

	f.args = args;
	dofmt(&f, fmt);
}

void
print(char *fmt, ...) {
	va_list args;

	va_start(args, fmt);
	vfprint(fmt, args);
	va_end(args);
}
