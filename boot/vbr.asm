org 0x7c00
bits 16

%define LOADSEG		(0x10000/16)	; where to load code (64KB)
%define LOADOFF		0
%define DIROFF		0x0200		; where to read the root directory
					; (offset)

; FAT directory entry
%define DNAME		0x00
%define DEXT		0x08
%define DATTR		0x0b
%define DSTART		0x1a
%define DLENLO		0x1c
%define DLENHI		0x1e

%define DIRSZ		0x20

; Data is kept on the stack, indexed by BP.
%define DRIVE		0x00		; boot drive, passed by BIOS in DL
%define TOTAL		0x02		; size of allocated data above

; BIOS Parameter Block
magic:					; jmp short start, nop
	db 0xeb, 0x3c
	db 0x90
version:				; mkdosfs
	times 8 db 0
sectsize:				; bytes per sector
	times 2 db 0
clustsize:				; sectors per cluster
	times 1 db 0
nresrv:					; reserved sectors
	times 2 db 0 
nfats:					; number of FAT's
	times 1 db 0
nroots:					; number of root entries
	times 2 db 0
volsize:				; sectors in volume
	times 2 db 0
mediadesc:				; media descriptor type
	times 1 db 0
fatsize:				; sectors per FAT
	times 2 db 0
trksize:				; sectors per track
	times 2 db 0
nheads:					; number of heads
	times 2 db 0
nhidden:				; hidden sectors
	times 4 db 0
bigvolsize:				; sectors in big volume
	times 4 db 0

; Extended Boot Record
driveno:				; drive number
	times 1 db 0
reserved:				; reserved
	times 1 db 0
bootsig:				; signature (0x28 or 0x29)
	times 1 db 0
volid:					; volume id
	times 4 db 0
vollabel:				; volume label string
	times 11 db 0
systmeid:				; system id string
	times 8 db 0

; Boot Code
start:
	cli

	xor ax, ax
	mov ss, ax
	mov ds, ax
	mov es, ax

	mov sp, magic-TOTAL
	mov bp, sp			; set the indexed-data pointer
	mov [bp+DRIVE], dl		; save the boot drive

	mov si, confidence		; for that warm, fuzzy feeling
	call puts

	; DX:AX = nresrv + nfats * fatsize
	mov ax, [fatsize]
	mul byte [nfats]
	add ax, [nresrv]

	call diskreset

	mov bx, magic+DIROFF
	call readsect			; read the root directory

	mov bx, 512/DIRSZ

	mov di, magic+DIROFF		; compare first directory entry

.findboot:				; save for later if it matches
	push di
	mov si, bootfile
	mov cx, DATTR
	repe cmpsb
	pop di
	je .bootfound

	dec bx
	jz perror

	add di, DIRSZ
	jmp .findboot

.bootfound:
	xor bx, bx			; a handy value

	mov ax, [nroots]
	mov cx, DIRSZ
	mul cx

	mov cx, [sectsize]
	div cx
	push ax				; rootsz

	mov ax, [fatsize]
	mul byte [nfats]
	add ax, [nresrv]
	push dx				; roothi
	push ax				; rootlo

	; DI points to matching directory entry
	mov ax, [di+DSTART]		; first cluster number
	dec ax				; 0 and 1 are reserved
	dec ax
	mov cl, [clustsize]
	xor ch, ch
	mul cx

	pop cx				; rootlo
	add ax, cx
	pop cx				; roothi
	adc dx, cx
	pop cx				; rootsz
	add ax, cx
	adc dx, bx
	push ax
	push dx

	; calculate how many sectors to read
	mov ax, [di+DLENLO]
	mov dx, [di+DLENHI]
	mov cx, [sectsize]
	push cx
	dec cx
	add ax, cx
	adc dx, bx
	pop cx
	div cx
	mov cx, ax
	pop dx
	pop ax

	mov bx, LOADSEG			; address to load into (seg+offset)
	mov es, bx			; seg
	mov bx, LOADOFF			; offset

.readboot:
	call readsect			; read the sector

	mov di, [sectsize]		; bump addresses/counts
	add bx, di
	jnb .incsectno

	mov di, es			; next 64KB segment
	add di, 0x1000
	mov es, di

.incsectno:
	xor di, di
	inc ax
	adc dx, di
	loop .readboot

	mov di, LOADSEG			; set DS for loaded code
	mov ds, di
	jmp LOADSEG:LOADOFF		; no deposit, no return

; Reset disk system
diskreset:
	pusha

	xor ax, ax			; AH = 0x00
	mov dl, [bp+DRIVE]		; DL = drive
	int 0x13
	jc perror			; CF set on error

	popa
	ret

; Read a sector from a disk.
;   DX:AX   sector number
;   ES:BX   buffer address
readsect:
	pusha
	push bx

	mov bx, [trksize]
	imul bx, [nheads]
	or bx, bx
	jz pioerror
	div bx				; AX = cylinder, DX = sector

	mov cx, ax			; save cylinder
	rol cx, 8			; CH = low 8 bist of cylinder
	shl cl, 6			; CL = hight 2 bits of cylinder
					; (bits 6-7)

	mov ax, dx
	xor dx, dx
	mov bx, [trksize]
	div bx				; AX = head, DX = sector

	inc dx				; sector numbers are 1-based
	and dx, 0x003f
	or cx, dx			; CL = sector number (bits 0-5)

	mov dx, ax
	rol dx, 8			; DH = head
	mov dl, [bp+DRIVE]		; DL = drive

	mov ax, 0x0201			; AH = 0x02
					; AL = 1 - read one sector
	
	pop bx
	int 0x13
	jc pioerror			; CF set on error

	popa
	ret

; Output a string to the display.
;   SI  string
puts:
	pusha

	xor bx, bx
.loop:
	lodsb
	or al, al
	jz .ret

	mov ah, 0x0e
	int 0x10
	jmp .loop

.ret:
	popa
	ret

perror:
	mov si, error
	call puts
	hlt

pioerror:
	mov si, ioerror
	call puts
	hlt

confidence:
	db "MBR...", 0x0d, 0x0a, 0
error:
	db "Error", 0x0d, 0x0a, 0
ioerror:
	db "I/O error", 0x0d, 0x0a, 0
bootfile:
	db "KERNEL     "

	times 510-($-$$) db 0
	dw 0xaa55
