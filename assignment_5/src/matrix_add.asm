extern printf, rand, srand

section .data
char_matrix:	times 16 db 'I',0
doubles:	times 16 dw 0,0
;we print only 4 bytes from each address passed to printf
fmt:		db "%d %d %d %d",10,0
fmt_int:	db "%d",10,0

section .text
	global main

;//////////////////////
;// modulo
;// 	does modulo, requires two inputs
;// 	n%x
;// 	remainder is held in eax
;//////////////////////
modulo:
	push ebp
	mov ebp, esp
	mov eax, [ebp+8]	;n
	mov ecx, [ebp+12]	;x
	sub edx, edx		;clear edx for math
	div ecx			;do division
	mov eax, edx		;place remainder in eax to return
	pop ebp
	ret

;//////////////////////
;// do_rand
;//	generate a random number and limit it to a range within
;//	modulo
;//////////////////////
do_rand:
	push ebp
	mov ebp, esp
	call rand		;call rand
	push dword [ebp+8]	;supply upper limit
	push ecx		;rand return
	call modulo		;returns results in eax
	add esp, 8

	pop ebp
	ret			;eax holds results

;//////////////////////
;// gen_char_matrix
;//	generate a matrix of chars, 16 long, or 4*4
;//////////////////////
gen_char_matrix:
	;seed random
	push esp	;seed
	call srand	;seed randon
	add esp, 4

	mov ebx, -1	;starting place
.l_row:
	inc ebx		;increment row
	cmp ebx, 3	;4 rows?
	jg .end		;yes, so end
	mov esi, 0	;set col to 0
.l_col:
	cmp esi, 3	;4 cols?
	jg .l_row	;yes go to next row
	push 1000			;the range of the alphabet
	call do_rand			;fill eax
	add esp, 4			;adjust
	mov [char_matrix+ebx+esi*4], al ;move vowel to matrix
	mov [doubles+ebx+esi*8], ax
	inc esi			;	;next char
	jmp .l_col			;iterate column
.end:
	ret

print_matrix:
	push ebp
	mov ebp, esp
	sub esp, 8
	
	mov eax, [ebp+12]
	sub edx, edx
	mov ebx, 4
	div ebx
	mov [ebp+12], eax
	mov esi, [ebp+8]	;start of array
	mov ecx, 4
.print:
	cmp dword [ebp+12], 1
	je .isbyte
	jg .isword
.isbyte:
	mov al, [esi]
	jmp .write
.isword:
	mov ax, [esi]
	jmp .write
.write:
	push eax
	add esi, [ebp+12]
	loop .print
	push fmt	
	call printf
	add esp, 20
	mov esp, ebp		;deallocate local vars
	pop ebp
	ret			;return

exit:
	mov ebx, 0		;success
	mov eax, 1
	int 0x80		;interrupt
	ret			;return

main:
	call gen_char_matrix	;generate our matrix
	push 4
	push char_matrix
	call print_matrix	;print our matrix
	add esp, 8

	push 8
	push doubles
	call print_matrix	;print our matrix
	add esp, 8
	call exit		;exit with ok
