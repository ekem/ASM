;Assignment 4
;Ross O. Shoger
;
;This program has 4 parts. It reverses a general buffer, counts the characters
;in that buffer; display the results. Then calculates and prints the 
;primes between 0 and 65,000 - prints 200 for validation. Finaly it calculates
;fibonacci to 7.486

.model flat, stdcall

STD_INPUT_HANDLE	EQU -10
STD_OUTPUT_HANDLE	EQU -11
STD_ERROR_HANDLE	EQU -12

extern rand:proc
extern srand:proc

WriteConsoleA proto,
	hConsoleInput:dword,
	lpBuffer:ptr byte,
	nNumberOfCharsToWrite:ptr dword,
	lpNumberOfCharsWritten:dword,
	lpReservered:dword

GetLocalTime proto:dword

GetStdHandle proto, nStdHandle:dword

ExitProcess proto, dwExitCode:dword

.data

LPSYSTEMTIME STRUCT
	wYear		word ?
	wMonth		word ?
	wDayOfWeek	word ?
	wDay		word ?
	wHour		word ?
	wMinute		word ?
	wSecond		word ?
	wMilliseconds	word ?
LPSYSTEMTIME ends

localtime LPSYSTEMTIME <>

; Handles for console indirection
stdout dd 0
stdin  dd 0
stderr dd 0

buffer byte 1 dup('123abcXZY!@#$aaaaaaabbbbbbbccccccc')		;a general buffer
read_written dword 0			;bytes read and written

freq_table dword 256 dup(0)		;table to count characters

fib_array dword 7 dup(0)		;array for fib_calc

matrix_char byte 4 dup(4 dup('I'))		;2d array for chars

vowels byte 'A','E','I','O','U',0

.data?
prime_table byte 65000 dup(?)		;table for prime numbers

.code

include ekem.asm	;includes the bin->int function, which loads and
			;prints the buffer

;/////////////////////
;// init
;// Initialize our function
;/////////////////////
init proc
	; Get output handle
	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov stdout, eax
	; Get input handle
	push STD_INPUT_HANDLE
	call GetStdHandle
	mov stdin, eax
	ret
init endp

;/////////////////////
;// prime_calc
;// Calculate primes
;/////////////////////
prime_calc proc
;Initialize Array
; set everything in table to 0
	mov ecx, length prime_table	;count of table
	mov edi, offset prime_table	;start of table
prime_calc_init:
	mov al, 0
	stosb
	loop prime_calc_init

;Traverse array, check for primes
	mov ecx, 0
	mov prime_table[ecx], 1		;1 is not prime
	inc ecx				;adjust ecx to 2
prime_calc_loop:
	cmp ecx, 257			;if ecx > ~ sqrt(65000) + 1
	jg prime_calc_end
	cmp byte ptr prime_table[ecx], 0;is the value prime?
	je prime_calc_is_prime		;yes
	inc ecx				;add to counter
	jmp prime_calc_loop
prime_calc_is_prime: ;Save registers as each element in printed
	pushad
	add ecx, 1
	push ecx
	call prime_factor
	add esp, 4
	popad
	inc ecx
	jmp prime_calc_loop
prime_calc_end:
	ret
prime_calc endp

;/////////////////////
;// prime_factor
;//  Mark off elements within the array for each factor of n
;/////////////////////
prime_factor proc
	push ebp
	mov ebp, esp
	mov ecx, 2
prime_factor_loop:
	mov eax, [ebp+8]			;set eax to n
	mul ecx					;mul eax by counter for factor
	cmp eax, lengthof prime_table		;eax larger than our table?
	jg prime_factor_end			;yes, so finish
	mov prime_table[eax-type prime_table], 1;set proper element to 1
	inc ecx					;increment counter
	jmp prime_factor_loop
prime_factor_end:
	pop ebp
	ret
prime_factor endp

;/////////////////////
;// str_freq_count
;//  Count of frequency of chars and fill table.
;/////////////////////
str_freq_count proc
	push ebp
	mov ebp, esp
	mov esi, [ebp+8]	;source array pointer
	mov ecx, [ebp+12]	;number of chars in array
