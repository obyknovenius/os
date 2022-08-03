#include "io.h"

/*
 * Intel 8259 Programmable Interrupt Controllers
 */
enum {
	Pic0Cmd		= 0x20,		/* command port (ICW1, OCW2, OCW3) */
	Pic0Dat		= 0x21,		/* data port (ICW2, ICW3, ICW4, ICW1) */
	Pic1Cmd		= 0xA0,		/* command port */
	Pic1Dat		= 0xA1,		/* data port */

	Icw1Init	= 1 << 4,
	Icw1Icw4	= 1 << 0,

	Icw48086	= 1 << 0,

	Ocw2Eoi		= 1 << 5,		/* end of interrupt */
};

static int i8259mask = 0xFFFF;	/* disabled interrupts */

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
	outb(Pic0Dat, VectorPic);

	/* ICW3 - has a slave on IR 2 */
	outb(Pic0Dat, 1 << 2);

	/* ICW4 - 8086 mode, non buffered */
	outb(Pic0Dat, Icw48086);

	/*
	 * Set up the second 8259 interrupt controller.
	 * Make 8259 interrupts start at CPU vector VectorPIC + 8.
	 * Set the 8259 as slave with edge triggered
	 * input with fully nested interrupts.
	 */
	
	/* ICW1 - edge triggered mode, cascade mode, ICW4 needed */
	outb(Pic1Cmd, Icw1Init | Icw1Icw4);

	/* ICW2 - vector offset */
	outb(Pic1Dat, VectorPic + 8);

	/* ICW3 - I'm slave 2 */
	outb(Pic1Dat, 2);

	/* ICW4 - 8086 mode, non buffered */
	outb(Pic1Dat, Icw48086);

	/* enable keyboard interrupts */
	i8259mask &= ~(1 << 1);
	
	/* OCW1 - set the mask bits */
	outb(Pic0Dat, i8259mask & 0xFF);
	outb(Pic1Dat, (i8259mask >> 8) & 0xFF);
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
