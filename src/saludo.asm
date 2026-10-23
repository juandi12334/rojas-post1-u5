; Programa COM. El CPU empieza en el primer byte del archivo,
; por eso el codigo va antes de los datos.
org 0x100

section .text
    mov  ah, 09h
    mov  dx, nombre
    int  21h
    mov  ax, 4C00h
    int  21h

section .data
    nombre  db  "Laboratorio 5 - DOSBox y Ensamblador", 0Dh, 0Ah
            db  "Estudiante: Rojas", 0Dh, 0Ah
            db  "Unidad 5 - Arquitectura de Computadores", 0Dh, 0Ah, "$"
