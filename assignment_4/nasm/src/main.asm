;Assignment 4
;Ross O. Shoger
;
;This program has 4 parts. It reverses a general buffer, counts the characters
;in that buffer; display the results. Then calculates and prints the 
;primes between 0 and 65,000 - prints 200 for validation. Finaly it calculates
;fibonacci to 7.

%define newline 0xA			;macro for newline
extern printf				;printf extern reference

	section .data
buffer:		db '123abcXZY!@#$aaaaaaabbbbbbbccccccc" ;a global buffer
bufferc:	equ $-buffer		;buffer count

prime_table:	resb 65000		;table of primes
prime_tablec:	equ $-prime_table	;count for prime table

freq_table:	times 256 db 0		;table to count characters
freq_tablec:	equ $-freq_table	;count of freq_table

fib_array:	times 7 dd 0		;array for fib_calc

fmt_dec:	db "%d",10,0		;formatting, "\n", '0'
fmt_table:	db "%c - %d",10,0	;formatting, "\n", '0'
fmt_newline:	db 10,0			;a newline'

section .text
	global main

;/////////////////////
;// str_reverse
;//  Reverse a string in buffer
;/////////////////////
str_reverse:
	push ebp
	mov ebp, esp
	mov esi, [ebp+8]	;string pointer
	mov ecx, [ebp+12]	;string length

	mov esi, buffer		;start of string
	mov edi, buffer		;end of string pointer
	add edi, bufferc-1	;move pointer to end of string
	shr ecx, 1		;floor(n/2)
.reverse_loop:
	mov al, [esi]		;move char into reg
	mov bl, [edi]		;move end char in to reg
	mov [esi], bl		;swap chars
	mov [edi], al
	inc esi			;increment to next char from first
	dec edi			;decrement to previous char from last
	loop .reverse_loop	;dec ecx and repeat until end of string
	pop ebp
	ret

;/////////////////////
;// str_freq_count
;//  Count of frequency of chars and fill table.
;/////////////////////
str_freq_count:
	push ebp
	mov ebp, esp
	mov esi, [ebp+8]			;source array pointer
	mov ecx, [ebp+12]			;number of chars in array
.fill:
	movzx edi, byte [esi]			;move into edi the char
	inc byte [freq_table+edi]		;increment element in array
	inc esi					;increment buffer
	loop .fill
	pop ebp
	ret

;/////////////////////
;// prime_calc
;// Calculate primes
;/////////////////////
prime_calc:
;Initialize Array
; set everything in table to 0
	mov ecx, prime_tablec		;count of table
	mov edi, prime_table		;start of table
.init:
	mov al, 0			;0 in reg
	stosb				;store byte from reg in edi
	loop .init			;iterate through

;Traverse array, check for primes
	mov ecx, 0
	mov byte [prime_table+ecx], 1	;1 is not prime
	inc ecx				;adjust ecx to 2
.loop:
	cmp ecx, 257			;if ecx > ~ sqrt(65000) + 1
	jg .end
	cmp byte [prime_table+ecx], 0	;is the value prime?
	je .is_prime			;yes
	inc ecx				;add to counter
	jmp .loop
.is_prime: ;Save registers as each element in printed
	pushad				;save the registers
	add ecx, 1			;adjust for array
	push ecx
	call prime_factor
	add esp, 4
	popad				;restore regs
	inc ecx
	jmp .loop			;find all of the factors
.end:
	ret

;/////////////////////
;// prime_factor
;//  Mark off elements within the array for each factor of n
;/////////////////////
prime_factor:
	push ebp
	mov ebp, esp
	mov ecx, 2
.loop:
	mov eax, [ebp+8]		;set eax to n
	mul ecx				;mul eax by counter for factor
	cmp eax, prime_tablec		;eax larger than our table?
	jg .end				;yes, so finish
	mov byte [prime_table+eax-1], 1	;set proper element to 1
	inc ecx				;increment counter
	jmp .loop
.end:
	pop ebp
	ret

;/////////////////////
;// fib_calc
;//  do the fib calc, and print
;/////////////////////
fib_calc:
	mov esi, 0
	mov dword [fib_array+esi], 1		;f(1)
	mov dword [fib_array+esi+4], 1	;f(2)

	mov esi, 8		;adjust esi to second element
; loop through until end of array, use f(n) = f(n-1)+f(n-2_)
.do:
	cmp esi, 28				;7 dwords?
	je .end					;yes, let's print
	mov eax, dword [fib_array+esi-4]	;set eax to f(n-1)
	add eax, dword [fib_array+esi-8]	;add f(n-2) to eax
	mov dword [fib_array+esi], eax		;set f(n) to eax
	add esi, 4				;increment esi
	jmp .do
; Termination point and printing fib_array
.end:
	mov esi, 0
	mov ecx, 7
.print:
	pushad				;save registers
	push dword [fib_array+esi]	;push current element
	push fmt_dec
	call printf
	add esp, 8			;adjust stack
	popad				;restore registers
	add esi, 4			;increment fin_array
	loop .print
	ret

;/////////////////////
;// print_prime_prime_list
;//  print prime_table
;/////////////////////
print_prime_list:
	mov esi, 0			;start
.loop:
	cmp esi, 200			;max
	je .end				;goto end
	cmp byte [prime_table+esi], 0	;find 0, which is index of prime
	je .print			;yes, print.
	inc esi				;iterate
	jmp .loop
.print:
;simple printf
	pushad
	mov eax, esi
	add eax, 1
	push eax
	push fmt_dec
	call printf
	add esp, 8
	popad
	inc esi
	jmp .loop
.end:
	ret

;/////////////////////
;// print_freq_table
;//  print freq_table, another printf starting at the beginning of a string
;/////////////////////
print_freq_table:
	mov esi, 0			;starting point
	mov ecx, freq_tablec		;length
	mov eax, 0			;starting point
;loop through each element printing
.loop:
	mov al, byte [freq_table+esi]
	pushad
	push eax 
	push esi
	push fmt_table
	call printf
	add esp, 12
	popad
	add esi, 1
	loop .loop
	ret

;/////////////////////
;// print_buffer
;//  print our buffer
;/////////////////////
print_buffer:
	mov edx, bufferc
	mov ecx, buffer
	mov ebx, 1
	mov eax, 4
	int 0x80	;interrupt
	ret

;/////////////////////
;// print_newline
;//  print a newline char
;/////////////////////
print_newline:
	push fmt_newline
	call printf
	add esp, 4
	ret

;/////////////////////
;// exit
;//  perform an exit with a 0 value
;/////////////////////
exit:
	mov ebx, 0	;status
	mov eax, 1
	int 0x80	;interrupt
	ret

;/////////////////////
;// main
;//  program entrance point
;/////////////////////
main:
	call print_buffer	;print string
	push bufferc		;string length
	push buffer		;string pointer
	call str_reverse	;reverse string
	add esp, 8		;adjust stack
	call print_newline
	call print_buffer	;display reversed string

	call print_newline
	push bufferc		;string length
	push buffer		;add of string
	call str_freq_count	;perform count
	add esp, 8

	;for print, this time we print the char too,
	;even though the mapping for the unicode chars
	;isnt implemented
	call print_freq_table

	;calculate our primes and print
	call prime_calc
	call print_prime_list

	call fib_calc			;7 elements of fib
	call exit

