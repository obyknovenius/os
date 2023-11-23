#include <t.h>
#include "cga.h"

enum {
	MaxIntWidth = 64
};

enum {
	FmtLong		= 1,
	FmtLongLong	= FmtLong << 1
};

typedef struct Fmt	Fmt;
struct Fmt {
	va_list	args;	/* args passed to dofmt */
	int c;		/* % format char */
	uint8 flags;
};

/* fmt a character */
static void
cfmt(Fmt *f) {
	char c;

	c = va_arg(f->args, char);
	cgaputc(c);
}

/* fmt an integer */
static void
ifmt(Fmt *f) {
	char buf[MaxIntWidth], *p, *conv;
	unsigned long long arg;
	int base, rem, n;
	uint8 fl;

	fl = f->flags;

	if (fl & FmtLongLong) {
		arg = va_arg(f->args, long long);
	}
	else if (fl & FmtLong) {
		arg = va_arg(f->args, long);
	}
	else {
		arg = va_arg(f->args, int);
	}

	conv = "0123456789abcdef";
	switch (f->c) {
	case 'd':
		base = 10;
		break;
	case 'x':
		base = 16;
		break;
	}

	p = buf + sizeof(buf) - 1;
	n = 0;
	while (arg) {
		rem = arg % base;
		arg /= base;
		*p-- = conv[rem];
		n++;
	}

	if (n == 0) {
		*p-- = '0';
		n = 1;
	}

	if (base == 16) {
		n += 2;
		*p-- = f->c;
		*p-- = '0';
	}
	
	p = p + 1;
	for (;n > 0; n--) {
		cgaputc(*p++);
	}
}

static void 
flagfmt(Fmt* f) {
	switch (f->c) {
	case 'l':
		if (f->flags & FmtLong) {
			f->flags |= FmtLongLong;
		}
		f->flags |= FmtLong;
		break;
	}
}

static char*
fmtdispatch(Fmt *f, char *fmt) {
	char c;

	f->flags = 0;

	for (;;) {
		c = *fmt;
		fmt = fmt + 1;
		
		f->c = c;
		switch (c) {
		case 'c':
			cfmt(f);
			return fmt;
		case 'l':
			flagfmt(f);
			break;
		case 'd':
		case 'x':
			ifmt(f);
			return fmt;
		}
	}
}

static void
dofmt(Fmt *f, char *fmt) {
	char c;

	for (;;) {
		while ((c = *fmt) && c != '%') {
			cgaputc(c);
			fmt++;
		}
		fmt++;
		if (!c)
			return;
		fmt = fmtdispatch(f, fmt);
	}
}

static void
vprint(char *fmt, va_list args) {
	Fmt f;

	f.args = args;
	dofmt(&f, fmt);
}

void
print(char *fmt, ...) {
	va_list args;

	va_start(args, fmt);
	vprint(fmt, args);
	va_end(args);
}
