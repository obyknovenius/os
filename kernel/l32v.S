.globl inb
.globl outb
.globl lidt

/*
 * input a byte
 */
inb:
	movl 4(%esp), %edx
	xorl %eax, %eax
	inb %edx, %al
	ret

/*
 * output a byte
 */
 outb:
	movl 8(%esp), %eax
	movl 4(%esp), %edx
	outb %al, %edx
	ret

/*
 * routines to load/read various system registers
 */
lidt:
	movl 4(%esp), %eax
	lidt (%eax)
	ret
