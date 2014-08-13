	section .data

	section .text
	global main
	extern printf, scanf

main:

.quit:
	mov ebx, 0
	mov eax, 1
	int 0x80
