#define DISPLAYBUF ((unsigned char*)0xB8000)

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

unsigned char inb(int port);
void outb(int port, unsigned char b);

static unsigned char
crtcregr(int index) {
	outb(0x3D4, index);
	return inb(0x3D5) & 0xFF;
}

static void
crtcregw(int index, unsigned char data) {
	outb(0x3D4, index);
	outb(0x3D5, data);
}

static void
movecursor() {
	crtcregw(0x0E, (curpos / 2 >> 8) & 0xFF);
	crtcregw(0x0F, (curpos / 2) & 0xFF);
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
	else {
		DISPLAYBUF[curpos++] = c;
		DISPLAYBUF[curpos++] = Attr;
	}
	movecursor();
}

void
cgaputs(char* s) {
	while (*s != '\0')
		cgaputc(*s++);
}

void
cgainit() {
	curpos = crtcregr(0x0E) << 8;
	curpos |= crtcregr(0x0F);
	curpos *= 2;
}