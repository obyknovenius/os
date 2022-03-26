org 0x10000
bits 16

; fields in segment descriptors
%define SEGG	(1<<23)			; granularity 1=4k
%define	SEGB	(1<<22)			; big 1=32bit (for stack)
%define SEGD	(1<<22)			; default 1=32bit (for code)

%define SEGP	(1<<15)			; present
%define	SEGPL(x)((x)<<13)		; priority level
%define SEGS	(1<<12)			; system

%define SEGE	(1<<10)			; expand down (for data)
%define SEGW	(1<<9)			; writable (for data)
%define SEGC	(1<<10)			; conforming (for code)
%define SEGR	(1<<9)			; readable (for code)

%define SEGDATA (SEGS)
%define SEGCODE (SEGS|1<<11)

%define SELECTOR(i)	((i)<<3)

; Start:
;	disable iterrupts
;	set all segments
;	create temporary stack
start16r:
	cli				; interrupts off

	mov ax, cs
	mov ds, ax			; set the data segment

	mov ax, 0			; always put stack in first 64k
	mov ss, ax
	mov sp, 0x7C00			; set the stack

	mov ax, 0x2401			; enable a20 line
	int 0x15

; Load a basic GDT to map 4GB, turn on the protection mode bit in CR0,
; set all the segments to point to the new GDT then jump to the 32-bit code.
	lgdt [gdtdesc]			; load a basic GDT

	mov eax, cr0
	or eax, 1
	mov cr0, eax			; turn on protection mode

	jmp dword 0x08:start32p

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

gdt:
	dd 0x00000000, 0x00000000
	dd 0x0000FFFF, (SEGG|SEGD|(0xF<<16)|SEGP|SEGPL(0)|SEGCODE|SEGR)
	dd 0x0000FFFF, (SEGG|SEGB|(0xF<<16)|SEGP|SEGPL(0)|SEGDATA|SEGW)

gdtdesc:
	dw gdtdesc-gdt
	dd gdt

[bits 32]
start32p:
	mov ax, 0x10
	mov ds, eax
	mov ss, ax
	mov byte [0xB8000], 'P'
	mov byte [0xB8001], 0x1B
	hlt