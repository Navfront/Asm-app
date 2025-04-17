.code 

;---------------------------------------------------------------------
;   R8  = position_opts - упакованные параметры позиции и длины:
;                         биты 48-63: длина линии (16 бит)
;                         биты 32-47: ширина экрана (16 бит)
;                         биты 16-31: Y координата (16 бит)
;                         биты 0-15:  X координата (16 бит)
; результат (смещение) в RBX 
getStartSymbolShift proc
                         ; Вычисляем смещение в буфере по формуле: (width * Y + X) * 4
    
                         ; Получаем Y координату (биты 16-31 в R8)
    mov rbx, r8          ; Копируем position_opts в RBX
    shr rbx, 32          ; Сдвигаем вправо на 32 бита (теперь Y в младших 16 битах)
    movzx rbx, bx        ; Очищаем старшие биты (оставляем только Y)

                         ; Получаем ширину экрана (биты 32-47 в R8)
    mov rax, r8          ; Копируем position_opts в RAX
    shr rax, 16          ; Сдвигаем вправо на 16 бит (теперь width в младших 16 битах)
    movzx rax, ax        ; Очищаем старшие биты (оставляем только width)

                         ; Умножаем ширину на Y координату
    imul rbx, rax        ; RBX = width * Y

                         ; Получаем X координату (биты 0-15 в R8)
    mov rax, r8          ; Снова копируем position_opts
    movzx rax, ax        ; Очищаем все кроме X (младшие 16 бит)

                         ; Суммируем (width * Y) + X
    add rbx, rax         ; RBX = (width * Y) + X

                         ; Умножаем на 4 (размер одного CHAR_INFO)
    shl rbx, 2           ; RBX = ((width * Y) + X) * 4
    ret
getStartSymbolShift endp

;---------------------------------------------------------------------
;   R8  = position_opts - упакованные параметры позиции и длины:
;                         биты 48-63: длина линии (16 бит)
;                         биты 32-47: ширина экрана (16 бит)
;                         биты 16-31: Y координата (16 бит)
;                         биты 0-15:  X координата (16 бит)
; результат (widthBySymbols) в R9 
getWidthBySymbols proc
                         ; Получаем ширину экрана (биты 32-47 в R8)
    mov r9, r8          ; Копируем position_opts в R9
    shr r9, 32          ; Сдвигаем вправо на 32 бит (теперь ScreenWidth в младших 16 битах)
    movzx r9, r9b        ; Очищаем старшие биты (оставляем только ScreenWidth)
    imul r9, 4          ; R9 = ScreenWidth * 4 
    ret
getWidthBySymbols endp

;---------------------------------------------------------------------
; void drawVerticalLine(CHAR_INFO* chiBuffer, CHAR_INFO symbol, POSITION_OPTS pos_opts); 
;   RCX = chiBuffer*    - указатель на буфер CHAR_INFO (4 байта на символ)
;   RDX = symbol        - символ и атрибуты (младшие 4 байта: 2b атрибут + 2b символ)
;   R8  = position_opts - упакованные параметры позиции и длины:
;                         биты 48-63: длина линии (16 бит)
;                         биты 32-47: ширина экрана (16 бит)
;                         биты 16-31: Y координата (16 бит)
;                         биты 0-15:  X координата (16 бит)
drawVerticalLine proc

    push rbx
    push rdi
    push rax
    push rcx
    push r8
    push r9

    call getStartSymbolShift ; смещение в RBX 
    call getWidthBySymbols ; ширина экрана в символах в R9
    sub r9, 4               ; вычитаем 4 байта (ширина символа)

    mov rdi, rcx         ; Копируем указатель на буфер в RDI
    add rdi, rbx         ; Добавляем вычисленное смещение

    mov rax, rdx         ; Копируем символ и атрибуты в RAX (для STOSD)
    mov rcx, r8          ; Копируем position_opts в RCX
    shr rcx, 48          ; Сдвигаем вправо на 48 бит (получаем длину линии)
    _1:
    stosd                ; Повторяем запись EAX в [RDI] RCX раз (автоинкремент RDI на 4)
    add rdi, r9
    loop _1

    pop r9
    pop r8
    pop rcx
    pop rax
    pop rdi
    pop rbx
    ret                  ; возвращаем управление
drawVerticalLine endp

;---------------------------------------------------------------------
; void drawHorizontalLine(CHAR_INFO* chiBuffer, CHAR_INFO symbol, POSITION_OPTS pos_opts); 
;   RCX = chiBuffer*    - указатель на буфер CHAR_INFO (4 байта на символ)
;   RDX = symbol        - символ и атрибуты (младшие 4 байта: 2b атрибут + 2b символ)
;   R8  = position_opts - упакованные параметры позиции и длины:
;                         биты 48-63: длина линии (16 бит)
;                         биты 32-47: ширина экрана (16 бит)
;                         биты 16-31: Y координата (16 бит)
;                         биты 0-15:  X координата (16 бит)
drawHorizontalLine proc

    push rbx
    push rdi
    push rax
    push rcx

    mov eax, 0DEADBEEFh  ; Уникальное значение для идентификации DEADBEEF
    nop                  ; Выравнивание для отладки

                         ; Вычисляем смещение в буфере по формуле: (width * Y + X) * 4
    
    call getStartSymbolShift ; смещение в RBX 

    mov rdi, rcx         ; Копируем указатель на буфер в RDI
    add rdi, rbx         ; Добавляем вычисленное смещение

    mov rax, rdx         ; Копируем символ и атрибуты в RAX (для STOSD)
    mov rcx, r8          ; Копируем position_opts в RCX
    shr rcx, 48          ; Сдвигаем вправо на 48 бит (получаем длину линии)
    rep stosd            ; Повторяем запись EAX в [RDI] RCX раз (автоинкремент RDI на 4)

    pop rcx
    pop rax
    pop rdi
    pop rbx
    ret                  ; возвращаем управление
drawHorizontalLine endp

;---------------------------------------------------------------------
; extern "C" void drawColors(CHAR_INFO* chiBuffer, unsigned short screenWidth);
; RCX = chiBuffer*  - указатель на буфер CHAR_INFO (4 байта на символ)
; RDX = screenWidth  - ширина экрана в символах

drawColors proc
    push rax
    push rbx
    push rcx
    push rdx        
    push r8
    
    
    mov rdi, rcx    ; копируем указатель на буфер в RDI (для эффективной работы)
    shl edx, 2      ; умножаем ширину экрана на 4 (размер CHAR_INFO = 4 байта)
    sub edx, 64     ; вычитаем 64 (16 символов * 4 байта) — это смещение для перехода на следующую строку
    mov ebx, 0058h  ; начальный символ 'X' (в младшем слове) и атрибут = 0 (в старшем)
    mov r8d, 16     ; счётчик строк (16 строк)

rows_loop:
    mov ecx, 16     ; счётчик столбцов (16 символов в строке)

cols_loop:
    mov [rdi], ebx  ; записываем символ и атрибут в буфер
    add ebx, 010000h ; увеличиваем атрибут (старшее слово) на 1
    add rdi, 4      ; переходим к следующему CHAR_INFO (+4 байта)
    dec ecx         ; уменьшаем счётчик столбцов
    jnz cols_loop   ; если не ноль — продолжаем цикл
    
    add rdi, rdx    ; переходим на следующую строку (пропускаем `screenWidth - 16` символов)
    dec r8d         ; уменьшаем счётчик строк
    jnz rows_loop   ; если не ноль — продолжаем цикл

    pop r8
    pop rdx         
    pop rcx
    pop rbx
    pop rax
    ret             ; возвращаем управление
drawColors endp

end