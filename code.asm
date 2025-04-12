.code 

drawHorizontalLine proc
; void drawHorizontalLine(CHAR_INFO* chiBuffer, CHAR_INFO symbol, POSITION_OPTS position);
; RCX = chiBuffer*
; RDX = symbol (2b(atr) + 2b(symcode))
; R8 = opts (2b(length) + 2b(screen_width) + 2b(Y) + 2b(X))


;_metka_drawHorizontalLine:
;
;mov [ rcx ], rdx
;add rcx, 4
;dec r9
;jnz _metka_drawHorizontalLine

push rbx
push rdi
push rax
push rcx

mov eax, 0DEADBEEFh  ; ”никальное значение
nop                  ; ƒл€ удобства

; rbx = offset (width * y + x) * 4;
mov rbx, r8
shr rbx, 32
movzx rbx, bx

mov rax, r8
shr rax, 16
movzx rax, ax

imul rbx, rax

mov rax, r8
movzx rax, ax

add rbx, rax

shl rbx, 2

mov rdi, rcx
add rdi, rbx ;add offset to rdi
mov rax, rdx
mov rcx, r8
shr rcx, 48 ;сдвиг до length
rep stosd

pop rcx
pop rax
pop rdi
pop rbx

ret

drawHorizontalLine endp

end