str_freq_count_fill:
	movzx edi, byte ptr [esi]		;move into edi the char
	inc freq_table[edi*type freq_table]	;increment element in array
	inc esi					;increment buffer
	loop str_freq_count_fill
	pop ebp
	ret
str_freq_count endp

;/////////////////////
;// str_reverse
;//  Reverse a string in buffer
;/////////////////////
str_reverse proc
	push ebp
	mov ebp, esp
	
	mov esi, [ebp+8]	; string to reverse
	mov eax, 2
	mov ecx, [ebp+12]	; length of string
	
	; Iterate through string and push to stack
str_reverse_read:
	push [esi]
	add esi, type buffer
	loop str_reverse_read

	; Pop elements from stack and fill string
	mov esi, [ebp+8]	; start at beginning of array
	mov ecx, [ebp+12]	; reset counter
str_reverse_write:
	pop [esi]
	add esi, type buffer
	loop str_reverse_write

	pop ebp
	ret
str_reverse endp

fib_calc proc
	mov esi, 0
	mov fib_array[esi], 1		;f(1)
	mov fib_array[esi+dword], 1	;f(2)

	mov esi, 2*dword		;adjust esi to second element
; loop through until end of array, use f(n) = f(n-1)+f(n-2_)
fib_calc_do:
	cmp esi, 7*dword		;7 dwords?
	je fib_calc_end			;yes, let's print
	mov eax, fib_array[esi-dword]	;set eax to f(n-1)
	add eax, fib_array[esi-2*dword]	;add f(n-2) to eax
	mov fib_array[esi], eax		;set f(n) to eax
	add esi, dword			;increment esi
	jmp fib_calc_do
; Termination point and printing fib_array
fib_calc_end:
	mov esi, 0
	mov ecx, lengthof fib_array
fib_calc_print:
	pushad				;save registers
	push fib_array[esi]		;push current element
	call print_int			;print element
	add esp, dword			;adjust stack
	call print_newline		;newline
	popad				;restore registers
	add esi, dword			;increment fin_array
	loop fib_calc_print
	ret
fib_calc endp

matrix_gen proc
	push esp
	call srand
	add esp, 4
	mov ebx, -1	;rows
matrix_gen_loop_row:
	inc ebx
	cmp ebx, 3
	jg matrix_gen_end
	mov esi, 0	;columns
matrix_gen_loop_col:
	cmp esi, 3
	jg matrix_gen_loop_row
	call rand
	push 2
	push ecx
	call modulo
	add esp, 8
	cmp eax, 0
	je matrix_gen_vowel
	jmp matrix_gen_cons
matrix_gen_vowel:
	call rand
	push 5
	push ecx
	call modulo
	add esp, 8
	mov dl, vowels[eax]
	jmp matrix_gen_write
matrix_gen_cons:
	call rand
	push 25
	push ecx
	call modulo
	add esp, 8
	add eax, 65			;make uppercase char
	mov dl, al			;prepare to pass char
	push ebx			;preserve ebx for overall count
	push eax
	call check_vowel		;check vowel, returns 1 if vowel
	add esp, 4
	pop ebx				;restore ebx
	cmp eax, 1			;was the char generated a vowel?
	je matrix_gen_write		;no, so write char
	add dl, 1			;char was a vowel, so just add 1
matrix_gen_write:
	mov matrix_char[ebx+esi*4], dl
	inc esi
	jmp matrix_gen_loop_col
matrix_gen_end:
	ret
matrix_gen endp

check_vowel proc
	push ebp
	mov ebp, esp
	mov eax, 1			;set eax 0 for fail, return 0
	mov ecx, lengthof vowels	;iterate through vowels
check_vowel_loop:
	mov bl, vowels[ecx-1]
	cmp byte ptr [ebp+8], bl	;is char this element?
	je check_vowel_found		;yes
	loop check_vowel_loop		;check next element
	jmp check_vowel_pass		;no vowels found
check_vowel_found:
	mov eax, 0			;found vowel, return 1
