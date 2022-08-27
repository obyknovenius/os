int inb(int port);
void outb(int port, int b);

enum {
	VectorPic	= 32,	/* external i8259 interrupts */
};

enum {
	IrqKbd		= 1,
};
