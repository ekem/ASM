extern printf

section .data
bytea:		db 1,2,3,4,5,6,7,8,9,10,11,12,13,14,16
worda:		dw 100,200,300,400,500,600,700,800,900,100,110,120,130,140,150,160
dworda:		dd 1000,2000,3000,4000,5000,6000,7000,8000,9000,10000,10010,10020,10030,10040,10050,10060

fmt:		db "%d %d %d %d",`\n`,0
fmt_result:	db "%d",`\n`,0

section .text
	global main
;;
;; Cast
;;  takes a type length and pointer to an array element
;;  fill eax with either a byte, word, or dword passed
;;
cast:
	push ebp
	mov ebp, esp
	mov esi, [ebp+8]		;element pointer

	cmp dword [ebp+12], 2		;2 = word
	jl .isbyte			;is 1, so byte
	je .isword			;is 2, word
	jg .isdword			;is 4, dword

	;;fill registers and jump to end
.isbyte:
	movzx eax, byte [esi]
	jmp .end
.isword:
	movzx eax, word [esi]
	jmp .end
.isdword:
	mov eax, dword [esi]
	jmp .end
.end:
	pop ebp
	ret

;;
;; printm
;;  prints the first 4 elements of the arrays using cast ()
;;
printm:
	push ebp
	mov ebp, esp

	mov esi, [ebp+8]
	mov ebx, [ebp+12]	;our segment length

	mov ecx, 4
.loop:
	push ebx
	push esi
	call cast
	add esp, 8

	push eax
	add esi, ebx
	loop .loop

	push fmt
	call printf
	add esp, 20

	pop ebp
	ret

add_row:
	push ebp
	mov ebp, esp
	sub esp, 4
	mov dword [ebp-4], 0
	mov esi, [ebp+8]	;element
	mov ebx, [ebp+12]	;type
	mov eax, 0
	mov ecx, 4		;count
.loop:
	push ebx
	push esi
	call cast
	add dword [ebp-4], eax
	add esi, ebx
	loop .loop
	mov eax, [ebp-4]
	mov esp, ebp
	pop ebp
	ret

calc_row_sum:
	push ebp
	mov ebp, esp
	mov esi, [ebp+8]	;array
	mov eax, [ebp+12]	;row size
	mul dword [ebp+20]
	mul dword [ebp+16]

	add esi, eax

	push dword [ebp+20]
	push esi
	call printm
	pop esi
	add esp, 4
	
	push dword [ebp+20]
	push esi
	call add_row
	add esp, 8

	push eax
	push fmt_result
	call printf
	add esp, 8

	pop ebp
	ret

main:
	push 2			;type      20
	push 1			;row       16
	push 4			;row size  12
	push worda		;array     8
	call calc_row_sum
	add esp, 16

	;print bytes
	push 1
	push bytea
	call printm
	add esp, 8

	;print words
	push 2
	push worda
	call printm
	add esp, 8

	;print words
	push 4
	push dworda
	call printm
	add esp, 8

	mov ebx, 0
	mov eax, 1
	int 0x80
	ret
