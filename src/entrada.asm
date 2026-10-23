; Lee una tecla sin eco y muestra su codigo ASCII en hexadecimal.
org 0x100

section .text
    mov  ah, 09h
    mov  dx, prompt
    int  21h
    mov  ah, 07h          ; leer caracter sin eco
    int  21h              ; AL = ASCII
    mov  bl, al
    mov  ah, 09h
    mov  dx, msg_ok
    int  21h
    mov  ah, 02h          ; mostrar caracter en DL
    mov  dl, bl
    int  21h
    mov  ah, 09h
    mov  dx, msg_cod
    int  21h
    mov  al, bl
    shr  al, 4            ; nibble alto
    call print_hex_nibble
    mov  al, bl
    and  al, 0Fh          ; nibble bajo
    call print_hex_nibble
    mov  ah, 09h
    mov  dx, nl
    int  21h
    mov  ax, 4C00h
    int  21h

print_hex_nibble:
    cmp  al, 9
    jle  .digito
    add  al, 7            ; A-F: saltar desde '9' hasta 'A'
.digito:
    add  al, 30h
    mov  ah, 02h
    mov  dl, al
    int  21h
    ret

section .data
    prompt  db  "Ingrese una letra (se mostrara su codigo ASCII): $"
    msg_ok  db  0Dh, 0Ah, "Caracter recibido: $"
    msg_cod db  0Dh, 0Ah, "Codigo ASCII (hex): $"
    nl      db  0Dh, 0Ah, "$"
