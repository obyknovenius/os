#include "t.h"
#include "io.h"
#include "cga.h"

#define DISPLAYBUF ((byte*)0xB8000)

enum {
	Black,
	Blue,
	Green,
	Cyan,
	Red,
	Magenta,
	Brown,
	Grey,
};

enum {
	Width	= 80 * 2,
	Height	= 25,

	Attr	= (Black << 4) | Grey,
};

static int curpos;

static byte
crtcregr(int index) {
	outb(0x3d4, index);
	return inb(0x3d5) & 0xff;
}

static void
crtcregw(int index, byte data) {
	outb(0x3d4, index);
	outb(0x3d5, data);
}

static void
movecursor() {
	crtcregw(0x0e, (curpos / 2 >> 8) & 0xff);
	crtcregw(0x0f, (curpos / 2) & 0xff);
}

void
cgaputc(int c) {
	int i;

	if (c == '\n') {
		curpos = curpos / Width;
		curpos = (curpos + 1) * Width;
	}
	else if (c == '\t') {
		i = 8 - ((curpos / 2) % 8);
		while (i-- > 0)
			cgaputc(' ');
	}
	else if (c == '\b') {
		if (curpos >= 2)
			curpos -= 2;
		cgaputc(' ');
		curpos -= 2;
	}
	else {
		DISPLAYBUF[curpos++] = c;
		DISPLAYBUF[curpos++] = Attr;
	}
	movecursor();
}

void
cgaputs(char *s) {
	while (*s != '\0')
		cgaputc(*s++);
}

void
cgainit() {
	curpos = crtcregr(0x0e) << 8;
	curpos |= crtcregr(0x0f);
	curpos *= 2;
}
