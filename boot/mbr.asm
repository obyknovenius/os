org 0x7C00
bits 16

start:
    cli

    mov si, confidence  ; for that warm, fuzzy feeling
    call puts

    hlt

; Output a string to the display.
; String argument is in si.
puts:
    pusha

    lodsb
    or al, al
    jz .ret

    mov ah, 0x0E
    int 0x10
    jmp puts

.ret:
    popa
    ret


confidence db "MBR...", 0x0D, 0X0A, 0

times 510-($-$$) db 0
dw 0xAA55