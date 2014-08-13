	section .data
eps:	dq 1.0E-12
x:	dq 1.00
y:	dq 1.01

fmt_equal db "Equal",10,0
fmt_less db "X is lower",10,0
fmt_more db "X is not lower",10,0

	section .text
	global main
	extern printf		;load printf
equal:
	mov eax, -1		;set bad return
	fld qword [eps]		;push eps to stack
	fld qword [x]		;push x to stack
	fsub qword [y]		;subtract y
	fabs			;take abs(st(0))
	fcomi			;compare st(0) to st(1) and set flag
	ja .notequal		;if st(0) > st(1) then we are over epsilon
	push fmt_equal		;otherwise we are equal
	call printf
	add esp, 4
	mov eax, 0		;set success return
.notequal:
	ret

compare:
	fld qword [y]		;push our y to stack first
	fld qword [x]		;now x is st(0)
	fcomi			;st(0) > st(1)
	ja .larger		;yes, so print more than msg
	push fmt_less		;no, so print less than
	jmp .print
.larger:
	push fmt_more		;more than message
.print:
	call printf		;print stack
	add esp, 4
	ret

main:
	finit			;initiliaze fpu
	call equal		;check for equality
	cmp eax, 0		;check return, 0 is success
	je .quit		;equal, so exit
	call compare		;not equal so compare
.quit:
	mov ebx, 0
	mov eax, 1
	int 0x80
