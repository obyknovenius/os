#include "io.h"

/*
 * Intel 8259 Programmable Interrupt Controllers
 */
enum {
	Pic0Cmd	= 0x20,		/* command port (ICW1, OCW2, OCW3) */
	Pic0Dat	= 0x21,		/* data (ICW2, ICW3, ICW4, ICW1) */
	Pic1Cmd	= 0xA0,		/* command port */
	Pic1Dat	= 0xA1,		/* data else */

	Icw1Init	= 1 << 4,
	Icw1Icw4	= 1 << 0,

	Icw48086	= 1 << 0,
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
	outb(Pic0Cmd, Icw1Init | Icw1Icw4);	/* ICW1 - edge, cascade, ICW4 */
	outb(Pic0Dat, VectorPic);		/* ICW2 - vector offset */
	outb(Pic0Dat, 1 << 2);			/* ICW3 - has a slave on IR 2 */
	outb(Pic0Dat, Icw48086);		/* ICW4 - 8086, non buffered */

	/*
	 * Set up the second 8259 interrupt controller.
	 * Make 8259 interrupts start at CPU vector VectorPIC + 8.
	 * Set the 8259 as slave with edge triggered
	 * input with fully nested interrupts.
	 */
	outb(Pic1Cmd, Icw1Init | Icw1Icw4);	/* ICW1 - edge, cascade, ICW4 */
	outb(Pic1Dat, VectorPic + 8);		/* ICW2 - vector offset */
	outb(Pic1Dat, 2);			/* ICW3 - I'm slave 2 */
	outb(Pic1Dat, Icw48086);		/* ICW4 - 8086, non buffered */

	i8259mask &= ~(1 << 1);			/* enable keyboard interrupts */
	
	outb(Pic0Dat, i8259mask & 0xFF);	/* OCW1 */
	outb(Pic1Dat, (i8259mask >> 8) & 0xFF);	/* OCW1 */
}
