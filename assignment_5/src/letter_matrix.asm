extern printf, rand, srand

section .data
char_matrix:	times 16 db 'I',0
vowels:		db 'A','E','I','O','U',0
;we print only 4 bytes from each address passed to printf
fmt:		db "%.4s",`\n`,"%.4s",`\n`,"%.4s",`\n`,"%.4s",10,0

section .text
	global main

;//////////////////////
;// check_vowel
;//	check if a char is a vowel, passed on stack
;//////////////////////
check_vowel:
	push ebp
	mov ebp, esp
	mov eax, 1		;set fail condition
	mov ecx, 5		;set to count of vowels
.loop:
	mov bl, [vowels+ecx-1]	;fill register with a vowel
	cmp byte [ebp+8], bl	;is the passed value the same
	je .found		;yes, so return
	loop .loop		;iterate to next vowel
	jmp .pass		;nothing found, return a 1
.found:
	mov eax, 0		;vowel was found, return succeed
.pass:
	pop ebp
	ret

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

	;50% chance to gen a vowel
	push 2		;limit
	call do_rand	;eax holds return
	add esp, 4
	cmp eax, 0	;0 vowel, 1 not
	je .vowel
	jmp .cons
.vowel:	;generate a vowel
	;choose a random vowel
	push 5			;5 vowels
	call do_rand		;fill eax
	add esp, 4		;adjust
	mov dl, [vowels+eax]	;indirect address vowel
	jmp .write		;short to write
.cons:	;any letter but a vowel
	push 25			;the range of the alphabet
	call do_rand		;fill eax
	add esp, 4		;adjust
	add eax, 65		;place within proper range
	mov dl, al		;save char
	push ebx		;save ebx
	push eax		;vowel to check
	call check_vowel	;check our vowel, return in eax
	add esp, 4
	pop ebx			;restore ebx
	cmp eax, 1		;not a vowel
	je .write		;pass
	add dl, 1		;is a vowel, add 1
.write:
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
