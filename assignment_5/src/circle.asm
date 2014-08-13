	section .data
diameter:	dq 2.0
radius:		dq 1.0
ratio:		dq 2.0

msg_prompt:	db "Enter a diameter: (default is 2.0) ", 0
fmt_input:	db "%lf", 0
fmt_result:	db `\U1d622`, " = ",`\u3c0`,`\u22c5`,`\U1d633`,`\u00b2`,10, \
			`\U1d633`," = %f",`\n`,`\U1d622`," = %f", `\n`, 0

	section .bss
result:		resq 1

	section .text
	global main
	extern printf, scanf

main:
	push msg_prompt		;pointer to first message
	call printf		;call printf
	add esp, 4		;adjust stack pointer
	push diameter		;push pointer to diamter to stack
	push fmt_input		;push fmt string for input to stack
	call scanf		;call scanf to get input
	add esp, 8		;adjust stack pointer

	finit			;initialize fpu

	fld qword [diameter]	;push diameter to fpu stack
	fdiv qword [ratio]	;div by ratio or /2
	fst qword [radius]	;store first fpu stack, st0, to radius
	fmul st0		;multiply st0 by st0, squaring the r
	fldpi			;push pi to fpu stack
	fmul			;multiply terms on stack
	fst qword [result]	;store as result

.print:
	;result and radius are quad words, or long long and 64-bits.
	;must be sent to stack in halves
	push dword [result+4]	;push second half of result to stack
	push dword [result]	;push first
	push dword [radius+4]	;do the same with radius
	push dword [radius]
	push fmt_result		;print formatting string
	call printf		;call printf
	add esp, 24		;adjust stack pointer
.quit:
	mov ebx, 0		;exit code 0
	mov eax, 1		;exit command to kernel
	int 0x80		;interrupt and call kernel
