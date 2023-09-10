#include "mem.h"

	.code16

/*
 * Start:
 *	disables interrputs;
 *	set all segments;
 *	create temporary stack.
 */
 start16r:
	cli				/* interrupts off */

	movw	%cs, %ax
	movw	%ax, %ds		/* set the data segment */

	movw	$0, %ax			/* always put stack in first 64k */
	movw	%ax, %ss
	movw	$PXEBASE, %sp

	movw	$0x2401, %ax		/* enable a20 line */
	int	$0x15

cgaputs:
	movl	$hello, %esi
	xorw	%bx, %bx
cgaputsloop:
	lodsb
	orb	%al, %al
	jz	cgaend

	movb	$0x0e, %ah
	int	$0x10
	jmp	cgaputsloop
cgaend:

/*
 * Try to retrieve the 0xE820 memory map.
 */
 e820:
	movl	$MMAP, %eax
	shrl	$4, %eax
	movw	%ax, %es

	xorw	%di, %di

	xorl	%eax, %eax		/* write terminator */
	stosl

	xorw	%bx, %bx

e820loop:
	movl	$20, %ecx		/* buffer size */
	movl	$0x534d4150, %edx	/* signature - ASCII "SMAP" */
	movl	$0x0000e820, %eax	/* function code */

	int	$0x15			/* writes 20 bytes at ES:DI */

	jc	e820end			/* some kind of error */

	movl	$0x534d4150, %edx
	cmpl	%edx, %eax		/* verify correct BIOS version */
	jne	e820end

	movl	$20, %edx
	cmpl	%edx, %ecx		/* verify corrct count */
	jne	e820end

	subw	$4, %di			/* overwrite terminator */
	movl	%ecx, %eax
	stosl

	addw	$20, %di		/* bump to next entry */

	xorl	%eax, %eax		/* write terminator */
	stosl

	cmpw	$0, %bx			/* zero if last entry */
	jne	e820loop
e820end:

/*
 * Load a basic GDT to map 4GB, turn on the protected mode bit in CR0,
 * set all the segments to point to the new GDT then jump to the 32-bit code.
 */
real:	
	movl	$(gdtdesc - KZERO - PBSBASE), %eax
	lgdtw	(%eax)		/* load a basic gdt */

	movl	%cr0, %eax
	orl	$CR0PE, %eax
	movl	%eax, %cr0		/* turn on protected mode */

	jmpl	$KCSEL, $(start32p - KZERO)

hello:
	.asciz	"Welcome to Utopia\r\n"

gdt:
	.long	0
	.long	0

	.long	0xffff
	.long	(SEGG | SEGD | (0x0f << 16) | SEGP | SEGPL(0) | SEGCODE | SEGR)

	.long	0xffff
	.long	(SEGG | SEGB | (0x0f << 16) | SEGP | SEGPL(0) | SEGDATA | SEGW)

gdtdesc:
	.word	3 * 8
	.long	(gdt - KZERO)
