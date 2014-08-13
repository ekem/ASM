	section .data
eps:		dq 1.0E-12
var1:		dq 5.00
result:		dq 1.0
fmt_result:	db "%d",`\n`,0
fmt_r2:		db "%f",`\n`,0

	section .text
	global main
	extern printf, scanf

factorial:
	push ebp
	mov ebp, esp
	sub esp, 8
	fld qword [ebp+8]
	fldz
	fcomip
	jb .pass
	fld1
	jmp .return		;short circuit to return
.pass:
	fld1
	fsub
	fstp qword [ebp-8]

	;push dword [ebp-4]
	;push dword [ebp-8]
	;push fmt_r2
	;call printf
	;add esp, 12

	push dword [ebp-4]
	push dword [ebp-8]
	call factorial		;find factor of n-1
	add esp, 4		;adjust stack
	fld qword [ebp+8]
	fmul
.return:
	mov esp, ebp
	pop ebp
	ret
main:
	finit

	push dword [var1+4]
	push dword [var1]
	call factorial
	add esp, 8
	fstp qword [var1]
	push dword [var1+4]
	push dword [var1]
	push fmt_r2
	call printf
	add esp, 12


.quit:
	mov ebx, 0
	mov eax, 1
	int 0x80
