; Mide un bucle de trabajo fijo con la hora de DOS (INT 21h, funcion 2Ch).
; El contador externo es 200 en las tres corridas. Solo cambia cycles en DOSBox.
org 0x100

section .text
    mov  ah, 09h
    mov  dx, msg_inicio
    int  21h
    mov  ah, 2Ch
    int  21h
    mov  [hora1], ch
    mov  [min1], cl
    mov  [seg1], dh
    mov  [cc1], dl
    mov  cx, 200             ; bucle externo. Igual en las 3 corridas.
trabajo_ext:
    push cx
    mov  cx, 0FFFFh          ; bucle interno: 65535 iteraciones
trabajo_int:
    inc  ax
    loop trabajo_int
    pop  cx
    loop trabajo_ext
    mov  ah, 2Ch
    int  21h
    mov  [hora2], ch
    mov  [min2], cl
    mov  [seg2], dh
    mov  [cc2], dl
    mov  ah, 09h
    mov  dx, msg_t1
    int  21h
    mov  al, [hora1]
    call print_dec2
    mov  ah, 09h
    mov  dx, sep
    int  21h
    mov  al, [min1]
    call print_dec2
    mov  ah, 09h
    mov  dx, sep
    int  21h
    mov  al, [seg1]
    call print_dec2
    mov  ah, 09h
    mov  dx, sep
    int  21h
    mov  al, [cc1]
    call print_dec2
    mov  ah, 09h
    mov  dx, msg_t2
    int  21h
    mov  al, [hora2]
    call print_dec2
    mov  ah, 09h
    mov  dx, sep
    int  21h
    mov  al, [min2]
    call print_dec2
    mov  ah, 09h
    mov  dx, sep
    int  21h
    mov  al, [seg2]
    call print_dec2
    mov  ah, 09h
    mov  dx, sep
    int  21h
    mov  al, [cc2]
    call print_dec2
    mov  ah, 09h
    mov  dx, msg_fin
    int  21h
    mov  ax, 4C00h
    int  21h

print_dec2:                   ; imprime AL (0-99) en 2 digitos
    aam
    xchg ah, al
    push ax
    add  al, 30h
    mov  dl, al
    mov  ah, 02h
    int  21h
    pop  ax
    mov  al, ah
    add  al, 30h
    mov  dl, al
    mov  ah, 02h
    int  21h
    ret

section .data
    msg_inicio  db "Midiendo bucle de trabajo fijo...", 0Dh, 0Ah, "$"
    msg_t1      db "Hora inicial (hh:mm:ss:cc): $"
    msg_t2      db 0Dh, 0Ah, "Hora final   (hh:mm:ss:cc): $"
    msg_fin     db 0Dh, 0Ah, "Medicion completa. Compare el campo cc (centesimas).", 0Dh, 0Ah, "$"
    sep         db ":$"
    hora1 db 0
    min1  db 0
    seg1  db 0
    cc1   db 0
    hora2 db 0
    min2  db 0
    seg2  db 0
    cc2   db 0
