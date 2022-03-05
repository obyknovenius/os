org 0x10000
bits 16

start:
	mov si, hello
	call puts
	hlt

; Output a string to the display.
;   SI  string
puts:
	pusha

	xor bx, bx
.loop:
	lodsb
	or al, al
	jz .ret

	mov ah, 0x0E
	int 0x10
	jmp .loop

.ret:
	popa
	ret

hello:
	db "Welcome to Utopia", 0x0D, 0x0A, 0