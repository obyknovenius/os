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
 * wait for output no longer busy
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

/*
 * keyboard interrupt
 */
void
i8042intr() {
	int sc;

	/* get the scan code */
	sc = inb(Data);

	print("scan code: %x\n", sc);
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
	} else
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
