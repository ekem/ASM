	section .data
DBL_MAX:	dq 1.7976931348E+308
E:		dq 2.718281828459045235360287471352662497757247093699959
eps:		dq 1.0E-13
var1:		dq 5.00
result:		dq 1.0
fmt_result:	db "%d",`\n`,0
fmt_r2:		db "%f",`\n`,0

	section .text
	global main
	extern printf, scanf
euclid:
	push ebp
	mov ebp, esp

	fld1		;initialize with first seed
.loop:
	fld qword [E]
	fsub st0, st1
	fld qword [eps]
	fcomip
	jb .pass
	jmp .return
.pass:
	
	loop .loop
.return:
	pop ebp
	ret

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

	call euclid
	;push dword [var1+4]
	;push dword [var1]
	;call factorial
	;add esp, 8
	;fstp qword [var1]

	;push dword [var1+4]
	;push dword [var1]
	;push fmt_r2
	;call printf
	;add esp, 12


.quit:
	mov ebx, 0
	mov eax, 1
	int 0x80
