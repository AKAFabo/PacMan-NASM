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
    levelChosen resb 1

.DATA
    lvlMsg db "Escoja el nivel a cargar (1 = Nivel1, 2 = Nivel2, 3 = Nivel3): ",0
    l1 db "level1.txt",0
    l2 db "level2.txt",0
    l3 db "level3.txt",0
;---------------------------------------------
    filas dd 18
    columnas dd 80
;---------------------------------------------
    playerX     dd 0
    playerY     dd 0
    playerMatrixPosition dd 0
;---------------------------------------------
    open_error_msg db 'Error al abrir el archivo', 0
    read_error_msg db 'Error al leer el archivo', 0
.CODE


main:
    PutStr  lvlMsg
    GetCh   [levelChosen]
    cmp     byte [levelChosen], '1'
    je      loadLevel1
    cmp     byte [levelChosen], '2'
    je      loadLevel2
    cmp     byte [levelChosen], '3'
    je      loadLevel3
    jmp     main

loadLevel1:
    mov     EBX, l1                 ;Carga level1 en memoria
    jmp     readFile
loadLevel2:
    mov     EBX, l2                 ;Carga level2 en memoria
    jmp     readFile
loadLevel3:
    mov     EBX, l3                 ;Carga level3 en memoria

readFile:

    ; Abre el archivo

    mov     EAX, 5         ; Número de sistema para abrir un archivo
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
    imul    CX, 10
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
    imul    CX, 10
    mov     CH, 0           ; Limpia el registro CH
    mov    [playerX], CX   ; Guarda el número en playerY

    ; Busca el segundo número del par ordenado
    mov     CX, 0           ; Inicializa CX
    mov     CL, [ESI+1521]  ; Primer dígito del primer número
    sub     CL, '0'         ; Convierte el carácter en número
    mov     CH, 0           ; Limpia el registro CH
    add    [playerX], CX    ; Guarda el número en playerY

    mov     ESI, worldSpace
    sub     AL, AL

calculateMatrixPosition:
; Calcula la posición del elemento en la matriz
    mov     AL, '<'
    ;mov     eax, base_matriz            ; Carga la dirección base de la matriz en eax
    mov     ebx, [playerY]                ; Carga el índice de la fila en ebx
    imul    ebx, 80                         ; Multiplica la fila por el número de columnas (80 columnas en total,)
    add     ebx, [playerX]                 ; Suma la columna al resultado anterior
    mov [ESI + EBX] , AL
    ;add     eax, ebx                    ; Suma el resultado a la dirección base de la matriz, 

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
exit_program:
nwln
    .EXIT


;Manejo de errores
error_open:
    PutStr  open_error_msg
    jmp     exit_program
error_read:
    PutStr  read_error_msg
    jmp     exit_program