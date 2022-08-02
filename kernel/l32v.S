/*
 * input a byte
 */
	.globl inb
inb:
	movl 4(%esp), %edx
	xorl %eax, %eax
	inb %edx, %al
	ret

/*
 * output a byte
 */
	.globl outb
 outb:
	movl 8(%esp), %eax
	movl 4(%esp), %edx
	outb %al, %edx
	ret

/*
 * routines to load/read various system registers
 */
	.globl lidt
lidt:
	movl 4(%esp), %eax
	lidt (%eax)
	ret
