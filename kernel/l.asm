[bits 32]
global vectortable

%define SELECTOR(i)	((i)<<3)

vectortable:
    mov ax, SELECTOR(2)
    mov gs, ax
    mov dword [gs:0xB8000],') : '
    hlt
