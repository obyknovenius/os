#include "cga.h"
#include "print.h"
#include "trap.h"
#include "i8259.h"

void sti();

void
main() {
	cgainit();

	print("Enjoy Your Journey\n");

	trapinit();

	i8259init();

	print("Press any key\n");

	sti();

	for(;;)
		;
}