check_vowel_pass:
	pop ebp
	ret
check_vowel endp

check_rows proc
	mov esi, offset matrix_char
	mov ecx, 4
check_rows_loop:
	push ecx
	push esi
	call check_string
	pop esi
	pop ecx

	cmp eax, 0
	je check_rows_print
	jmp check_rows_end
check_rows_print:
	push 4
	push esi
	call print_str
	add esp, 8
check_rows_end:
	add esi, 4
	loop check_rows_loop

	ret
check_rows endp

;check_cols proc
;	mov esi, 0
;	mov edi, 0
;	mov ecx, 0
;check_cols_fill:
;	cmp ecx, 4
;	jg check_cols_end
;	mov edi, ecx
;	mov byte ptr buffer[edi], byte ptr matrix_char[esi+ecx]
;	inc esi
;
;	inc ecx
;	jmp check_cols_fill
;check_cols_end:
;	push 4
;	call print_buffer
;	add esp, 4
;	ret
;check_cols endp

check_diags proc

	ret
check_diags endp

check_string proc
	push ebp
	mov ebp, esp
	mov edi, [ebp+8]
	mov ecx, 4
	mov ebx, 0
check_string_loop:
	movzx eax, byte ptr [edi]
	push ebx
	push ecx
	push eax
	call check_vowel
	add esp, 4
	pop ecx
	pop ebx
	cmp eax, 0
	je check_string_isvowel
	jmp check_string_not
check_string_isvowel:
	add ebx, 1
check_string_not:
	inc edi
	loop check_string_loop

	mov eax, 1
	cmp ebx, 2
	je check_string_isstr
	jmp check_string_end
check_string_isstr:
	mov eax, 0
check_string_end:

	push ebx
	call print_int
	pop ebx

	pop ebp
	ret
check_string endp
;// n%x
modulo proc
	push ebp
	mov ebp, esp
	mov eax, [ebp+8]	;n
	mov ecx, [ebp+12]	;x
	sub edx, edx		;clear edx for math
	div ecx			;do division
	mov eax, edx		;place remainder in eax to return
	pop ebp
	ret
modulo endp

print_matrix_char proc
	mov edi, 0
	mov esi, 0
print_matrix_char_loop:
	cmp edi, 16
	je print_matrix_char_end
	movzx eax, matrix_char[edi]
	mov buffer[esi], al
	pushad
	push 1
	call print_buffer
	add esp, 4
	popad
	inc edi
	mov eax, edi
	sub edx, edx
	mov ebx, 4
	div ebx
	cmp edx, 0
	je print_matrix_char_n
	jmp print_matrix_char_loop
print_matrix_char_n:
	call print_newline
	jmp print_matrix_char_loop
print_matrix_char_end:
	ret
print_matrix_char endp

;/////////////////////
;// print_prime_prime_list
;//  print prime_table
;/////////////////////
print_prime_list proc
	mov esi, 0
print_prime_list_loop:
	cmp esi, 200
	je print_prime_list_end
	cmp prime_table[esi], 0
	je print_prime_list_print
	inc esi
	jmp print_prime_list_loop
print_prime_list_print:
	pushad
	mov eax, esi
	add eax, 1
	push eax
	call print_int
	pop eax
	call print_newline
	popad
	inc esi
	jmp print_prime_list_loop
print_prime_list_end:
	ret
print_prime_list endp

print_prime_table proc
	push ebp
	mov ebp, esp
	mov esi, offset prime_table
	cmp dword ptr [ebp+8], 0
	je print_prime_table_full
	jg print_prime_table_limit
print_prime_table_limit:
	mov ecx, [ebp+8]
	jmp print_prime_table_loop
print_prime_table_full:
	mov ecx, lengthof prime_table
print_prime_table_loop:
	movzx eax, byte ptr [esi]
	pushad
	push eax
	call print_int
	pop eax
	popad
	inc esi
	loop print_prime_table_loop
	pop ebp
	ret
print_prime_table endp

print_freq_table proc
	mov esi, offset freq_table
	mov ecx, lengthof freq_table
	mov eax, 0
