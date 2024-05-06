;Pacman, Proyecto #1 Arquitectura de Computadores
;Cesar Fabricio Herrera - 2023097390

;El programa recibira un archivo de texto con el formato de un nivel, la posicion inicial del jugador y de los fantasmas
;Posteriormente, recibira caracteres a traves de la linea de comandos, los cuales indicaran la direccion del fantasma
;Al recibir la direccion, esta se actualizara, y consigo misma la posicion del jugador en la consola
;Al no estar trabajando con hilos, los fantasmas se moveran a medida que el jugador ingrese las teclas direccionales h
%include "io.mac"

.STARTUP

.UDATA
    ; Aquí van tus variables no inicializadas
    worldSpace resb 1920


.DATA
    ; Aquí van tus variables inicializadas
    msg db 'Hola mundo!', 0
    filename db 'level1.txt', 0
    playerX     dd 0
    playerY     dd 0

.CODE
readFile:

    ; Abre el archivo
    mov     EAX, 5         ; Número de sistema para abrir un archivo
    mov     EBX, filename ; Dirección del nombre del archivo
    mov     ECX, 0         ; Modo de apertura (lectura)
    int     0x80           ; Llama al sistema

    ; Comprueba si el archivo se abrió correctamente
    test    EAX, EAX
    js      error_open     ; Si hay un error, salta a error_open

    ; Lee el contenido del archivo y guárdalo en worldSpace
    mov     EAX, 3         ; Número de sistema para leer desde un archivo
    mov     EBX, EAX       ; Utiliza el descriptor de archivo devuelto por la llamada anterior
    mov     ECX, worldSpace ; Dirección del búfer donde se almacenarán los datos leídos
    mov     EDX, 1920      ; Número de bytes a leer
    int     0x80           ; Llama al sistema

    ; Comprueba si se leyeron correctamente los datos
    test    EAX, EAX
    js      error_read     ; Si hay un error, salta a error_read

    ; Procesa la línea 20 y guarda los valores en playerX y playerY
    mov     ESI, worldSpace ; Puntero a worldSpace

process_playerY:
   ; Busca el primer número del par ordenado
    mov     CX, 0           ; Inicializa CX
    mov     CL, [ESI+1517]  ; Primer dígito del primer número
    sub     CL, '0'         ; Convierte el carácter en número
    mov     CH, 0           ; Limpia el registro CH
    mov    [playerY], CL   ; Guarda el número en playerY

    ; Busca el segundo número del par ordenado
    mov     CX, 0           ; Inicializa CX
    mov     CL, [ESI+1518]  ; Primer dígito del primer número
    sub     CL, '0'         ; Convierte el carácter en número
    add    [playerY], CL   ; Guarda el número en playerY

process_playerX:
    ; Busca el primer número del par ordenado
    mov     CX, 0           ; Inicializa CX
    mov     CL, [ESI+1520]  ; Primer dígito del primer número
    sub     CL, '0'         ; Convierte el carácter en número
    mov     CH, 0           ; Limpia el registro CH
    mov    [playerX], CX   ; Guarda el número en playerY

    ; Busca el segundo número del par ordenado
    mov     CX, 0           ; Inicializa CX
    mov     CL, [ESI+1521]  ; Primer dígito del primer número
    sub     CL, '0'         ; Convierte el carácter en número
    mov     CH, 0           ; Limpia el registro CH
    add    [playerX], CX    ; Guarda el número en playerY

;Memory addresses test
;End test


    ; Imprime el contenido de worldSpace
    mov     ESI, worldSpace
print_loop:
    lodsb                   ; Carga el siguiente byte de worldSpace en AL
    test    AL, AL          ; Comprueba si AL es cero (fin de la cadena)
    jz      end_print       ; Si es cero, termina el bucle
    PutCh   AL              ; Imprime el carácter en la consola
    jmp     print_loop      ; Vuelve al inicio del bucle

end_print:
    ; Cierra el archivo
    mov     EAX, 6         ; Número de sistema para cerrar un archivo
    int     0x80           ; Llama al sistema
    ; Salta al final del programa
    jmp     exit_program

;Manejo de errores
error_open:
    PutStr  open_error_msg
    jmp     exit_program
error_read:
    PutStr  read_error_msg
    jmp     exit_program

open_error_msg db 'Error al abrir el archivo', 0
read_error_msg db 'Error al leer el archivo', 0

exit_program:
nwln
    .EXIT