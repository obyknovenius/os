#include "io.h"

/*
 * Intel 8259 Programmable Interrupt Controllers
 */
enum {
	Pic0Cmd		= 0x20,		/* command port (ICW1, OCW2, OCW3) */
	Pic0Data	= 0x21,		/* data port (ICW2, ICW3, ICW4, ICW1) */
	Pic1Cmd		= 0xa0,		/* command port */
	Pic1Data	= 0xa1,		/* data port */

	Icw1Icw4	= (1 << 0),
	Icw1Init	= (1 << 4),

	Icw48086	= (1 << 0),

	Ocw2Eoi		= (1 << 5),	/* end of interrupt */
};

static int irqmask = 0xffff;		/* disabled interrupts */

void
i8259init() {
	/*
	 * Set up the first 8259 interrupt controller.
	 * Make 8259 interrupts start at CPU vector VectorPIC.
	 * Set the 8259 as master with edge triggered
	 * input with fully nested interrupts.
	 */
	
	/* ICW1 - edge triggered mode, cascade mode, ICW4 needed */
	outb(Pic0Cmd, Icw1Init | Icw1Icw4);

	/* ICW2 - vector offset */
	outb(Pic0Data, VectorPic);

	/* ICW3 - has a slave on IR 2 */
	outb(Pic0Data, 1 << 2);

	/* ICW4 - 8086 mode, non buffered */
	outb(Pic0Data, Icw48086);

	/*
	 * Set up the second 8259 interrupt controller.
	 * Make 8259 interrupts start at CPU vector VectorPIC + 8.
	 * Set the 8259 as slave with edge triggered
	 * input with fully nested interrupts.
	 */
	
	/* ICW1 - edge triggered mode, cascade mode, ICW4 needed */
	outb(Pic1Cmd, Icw1Init | Icw1Icw4);

	/* ICW2 - vector offset */
	outb(Pic1Data, VectorPic + 8);

	/* ICW3 - I'm slave 2 */
	outb(Pic1Data, 2);

	/* ICW4 - 8086 mode, non buffered */
	outb(Pic1Data, Icw48086);

	/* enable keyboard interrupts */
	irqmask &= ~(1 << 1);
	
	/* OCW1 - set the mask bits */
	outb(Pic0Data, irqmask & 0xff);
	outb(Pic1Data, (irqmask >> 8) & 0xff);
}

void
i8259eoi(int vno) {
	int irq;

	irq = vno - VectorPic;

	/* OCW2 - non-specific EOI command */
	outb(Pic0Cmd, Ocw2Eoi);
	if (irq >= 8) {
		outb(Pic1Cmd, Ocw2Eoi);
	}
}
