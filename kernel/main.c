#include "cga.h"
#include "print.h"
#include "trap.h"
#include "i8259.h"
#include "kbd.h"

void sti();

void
main() {
	cgainit();

	print("Enjoy Your Journey\n");

	trapinit();
	kbdinit();
	i8259init();

	print("Type someting\n");

	sti();

	for(;;)
		;
}
