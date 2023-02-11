#include "mem.h"

/*
 * Macro for calculating offset within the page directory
 */
#define PDO(a)	(((a) >> 22) << 2)

	.globl	start32p
start32p:
	movw	$KDSEL, %ax
	movw	%ax, %ds
	movw	%ax, %es
	movw	%ax, %fs
	movw	%ax, %gs
	movw	%ax, %ss

start32pg:
	movl	$end - KZERO, %edx	/* clear pages for the tables etc. */
	addl	$(BY2PG - 1), %edx	/* start must be page aligned */
	andl	$~(BY2PG - 1), %edx

	/*
	 * zero page direcotry and page tables for low memory
	 */
	movl	%edx, %edi		/* first page after end */
	xorl	%eax, %eax
	movl	$((1 + LOWPTEPAGES) * BY2PG), %ecx /* page dir + page tables */
	shrl	$2, %ecx
	rep
	stosl

	/*
	 * populate page directory for low memory (20MB)
	 */
	movl	%edx, %eax		/* phys addr of page directory */
	movl	%edx, %edi		/* save it for later */
	movl	$(PTEP | PTERW), %ebx	/* page permissions */

	addl	$BY2PG, %edx		/* phys addr of first page table */
	addl	$PDO(KZERO), %eax	/* page dir offset for KZERO */
	movl	%edx, (%eax)		/* PTE for KZERO */
	orl	%ebx, (%eax)

	/* should be LOWPTEPAGES - 1 repetitions of the fragment */
	addl	$BY2PG, %edx		/* phys addr of second page table */
	addl	$4, %eax		/* page dir offset for KZERO + 4MB */
	movl	%edx, (%eax)		/* PTE's for KZERO + 4MB */
	orl	%ebx, (%eax)

	addl	$BY2PG, %edx		/* phys addr of third page table */
	addl	$4, %eax		/* PD offset for KZERO + 8MB */
	movl	%edx, (%eax)		/* PTE's for KZERO + 8MB */
	orl	%ebx, (%eax)

	addl	$BY2PG, %edx		/* phys addr of fourth page table */
	addl	$4, %eax		/* page dir offset for KZERO + 12MB */
	movl	%edx, (%eax)		/* PTE's for KZERO + 12MB */
	orl	%ebx, (%eax)

	addl	$BY2PG, %edx		/* phys addr of fifth page table*/
	addl	$4, %eax		/* page dir offset for KZERO + 16MB */
	movl	%edx, (%eax)		/* PTE's for KZERO + 16MB */
	orl	%ebx, (%eax)

	/*
	 * populate page tables for low memory
	 */
	movl	%edi, %eax
	addl	$BY2PG, %eax		/* phys addr of first page table */
	movl	$(MEMMIN / BY2PG), %ecx
setpte:
	movl	%ebx, (%eax)
	addl	$(1 << PGSHIFT), %ebx
	addl	$4, %eax
	loop	setpte

	movl	%edi, %ecx		/* load address of page directory */
	/* double-map first 20MB */
	/* should be LOWPTEPAGES repetitions */
	movl	PDO(KZERO)(%ecx), %edx	/* double-map KZERO at 0 */
	movl	%edx, PDO(0)(%ecx)
	movl	PDO(KZERO + 4 * MB)(%ecx), %edx
	movl	%edx, PDO(4 * MB)(%ecx)
	movl	PDO(KZERO + 8 * MB)(%ecx), %edx
	movl	%edx, PDO(8 * MB)(%ecx)
	movl	PDO(KZERO + 12 * MB)(%ecx), %edx
	movl	%edx, PDO(12 * MB)(%ecx)
	movl	PDO(KZERO + 16 * MB)(%ecx), %edx
	movl	%edx, PDO(16 * MB)(%ecx)
	movl	%ecx, %cr3

	movl	%cr0, %edx
	orl	$(CR0PG | CR0WP), %edx
	movl	%edx, %cr0		/* turn on paging */

	call	main
