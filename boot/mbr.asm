org 0x7C00
bits 16

DIROFF  equ 0x0200 ; where to read the root directory (offset)

; We keep data on the stack, indexed by BP.
DRIVE   equ 0x00    ; boot drive, passed by BIOS in DL
TOTAL   equ 0x02    ; size of allocated data above

; BIOS Parameter Block
magic:              ; jmp short start, nop
    db 0xEB, 0x3C
    db 0x90
version:            ; mkdosfs
    times 8 db 0
sectsize:           ; bytes per sector
    times 2 db 0
clustsize:          ; sectors per cluster
    times 1 db 0
nresrv:             ; reserved sectors
    times 2 db 0 
nfats:              ; number of FAT's
    times 1 db 0
rootsize:           ; number of root entries
    times 2 db 0
volsize:            ; sectors in volume
    times 2 db 0
mediadesc:          ; media descriptor type
    times 1 db 0
fatsize:            ; sectors per FAT
    times 2 db 0
trksize:            ; sectors per track
    times 2 db 0
nheads:             ; number of heads
    times 2 db 0
nhidden:            ; hidden sectors
    times 4 db 0
bigvolsize:         ; sectors in big volume
    times 4 db 0

; Extended Boot Record
driveno:            ; drive number
    times 1 db 0
reserved:
    times 1 db 0
bootsig:            ; signature (0x28 or 0x29)
    times 1 db 0
volid:              ; volume id
    times 4 db 0
vollabel:           ; volume label string
    times 11 db 0
systmeid:           ; system id string
    times 8 db 0

; Boot Code
start:
    cli

    xor ax, ax
    mov ss, ax
    mov ds, ax
    mov es, ax

    mov sp, magic-TOTAL
    mov bp, sp          ; set the indexed-data pointer
    mov [bp+DRIVE], dl  ; save the boot drive

    mov si, confidence  ; for that warm, fuzzy feeling
    call puts

    ; DX:AX = nresrv + nfats * fatsize
    mov ax, [fatsize]
    mul byte [nfats]
    add ax, [nresrv]

    call dreset

    mov bx, magic+DIROFF
    call read           ; read the root directory

    hlt

; Reset disk system
dreset:
    pusha

    xor ax, ax          ; AH = 0x00
    mov dl, [bp+DRIVE]  ; DL = drive
    int 0x13
    jc perror           ; CF set on error

    popa
    ret

; Read a sector from a disk.
;   DX:AX   sector number
;   ES:BX   buffer address
read:
    pusha
    push bx

    mov bx, [trksize]
    imul bx, [nheads]
    or bx, bx
    jz perror
    div bx              ; AX = cylinder, DX = sector

    mov cx, ax          ; save cylinder
    rol cx, 8           ; CH = low 8 bist of cylinder
    shl cl, 6           ; CL = hight 2 bits of cylinder (bits 6-7)

    mov ax, dx
    xor dx, dx
    mov bx, [trksize]
    div bx              ; AX = head, DX = sector

    inc dx              ; sector numbers are 1-based
    and dx, 0x003F
    or cx, dx           ; CL = sector number (bits 0-5)

    mov dx, ax
    rol dx, 8           ; DH = head
    mov dl, [bp+DRIVE]  ; DL = drive

    mov ax, 0x0201      ; AH = 0x02
                        ; AL = 1 - read one sector
    
    pop bx
    int 0x13
    jc perror           ; CF set on error

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

    mov ah, 0x0E
    int 0x10
    jmp .loop

.ret:
    popa
    ret

perror:
    mov si, error
    call puts
    hlt

confidence: db "MBR...", 0x0D, 0x0A, 0
error: db "Error", 0x0D, 0x0A, 0

times 510-($-$$) db 0
dw 0xAA55