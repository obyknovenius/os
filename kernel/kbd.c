#include "io.h"
#include "print.h"
#include "t.h"

enum {
	Data	= 0x60,		/* data port (read/write) */
	Status	= 0x64,		/* status port (read) */
	Cmd	= 0x64,		/* command port (write) */

	InReady	= (1 << 0),	/* input character ready */
	OutBusy	= (1 << 1),	/* output busy */
};

/* controller command byte */
enum {
	CScs1	= (1 << 6),	/* scan code set 1 */
	CAuxDis	= (1 << 5),	/* mouse disable */
	CKbdDis	= (1 << 4),	/* kbd disable */
	CSf	= (1 << 2),	/* system flag */
	CAuxInt	= (1 << 1),	/* mouse interrupt enable */
	CKbdInt	= (1 << 0),	/* kbd interrupt enable */
};

static byte ccb;

static void
delay(int ms) {
	print("delay %d", ms);
}

/*
 * Wait for output no longer busy
 */
static int
outready() {
	int try;

	for (try = 500; try > 0; try--) {
		if (!(inb(Status) & OutBusy)) {
			return 0;
		}
		delay(2);
	}
	return -1;
}

/*
 * wait for input
 */
static int
inready() {
	int try;

	for (try = 500; try > 0; try--) {
		if (inb(Status) & InReady) {
			return 0;
		}
		delay(2);
	}
	return -1;
}

enum {
	Spec	= 0xf800,	/* unicode private use area */
	Shift	= Spec | 0x60,

	No	= 0x00,

	NScan	= 128,
};

int kbtab[NScan] =
{
	No,	No,	'1',	'2',	'3',	'4',	'5',	'6',
	'7',	'8',	'9',	'0',	'-',	'=',	'\b',	'\t',
	'q',	'w',	'e',	'r',	't',	'y',	'u',	'i',
	'o',	'p',	'[',	']',	'\n',	No,	'a',	's',
	'd',	'f',	'g',	'h',	'j',	'k',	'l',	';',
	'\'',	'`',	Shift,	'\\',	'z',	'x',	'c',	'v',
	'b',	'n',	'm',	',',	'.',	'/',	Shift,	No,
};

int kbtabshift[NScan] =
{
	No,	No,	'!',	'@',	'#',	'$',	'%',	'^',
	'&',	'*',	'(',	')',	'_',	'+',	'\b',	'\t',
	'Q',	'W',	'E',	'R',	'T',	'Y',	'U',	'I',
	'O',	'P',	'{',	'}',	'\n',	No,	'A',	'S',
	'D',	'F',	'G',	'H',	'J',	'K',	'L',	':',
	'"',	'~',	Shift,	'|',	'Z',	'X',	'C',	'V',
	'B',	'N',	'M',	'<',	'>',	'?',	Shift,	No,
};

static bool shift;

/*
 * Scan code processing
 */
static void
kbdputsc(int c) {
	int keyup;

	keyup = c & 0x80;
	c &= 0x7f;

	if (shift)
		c = kbtabshift[c];
	else
		c = kbtab[c];

	/* keyup only important for shifts */
	if (keyup) {
		if (c == Shift)
			shift = false;
		return;
	}

	/* special character */
	if (c & Spec) {
		if (c == Shift)
			shift = true;
		return;
	}
	else
		print("%c", c);
}

/*
 * Keyboard interrupt
 */
void
i8042intr() {
	int c;

	/* get the character */
	c = inb(Data);

	kbdputsc(c);
}

static char *initfailed = "i8042: kbdinit failed\n";

static int
outbyte(int port, int c) {
	outb(port, c);
	if (outready() < 0) {
		print(initfailed);
		return -1;
	}
	return 0;
}

void
kbdinit() {
	/* get current controller command byte */
	outb(Cmd, 0x20);
	if (inready() < 0) {
		print("i8042: kbdinit can't read ccb\n");
		ccb = 0;
	}
	else
		ccb = inb(Data);
	
	if (outready() < 0) {
		print(initfailed);
		return;
	}

	/* enable kbd xfers and interrupts */
	ccb &= ~CKbdDis;
	ccb |= CKbdInt | CSf | CScs1;

	if (outready() < 0) {
		print(initfailed);
		return;
	}

	/* disable mouse */
	if (outbyte(Cmd, 0x60) < 0 || outbyte(Data, ccb) < 0) {
		print("i8042: kbdinit mouse disable failed\n");
	}
}
