#include "t.h"
#include "mem.h"
#include "ureg.h"
#include "io.h"
#include "i8259.h"
#include "print.h"

typedef struct Segdesc	Segdesc;

struct Segdesc {
	uint32	d0;
	uint32	d1;
};

void vectortable();
void lidt(uint16* ptr);

/*
 * Minimal trap setup. Just enough so that we can panic
 * on traps (bugs) during kernel initialization.
 * Called very early - malloc is not yet availabe.
 */
 void
 trapinit() {
	int v;
	uint32 vaddr;
	Segdesc *idt;

	uint x;
	uint16 ptr[3];

	idt = (Segdesc*)IDTADDR;
	vaddr = (uint32)vectortable;
	for (v = 0; v < 256; v++) {
		idt[v].d0 = (vaddr & 0xffff) | (KCSEL << 16);
		idt[v].d1 = (vaddr & 0xffff0000) | SEGP | SEGPL(0) | SEGIG;
		vaddr += 6;
	}

	ptr[0] = sizeof(Segdesc) * 255 - 1;
	x = IDTADDR;
	ptr[1] = x & 0xffff;
	ptr[2] = (x >> 16) & 0xffff;
	lidt(ptr);
 }

/*
 * All traps come here. It is slower to have all traps call trap()
 * rather than directly vectoring the handler. However, this avoids a lot
 * of code duplication and possible bugs.
 * Trap is called with interrupts disabled via interrupt-gates.
 */
 void
 trap(Ureg* ureg) {
	int vno;

	vno = ureg->trap;

	if (vno >= VectorPic) {
		if (vno == VectorPic + IrqKbd)
			i8042intr();
		else
			print("interrupt %d\n", vno);

		/* reset IS bit */
		i8259eoi(vno);
	}
 }
