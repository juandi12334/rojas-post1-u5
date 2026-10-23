# Laboratorio Unidad 5 — Emuladores y Virtualización

Post-contenido de Arquitectura de Computadores (UFPS). El trabajo compara la emulación con DOSBox y la virtualización con VirtualBox.

## Datos del estudiante

- Apellido: Rojas
- Usuario de GitHub: juandi1234
- Repositorio: `rojas-post1-u5`
- Sistema operativo anfitrión: Windows

## Entorno

- DOSBox: 0.74-3. Verificado en `C:\Program Files (x86)\DOSBox-0.74-3\DOSBox.exe` (versión de archivo 0.74.3.0).
- NASM para DOS: 2.07 (`nasm.exe` y `cwsdpmi.exe` en la raíz del repositorio, extraídos de `nasm-2.07-dos.zip`). Verificado dentro de DOSBox con `nasm -v`: `NASM version 2.07 compiled on Jul 19 2009`. El archivo `nasm-3.02-installer-x86.exe` es el instalador de Windows y no se ejecuta en el DOS emulado.
- RAM del anfitrión: 7,7 GB. Espacio libre en el disco C: 211,1 GB. Medido el 22 de octubre de 2026.
- VirtualBox: 7.2.22 (revisión 175245). Verificado con `VBoxManage --version` → `7.2.22r175245`.
- ISO de Alpine Linux: `alpine-standard-3.19.0-x86_64.iso` en Descargas. Tamaño 217.055.232 bytes (207 MB). El volumen interno dice `alpine-std 3.19.0 x86_64`. SHA-256 medido: `4CF7CD3BAD64122A8A2423E78369A486A02334D4D88645AAB9D08120BB76B0F9`.

## Estructura

- `src/`: código fuente en ensamblador.
- `bin/`: programas `.com` ensamblados.
- `capturas/`: evidencias de cada checkpoint.

## Programas de la Parte 1

Los tres fuentes están en `src/` y se ensamblaron dentro de DOSBox con NASM 2.07 (`nasm -f bin`). El registro de NASM quedó vacío, sin errores. Los binarios resultantes son `bin/saludo.com` (111 bytes), `bin/entrada.com` (174 bytes) y `bin/ciclos.com` (367 bytes). En `saludo.com` los primeros bytes son `B4 09` (`MOV AH,09h`), así que la ejecución empieza en el código y no en el texto del mensaje.

`ciclos.asm` usa un bucle externo de 200 repeticiones, el mismo en las tres corridas. La guía partía de 2000; con `cycles=1000` esa cifra alarga la medición varios minutos. Bajar el contador no cambia la comparación, porque el trabajo sigue siendo fijo y solo varía la velocidad de emulación.

DOSBox no incluye `DEBUG.EXE`. En la raíz del repositorio está `debug.com` de FreeDOS, versión 2.50 (licencia MIT), para el checkpoint de depuración.

La tabla siguiente recoge las horas reales leídas en DOSBox:

| Corrida | cycles | Hora inicial (hh:mm:ss:cc) | Hora final (hh:mm:ss:cc) | Duración observada (centésimas) |
|---|---|---|---|---|
| 1 | 8000 | 20:56:30:89 | 20:56:34:19 | 330 |
| 2 | 1000 | 21:10:08:07 | 21:10:34:33 | 2626 |
| 3 | 20000 | 21:11:57:59 | 21:11:58:91 | 132 |

## Decisión técnica 1. Valor de cycles

Para este laboratorio el valor correcto de cycles es un número fijo, concretamente 8000, en lugar de max o de auto. Con cycles=max, DOSBox emula tantas instrucciones por segundo como permite un núcleo del procesador del equipo anfitrión. En un computador moderno ese ritmo es tan alto que el bucle de trabajo de ciclos.com termina casi al instante. Las dos lecturas de hora que el programa obtiene con la función 2Ch quedan entonces casi iguales, y la duración observada se acerca a cero. Esa medición deja de ser válida: la velocidad ya no representa un equipo DOS de referencia, sino la potencia del Windows donde se abrió DOSBox, y el bucle de espera deja de esperar. Un valor fijo, como 8000, mantiene el mismo ritmo en computadores distintos. Por eso la prueba se puede repetir y comparar. Las tres corridas de este trabajo, con el mismo bucle de 200 vueltas, lo confirman: 1000 ciclos tardaron 2626 centésimas, 8000 ciclos tardaron 330 y 20000 ciclos tardaron 132. max y auto siguen siendo útiles fuera de esta medición. Conviene usarlos al ejecutar software de productividad para DOS, como un editor de texto, cuando se busca una respuesta rápida y el programa no depende de una pausa medida con el reloj del procesador emulado.

## Decisión técnica 2. Tiempo emulado y ciclos reales

Comparar cycles=8000 con los gigahercios del procesador anfitrión mezcla dos unidades que no miden lo mismo. El parámetro cycles indica cuántas instrucciones del computador emulado intenta ejecutar DOSBox en cada milisegundo de tiempo virtual. Un gigahercio, en cambio, cuenta ciclos físicos del silicio del equipo donde está instalado Windows. Ochocientas mil instrucciones emuladas por segundo no son una fracción de esos gigahercios. Cada instrucción de 16 bits que DOSBox finge cuesta muchas instrucciones del procesador de Windows, porque la emulación interpreta el programa por software. Por eso el uso real de CPU del proceso DOSBox.exe es mucho mayor de lo que sugiere el número 8000. La centésima que ciclos.com muestra con la función 2Ch no sale de un contador del procesador real: sale del reloj que DOSBox mantiene dentro de la máquina emulada. Para observar el consumo verdadero corresponde abrir el Administrador de tareas de Windows, o el Monitor de recursos, y mirar el proceso DOSBox.exe. El archivo dosbox.conf no informa ese consumo.
