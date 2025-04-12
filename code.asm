.code 

drawHorizontalLine proc
; void drawHorizontalLine(CHAR_INFO* chiBuffer, CHAR_INFO symbol, POSITION_OPTS position);
; RCX = chiBuffer*
; RDX = symbol (2b(atr) + 2b(symcode))
; R8 = opts (2b(length) + 2b(screen_width) + 2b(Y) + 2b(X))


; Вариант цикла 1:
;_metka_drawHorizontalLine:
;
;mov [ rcx ], rdx ; чтение из регистра rcx адреса в памяти
;add rcx, 4
;dec r9
;jnz _metka_drawHorizontalLine

push rbx
push rdi
push rax
push rcx

mov eax, 0DEADBEEFh  ; Уникальное значение
nop                  ; Для удобства поиска

; формула рассчета оффсета = (width * y + x) * 4 
mov rbx, r8
shr rbx, 32 ; сдвиг до low64
movzx rbx, bx ; чистим значение выше bx

mov rax, r8
shr rax, 16 ; сдвиг до hi32
movzx rax, ax ; чистим выше ax

imul rbx, rax

mov rax, r8
movzx rax, ax ; чистим выше ax

add rbx, rax

shl rbx, 2

mov rdi, rcx
add rdi, rbx ; add offset to rdi
mov rax, rdx
mov rcx, r8
shr rcx, 48 ; сдвиг до length
rep stosd

pop rcx
pop rax
pop rdi
pop rbx

ret

drawHorizontalLine endp

end