#include "cga.h"
#include "print.h"
#include "trap.h"

void
main() {
	cgainit();

	print("Enjoy Your Journey\n");

	trapinit();

	asm("int $0x00");
	print("after interrupt\n");
}
