# Laboratorio Unidad 5 — Emuladores y Virtualización

Post-contenido de Arquitectura de Computadores (UFPS). El trabajo compara la emulación con DOSBox y la virtualización con VirtualBox.

## Datos del estudiante

- Apellido: Rojas
- Usuario de GitHub: juandi12334
- Repositorio: https://github.com/juandi12334/rojas-post1-u5
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

## Redes de la máquina virtual

| Modo | IP obtenida (`ip addr show eth0`) | ¿ping 8.8.8.8 desde la VM? | ¿ping desde el anfitrión a la VM? |
|---|---|---|---|
| NAT | 10.0.2.15 | Sí, 3 respuestas, 0 % perdidas | No medido en esa sesión |
| Host-Only | 192.168.56.101 | No. Respuesta: Network unreachable | Sí, 3 respuestas desde Windows |
| Bridge | 192.168.1.38 | Sí, 3 respuestas, 0 % perdidas | Sí, 3 respuestas desde Windows. El anfitrión está en 192.168.1.8 |

## Árbol de snapshots

```
snap_base
   Alpine Linux 3.19 recien instalado, sin modificaciones
   Estado actual despues de restaurar
   snap_con_herramientas
      Alpine con curl, wget, nano y htop instalados
```

Tras restaurar `snap_base`, `apk info curl` no mostró el paquete. Solo avisó que no encontraba la lista guardada del repositorio. `curl` había quedado en la foto posterior.

## Decisión técnica 3. Modo de red y seguridad

Para una máquina de práctica en el propio equipo, sin que otros aparatos deban alcanzarla, el modo adecuado es NAT. En la prueba obtuvo 10.0.2.15 y pudo hacer ping a 8.8.8.8, así que sale a internet a través del anfitrión. Esa dirección no es la de la red de la casa: el router no la ve como un computador más, y las conexiones las inicia la máquina hacia afuera. Queda aislada del resto de los dispositivos. Host-Only sirve para ensayar la red sin exponer la máquina. Obtuvo 192.168.56.101, el ping a 8.8.8.8 respondió Network unreachable y Windows sí pudo llamarla. Se pierde internet, y con él las actualizaciones y la instalación de paquetes. Bridge fue el de mayor alcance: recibió 192.168.1.38, en el mismo Wi-Fi que el anfitrión (192.168.1.8), respondió al ping desde Windows y también salió a internet. Cualquier dispositivo de esa red puede intentar alcanzarla, incluido el SSH de root que quedó habilitado. Por eso Bridge aumenta la superficie de ataque. En esta práctica, NAT es el modo por defecto y Host-Only el adecuado cuando el experimento debe quedar aislado.

## Recursos y discos

Dentro de la máquina, `nproc` devolvió 2 y `free -m` mostró 1976 MB de memoria total, cerca de los 2048 MB asignados. El anfitrión es un Intel Core i3-1315U, con 6 núcleos, 8 procesadores lógicos y 7,7 GB de RAM.

La escritura de 200 MB se hizo una vez en cada disco:

| Tipo de disco | Comando | Tiempo real |
|---|---|---|
| Fijo (Lab5-Alpine-fixed.vdi) | dd sobre /mnt/fijo/test.img | 1,98 s |
| Dinámico (Lab5-Alpine.vdi) | dd sobre /root/test.img | 2,67 s |

## Decisión técnica 4. Disco fijo, disco dinámico, CPU y RAM

En la medición, el disco fijo fue más rápido: 1,98 segundos frente a 2,67 segundos del dinámico, ambos al escribir 200 MB con dd. El fijo reserva su espacio en Windows desde el momento en que se crea, así que la escritura no tiene que agrandar el archivo ni reorganizar sus datos internos. El dinámico sí paga ese costo mientras crece. Aun así, el dinámico sigue siendo la opción por defecto en un laboratorio con muchos estudiantes y discos limitados, porque solo ocupa lo que el sistema invitado realmente usa. El fijo de 4 GB ocupa esos 4 GB aunque Alpine esté casi vacío. Este anfitrión tiene 8 procesadores lógicos y 7,7 GB de memoria. Asignar 2 procesadores y 2048 MB deja margen para que Windows siga funcionando. Entregar los 8 procesadores, o casi toda la memoria, dejaría al anfitrión sin recursos y el equipo se volvería lento o dejaría de responder. `free -m` mostró 1976 MB visibles dentro de la máquina, una cifra cercana a los 2048 asignados.

La máquina se exportó a `C:\Users\juand\VirtualBox VMs\Lab5-Alpine\Lab5-Alpine-export.ova`. El archivo mide 152.271.360 bytes (145 MB). No se sube al repositorio. Antes de exportar se desconectó el disco fijo de 4 GB, que tampoco se sube.

## Conclusiones

DOSBox emula un computador viejo: traduce cada orden por software, y por eso el mismo bucle de `ciclos.com` tardó 2626 centésimas con 1000 ciclos, 330 con 8000 y 132 con 20000. VirtualBox no imita otro procesador. Ejecuta Alpine sobre el procesador real del anfitrión, con poca sobrecarga, porque la arquitectura es la misma. `cycles` no se compara con los gigahercios del PC: cuenta órdenes emuladas por unidad de tiempo. NAT deja salir a internet y aísla la máquina de la red de la casa. Host-Only la comunica solo con Windows. Bridge la pone en el Wi-Fi real y es el modo más expuesto. Un snapshot guarda el estado del disco para volver atrás: después de instalar curl, wget, nano y htop, restaurar `snap_base` dejó la máquina sin curl.