print_freq_table_loop:
	mov al, byte ptr [esi]
	pushad
	push eax 
	call print_int
	pop eax
	popad
	add esi, type freq_table
	loop print_freq_table_loop
	ret
print_freq_table endp

print_str proc
	push ebp
	mov ebp, esp

	push 0
	push offset read_written
	push [ebp+12]
	push [ebp+8]
	push stdout
	call WriteConsoleA
	pop ebp
	ret
print_str endp

print_buffer proc
	push ebp
	mov ebp, esp

	push 0
	push offset read_written
	push [ebp+8]
	push offset buffer
	push stdout
	call WriteConsoleA
	pop ebp
	ret
print_buffer endp

print_newline proc
	.data
	ch_newline byte 0dh,0ah
	.code
	push 0
	push offset read_written
	push 2
	push offset ch_newline
	push stdout
	call WriteConsoleA
	ret
print_newline endp

disp_reverse proc
	.data
	msg_reverse1 byte "String:",0dh,0ah,0
	msg_reverse2 byte 0dh,0ah,"String Reversed:",0dh,0ah,0
	.code
	;print msg 1
	push lengthof msg_reverse1-1
	push offset msg_reverse1
	call print_str
	add esp, 8

	;display the string
	call print_newline
	push lengthof buffer			;length
	call print_buffer			;start of string
	add esp, 4

	;print msg 2
	call print_newline
	push lengthof msg_reverse2-1
	push offset msg_reverse2
	call print_str
	add esp, 8

	;revese the string
	push lengthof buffer			;length
	push offset buffer			;start of string
	call str_reverse			;reverse call
	add esp, 8

	;print buffer again
	call print_newline
	push lengthof buffer			;length
	call print_buffer			;start of string
	add esp, 4
	call print_newline
	ret
disp_reverse endp

disp_char_count proc
	.data
	msg_char_c byte 0dh,0ah,"Counting the characters in the string:",
			0dh,0ah,0

	.code

	push lengthof msg_char_c-1
	push offset msg_char_c
	call print_str
	add esp, 8

	push lengthof buffer
	push offset buffer
	call str_freq_count
	add esp, 8

	call print_newline
	call print_freq_table
	call print_newline

	ret
disp_char_count endp

disp_primes proc
	.data
	msg_primes0 byte 0dh,0ah,"Calculating primes...",0dh,0ah,0
	msg_primes1 byte 0dh,0ah,"First 49 bits of the table:",0dh,0ah,0
	msg_primes2 byte 0dh,0ah,"All Primes under 200:",0dh,0ah,0
	.code

	;print first message
	push lengthof msg_primes0-1
	push offset msg_primes0
	call print_str
	add esp, 8

	call prime_calc			;calculate primes

	;print first message
	push lengthof msg_primes1-1
	push offset msg_primes1
	call print_str
	add esp, 8

	;print first 49 bits
	call print_newline
	push 49
	call print_prime_table
	add esp, 4
	call print_newline		;newline

	;print second message
	push lengthof msg_primes2-1
	push offset msg_primes2
	call print_str
	add esp, 8

	;print the primes
	call print_newline
	call print_prime_list

	ret
disp_primes endp

disp_matrix proc
	call print_newline
	call matrix_gen
	call print_matrix_char
	add esp, 4
	
	call matrix_parse
	ret
disp_matrix endp

matrix_parse proc
	call check_rows
	ret
matrix_parse endp

disp_fib proc
	.data
	msg_fib byte 0dh,0ah,"First seven number of fibonacci:",0dh,0ah,0
	.code

	;print fib msg
	push lengthof msg_fib-1
	push offset msg_fib
	call print_str
	add esp, 8

	;display fibs
	call print_newline
	call fib_calc
	ret
disp_fib endp

main proc
	call init			;init i/o

	call disp_reverse		;first problem

	call disp_char_count		;second problem

	call disp_primes		;third problem

	call disp_fib			;fourth

	call disp_matrix		;Extra Credit

	call ExitProcess		;exit
main endp

end main
