#include "mem.h"

	.globl start32p
start32p:
	movw $KDSEL, %ax
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %fs
	movw %ax, %gs
	movw %ax, %ss

	call main
	hlt
