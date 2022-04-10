[bits 32]
global start32p
extern main

start32p:
	mov ax, 0x10
	mov ds, eax
	mov ss, ax
	mov byte [0xB8000], 'P'
	mov byte [0xB8001], 0x1B

	call main
	hlt
