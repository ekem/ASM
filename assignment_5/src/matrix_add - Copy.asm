extern printf, rand, srand

section .data
char_matrix:	times 16 db 'I',0
doubles:	times 16 dd 0,0
;we print only 4 bytes from each address passed to printf
fmt:		db "%.4s",`\n`,"%.4s",`\n`,"%.4s",`\n`,"%.4s",10,0

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
.loop_row:
	inc ebx		;increment row
	cmp ebx, 3	;4 rows?
	jg .end		;yes, so end
	mov esi, 0	;set col to 0
.loop_col:
	cmp esi, 3	;4 cols?
	jg .loop_row	;yes go to next row
	push 10				;the range of the alphabet
	call do_rand			;fill eax
	add esp, 4			;adjust
	add eax, 0xd30			;place within proper range
	mov dl, al			;save char
	mov [char_matrix+ebx+esi*4], dl ;move vowel to matrix
	inc esi			;	;next char
	jmp .loop_col			;iterate column
.end:
	ret

print_matrix:
	mov edi, char_matrix	;find offset
	mov ecx, 4		;4 rows
.loop:
	push edi		;push address
	add edi, 4		;increment 4 chars
	loop .loop		;next row

	push fmt		;push our string fmt
	call printf		;print string
	add esp, 20		;increment stack
	ret			;return

exit:
	mov ebx, 0		;success
	mov eax, 1
	int 0x80		;interrupt
	ret			;return

main:
	call gen_char_matrix	;generate our matrix
	call print_matrix	;print our matrix
	call exit		;exit with ok
