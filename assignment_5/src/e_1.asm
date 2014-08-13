	section .data
eps:		dq 1.0E-12
var1:		dq 11.00
result:		dq 1.0
fmt_result:	db "%d",`\n`,0
fmt_r2:		db "%e",`\n`,0

	section .text
	global main
	extern printf, scanf

do_e:
	push ebp
	mov ebp, esp
	sub esp, 8

	fld1
	push 11
	call factorial
	add esp, 4

	push eax
	fild dword [esp]
	pop eax

	fdiv
	fst qword [ebp-8]

	push dword [ebp-4]
	push dword [ebp-8]
	push fmt_r2
	call printf

	add esp, 16

	mov esp, ebp
	pop ebp
	ret

factorial:
	push ebp
	mov ebp, esp
	sub esp, 8
	;push dword [ebp+12]
	;push dword [ebp+8]
	;push fmt_r2
	;call printf
	;add esp, 12
	mov esi, [ebp+8]
	fld qword [esi]
	;mov eax, [ebp+8]	;place n in reg
	fldz
	fcomip
	;ftst
	;fstsw ax
	;fwait
	;sahf
	jb .pass
	;cmp eax, 0		;check for 0
	;jg .pass		;if greater than, pass
	fld1
	;mov eax, 1		;return condition to first seed if equal or less
	jmp .return		;short circuit to return
.pass:
	fld1
	fsub
	fstp qword [ebp-8]
	push dword [ebp-4]
	push dword [ebp-8]
	push fmt_r2
	call printf
	add esp, 12
	mov esi, dword [ebp-8]
	;dec eax			;set eax to n-1
	push dword [esi]
	;push eax		;push to stack
	call factorial		;find factor of n-1
	add esp, 4		;adjust stack
	;add esp, 4		;adjust stack
	fld qword [ebp+8]
	fmul
	;mov ebx, [ebp+8]	;restore n to ebx
	;mul ebx			;mul ebx by eax for n*!(n-1)
.return:
	mov esp, ebp
	pop ebp
	ret
main:
	finit
	push var1
	call factorial
	add esp, 4

	;push fmt_r2
	;call printf
	;add esp, 12

	;push 12
	;call factorial
	;add esp, 4

	;push eax
	;push fmt_result
	;call printf
	;add esp, 8

.quit:
	mov ebx, 0
	mov eax, 1
	int 0x80
