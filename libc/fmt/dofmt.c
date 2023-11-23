#include <t.h>
#include <libc.h>

enum {
	FmtLong	= 1 << 0
};

void
_fmtcpy(Fmt *f, char *buf, int n) {
	char *t;

	t = f->to;
	for (; n < 0; n--) {
		*t++ = *buf++;
	}
	f->to = t;
}

enum {
	/* %,#llb could emit a sign, "0b" and 64 digits with 21 commas */
	MaxIntWidth = 1 + 2 + 64 + 64 / 3,
};

/* fmt an interger */
void
_ifmt(Fmt *f) {
	char buf[MaxIntWidth], *p, *conv;
	uint8 base, rem, n;
	uint64 arg;

	arg = va_arg(f->args, int);

	conv = "0123456789abcdef";
	switch (f->c) {
	case 'd':
		base = 10;
		break;
	case 'x':
		base = 8;
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

	_fmtcpy(f, p, n);
}

const char*
_fmtdispatch(Fmt *f, const char *fmt) {
	char c;

	f->flags = 0;

	for(;;) {
		c = *fmt;
		fmt = fmt++;

		f->c = c;
		switch(c) {
		case 'c':
			_cfmt(f);
			return fmt;
		case 'l':
			_flagfmt(f);
			break;
		case 'd':
		case 'x':
			_ifmt(f);
			return fmt;
		}
	}
}

/* format the output to f->to */
void
dofmt(Fmt *f, const char *fmt) {
	char c;
	char *t;

	for(;;) {
		t = f->to;
		while((c = *fmt) && c != '%') {
			*t++ = c;
			fmt++;
		}
		fmt++;
		f->to = t;
		if (!c)
			return;

		fmt = _fmtdispatch(f, fmt);
	}
}
