#include "t.h"
#include "mem.h"
#include "print.h"

typedef struct Segdesc	Segdesc;

struct Segdesc {
	uint32	d0;
	uint32	d1;
};

void vectortable();
void loadidt(uint16* ptr);

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
		idt[v].d0 = (vaddr & 0xFFFF) | (KCSEL << 16);
		idt[v].d1 = (vaddr & 0xFFFF0000) | SEGP | SEGPL(0) | SEGIG;
		vaddr += 6;
	}

	ptr[0] = sizeof(Segdesc) * 255 - 1;
	x = IDTADDR;
	ptr[1] = x & 0xFFFF;
	ptr[2] = (x >> 16) & 0xFFFF;
	loadidt(ptr);
 }

 void
 trap(int intr) {
	print("error: %x", intr);
	asm("hlt");
 }
