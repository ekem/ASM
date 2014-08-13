	section .data
a:	dq 0		;value for a
b:	dq 0		;b
c:	dq 0		;c

r1:	dq -1		;root 1
r2:	dq -1		;root 2

msg_1:	db "Enter a, b, and c",10,"a: ",0
msg_b:	db "b: ",0
msg_c:	db "c: ",0

fmt_a:	db "%lf",0
fmt_b:	db "%lf",0
fmt_c:	db "%lf",0

fmt_result:	db "root 1: %f",`\n`,"root 2: %f",10,0
msg_i:		db "Results are imaginary numbers.",10,0

	section .bss
result:		resq 1

	section .text
	global main
	extern printf, scanf

main:
	;print first message
	push msg_1
	call printf
	add esp, 4

	;get 'a'
	push a
	push fmt_a
	call scanf
	add esp, 12

	;print 'b' message
	push msg_b
	call printf
	add esp, 4

	;get 'b'
	push b
	push fmt_b
	call scanf
	add esp, 12

	;print 'c' message
	push msg_c
	call printf
	add esp, 4

	;get 'c'
	push c
	push fmt_c
	call scanf
	add esp, 12
.do_math:
	finit			;init fpu

	fld qword [b]		;send b to stack
	fmul st0		;multiply st0 by itself

	push 4			;push value 4 to stack
	fild dword [esp]	;push stack to st0
	add esp, 4		;adjust stack
	fmul qword [a]		;4 * a * c
	fmul qword [c]
	fsub			;b^2-4ac
	ftst			;compare result to 0
	fstsw ax		;put flags in rx
	fwait			;wait until instruction is finished
	sahf			;copy to cpus flag
	jb .imaginary		;if lower, is negative and imaginary
	fsqrt			;positive, so take sqare root
	fld qword [a]		;push a to stack
	fadd st0		;2*a
	fld qword [b]		;push b
	fchs			;invert
	fld st0			;pust st0 again
	fsub st0, st3		;find first root
	fdiv st2		;finish	/ 2a
	fstp qword [r1]		;save value
	fadd st2		;find second route
	fdiv st1		;finish /2a
	fst qword [r2]		;save second root

	;push both roots for printing
	push dword [r1+4]
	push dword [r1]
	push dword [r2+4]
	push dword [r2]
	push fmt_result
	call printf
	add esp, 20
	jmp .quit
.imaginary:			;if the number is imaginary, then print msg_i
	push msg_i
	call printf
	add esp, 4
.quit:
	mov ebx, 0		;set status
	mov eax, 1		;kernel command
	int 0x80		;interupt
