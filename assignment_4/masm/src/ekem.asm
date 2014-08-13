print_int proc
	; Takes a dword integer from stack and prints ascii characters
	push ebp
	mov ebp, esp
	sub esp, 4

	; iterate through values, pulling ascii. work through until eax is 0
	mov eax, dword ptr [ebp+8]
	mov esi, offset buffer
	mov ecx, 0
print_int_loop:
	cmp eax, 0 			;exit if 0
	je print_int_finish
	mov ebx, 10			;we want to get the ascii value
	sub edx, edx			;clear edx for division
	div ebx
	add dl, 30h
	push edx
	inc ecx
	jmp print_int_loop
print_int_finish: 			;we are done
	mov dword ptr [ebp-4], ecx
	cmp ecx, 0 			;is it a 0?
	je print_int_zero
	jmp print_int_fill
; we push the results to the stack and pop
print_int_zero:
	inc dword ptr [ebp-4]
	mov ecx, dword ptr [ebp-4]
	push '0'
print_int_fill:
	pop edx
	mov byte ptr [esi], dl
	add esi, type buffer
	loop print_int_fill
print_int_end:
	push [ebp-4]
	call print_buffer
	add esp, 4
	mov esp, ebp
	pop ebp
	ret
print_int endp
