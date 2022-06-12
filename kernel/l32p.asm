[bits 32]
global start32p
global inb,outb
global loadidt
extern main

start32p:
	mov ax, 0x10
	mov ds, eax
	mov ss, ax

	call main
	hlt

; input a byte
inb:
	mov dx, [esp+4]
	in al, dx
	ret

; output a byte
outb:
	mov al, [esp+8]
	mov dx, [esp+4]
	out dx, al
	ret

; load interrupt descriptor table
loadidt:
	mov eax, [esp+4]
	lidt [eax]
	ret
