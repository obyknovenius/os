[bits 32]
global start32p
extern main

start32p:
	mov ax, 0x10
	mov ds, eax
	mov ss, ax

	call main
	hlt
