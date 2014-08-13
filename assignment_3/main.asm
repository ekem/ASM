name cs217
title Assigment Three
subttl Ross o. Shoger

.486
.model flat, stdcall

; Win32 console handles
STD_INPUT_HANDLE	EQU -10
STD_OUTPUT_HANDLE	EQU -11
STD_ERROR_HANDLE 	EQU -12

; Memory allocation constants
HEAP_NO_SERIALIZE              = 00000001h
HEAP_GROWABLE                  = 00000002h
HEAP_GENERATE_EXCEPTIONS       = 00000004h
HEAP_ZERO_MEMORY               = 00000008h
HEAP_REALLOC_IN_PLACE_ONLY     = 00000010h

BUFSIZ equ 100			;our buffer size

;===================================
; WinAPI
;===================================

; A struct to hold two word for a coordinate
COORD struct
	x word ?
	y word ?
COORD ends

; A struct representing a rect
SMALL_RECT STRUCT
  Left     WORD ?
  Top      WORD ?
  Right    WORD ?
  Bottom   WORD ?
SMALL_RECT ENDS

CONSOLE_SCREEN_BUFFER_INFO struct
	dwsize			COORD <>
	dwCursorPosition 	COORD <>
	wAttributes		word ?
	srWindow		SMALL_RECT <>
	dwMaximumWindowSize	COORD <>
CONSOLE_SCREEN_BUFFER_INFO ends

KEY_EVENT_RECORD struct
	bKeyDown          dword ?O
	wRepeatCount      word  ?
	wVirtualKeyCode   word  ?
	wVirtualScanCode  word  ?
	union uChar
	  UnicodeChar     word  ?
	  AsciiChar       byte  ?
	ends
	dwControlKeyState dword ?
KEY_EVENT_RECORD ends

MOUSE_EVENT_RECORD struct
	dwMousePosition         COORD <>
	dwButtonState           dword ?
	dwMouseControlKeyState  dword ?  
	dwEventFlags            dword ?
MOUSE_EVENT_RECORD ends

WINDOW_BUFFER_SIZE_RECORD struct
	dwSize COORD <>
WINDOW_BUFFER_SIZE_RECORD ends

MENU_EVENT_RECORD struct
	dwCommandId dword ?		; reserved
MENU_EVENT_RECORD ends

FOCUS_EVENT_RECORD struct
  bSetFocus dword ?
FOCUS_EVENT_RECORD ends

INPUT_RECORD struct
	EventType word ?
	align dword
	union Event
		KEY_EVENT_RECORD <>
		MOUSE_EVENT_RECORD <>
		WINDOW_BUFFER_SIZE_RECORD <>
		MENU_EVENT_RECORD <>
		FOCUS_EVENT_RECORD <>
	ends
INPUT_RECORD ends

;===================================
; Local
;===================================
RESULT struct
	answer dword ?
	count dword ?
RESULT ends

;===================================
; WinAPI
;===================================

GetStdHandle proto, nStdHandle:dword

ExitProcess proto, dwExitCode:dword

; Used to write to the console (low-level)
WriteConsoleA proto,
	hConsoleInput:dword,
	lpBuffer:ptr byte,
	nNumberOfCharsToWrite:ptr dword,
	lpNumberOfCharsWritten:dword,
	lpReservered:dword

; Used to read from console (low-level)
ReadConsoleA proto,
	hConsoleInput:dword,
	lpbuffer:ptr byte,
	nNumberOfCharsToRead:dword,
	lpNumberOfCharsRead:ptr dword,
	pInputControl:dword

; Read from position
ReadConsoleInputA proto,
	hConsoleInput:dword,
	lpBuffer:ptr INPUT_RECORD,
	nLength:dword,
	lpNumberOfEventsRead:ptr dword

ReadConsoleInputCharacterA proto,
	hConsoleOutput:dword,
	lpCharacter:ptr byte,
	nLength:dword,
	dwReadCoord:COORD,
	lpNumberOfCharsRead:ptr dword

WriteConsoleOutputCharacterA proto,
	hConsoleOutput:dword,
	lpCharacter:ptr byte,
	nLength:dword,
	dwWriteCoord:COORD,
	lpNumberOfCharsWritten:ptr dword

WriteConsoleOutputAttribute proto,
	hConsoleOutput:dword,
	lpAttribute:ptr word,
	nLength:dword,
	dwWriteCoord:COORD,
	lpNumpberOfAttrsWritten:ptr dword

; Get info about console buffer
GetConsoleScreenBufferInfo proto,
	hConsoleOutput:dword,
	lpConsoleScreenBufferInfo:ptr CONSOLE_SCREEN_BUFFER_INFO

; Flush unread data in input buffer
FlushConsoleInputBuffer proto,
	hConsoleInput:dword

; alloc some mem on the heap
HeapAlloc proto,
	hHeap:dword,	; handle to private heap block
	dwFlags:dword,	; heap alloc control flags
	dwBytes:dword	; number of bytes to allocate

; Free up some allocated memory
HeapFree proto,
	hHeap:dword,	; handle to heap with memory block
	dwFlags:dword,	; heap free flag
	lpMem:dword		; pointer to block to be freed

GetProcessHeap proto

Sleep proto,
	dwMilliseconds:dword

.data
; Handles for console indirection
stdout dd 0
stdin dd 0
stderr dd 0

; holds a struct related to console context
console_info CONSOLE_SCREEN_BUFFER_INFO <>

; some character constants
ch_newline byte 0dh,0ah
ch_prompt byte 0afh,020h
ch_lineno byte 1 dup(3 dup('0'), 020h)

disp_status COORD <10,2>	; used to display status
disp_read COORD <0,0>		; used to display numbers


hHeap dword ?					; our heap handle
dwFlags dword HEAP_ZERO_MEMORY	; flag for allocating off heap

buffer byte BUFSIZ dup(?),0,0 	; global io buffer for program

user_result RESULT <0,0>		; struct for user results

.data?
bufin INPUT_RECORD <>			; used to
username dword ?				; a pointer to the username
usernamec dword ?				; count of username
read_written dd ?				; used in io to count read and writes
user_resultp dword ?			; pointer to results

.code
;===================================
; init
; setup up the input and output handles, as well as process heap.
;===================================
init proc
	; Get output handle
	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov stdout, eax
	; Get input handle
	push STD_INPUT_HANDLE
	call GetStdHandle
	mov stdin, eax
	
	; Get our heap handle
	call GetProcessHeap
	mov hHeap, eax
	ret
init endp

;===================================
; display_introduction
; Display an introduction.
;===================================
display_introduction proc
	.data
	prog_author BYTE "Ross O. Shoger",0
	prog_title	BYTE "Assignment Three",0
	prog_introduction_msg byte 0dh, 0ah,"Hi, I'm a talking box!",0dh, 0ah,
								 0dh, 0ah,"What is your name? "
	.code
	; Print the title
	push 0
	push offset read_written
	push sizeof prog_title
	push offset prog_title
	push stdout
	call WriteConsoleA

	call print_newline

	; Print the author	
	push 0
	push offset read_written
	push sizeof prog_author
	push offset prog_author
	push stdout
	call WriteConsoleA

	call print_newline

	push 0
	push offset read_written
	push sizeof prog_introduction_msg
	push offset prog_introduction_msg
	push stdout
	call WriteConsoleA

	ret
display_introduction endp

;===================================
; display_instructions
; Display instructions to the user
;===================================
display_instructions proc
	.data
	prog_instructions byte ", enter a number that is between 0 and 100.",0dh,0ah,
							"The sum, the count, and the average of your numbers will be displayed.",0dh,0ah,
							"Negative numbers exit the input prompt.",0dh,0ah,0dh,0ah,0
	.code

	; Print our instructions
	push 0
	push offset read_written
	push sizeof prog_instructions-1
	push offset prog_instructions
	push stdout
	call WriteConsoleA

	ret
display_instructions endp

;===================================
; display_exit
; Display an exit message to console
;===================================
display_exit proc
	; Kind of a long way to accomplish, needs to fill buffers and 
	; then print
	.data
	display_exit_msg byte "Have a wonderful day ",0
	display_exit_msg_punc byte "!",0
	.code

	call print_newline

	; Print first part of message
	push 0
	push offset read_written
	push sizeof	display_exit_msg-1
	push offset display_exit_msg
	push stdout
	call WriteConsoleA

	; Print just username
	call print_username

	; Print puncauation
	push 0
	push offset read_written
	push sizeof	display_exit_msg_punc-1
	push offset display_exit_msg_punc
	push stdout
	call WriteConsoleA

	push stdin
	call FlushConsoleInputBuffer

	push 0
	push offset read_written
	push sizeof buffer
	push offset buffer
	push stdin
	call ReadConsoleA

	call print_newline
	ret
display_exit endp

;===================================
; getUser
; get user name. Reads ascii characters from console, count chars,
; and call HeapAlloc to store the name.
;===================================
get_user proc
	; Read from console for username
	push 0
	push offset read_written
	push sizeof buffer
	push offset buffer
	push stdin
	call ReadConsoleA

	; Check user input for string length and then allocate memory to
	; store the string
	mov edi, offset buffer

	sub eax, eax			; clear our counter
	sub ebx, ebx			; clear ebx once
get_user_parse:
	mov bl, [edi]			; move element into b low

	cmp ebx, 0dh			; is it a carriage return?
	je get_user_alloc		;  yes, store user

	add edi, type buffer	; increment edi
	inc eax					; increment char counter
	jmp get_user_parse		; continue until end
get_user_alloc:
	mov usernamec, eax
	add eax, 1
	push eax
	push dwFlags
	push hHeap
	call HeapAlloc
	mov username, eax

	mov edi, offset buffer
	sub ebx, ebx
	mov ecx, usernamec
	mov esi, username
get_user_fill:
	mov al, [edi]
	mov byte ptr [esi], al
	inc esi
	add edi, type buffer
	loop get_user_fill
	ret
get_user endp

;===================================
; get_values
; read input interger values from user and do some math
;===================================
get_values proc
	; C style entrace call
	push ebp
	mov ebp, esp
	sub esp, 16			; 4 * 4
	mov dword ptr [ebp-4], 0	; line number
	mov dword ptr [ebp-8], 0	; working accumulator
	mov dword ptr [ebp-12], 0	; working total
	mov dword ptr [ebp-16], 0	; working count
	jmp get_values_start

get_values_bad:
	push 1
	call print_status
get_values_start:
	mov dword ptr [ebp-8], 0	; set accumulator to 0
	add dword ptr [ebp-4], 1	; set line no to 1
	push [ebp-4]				; push lineno
	call print_lineno			; print a line no
	add esp,4					; correct stack pointer
	call print_prompt			; print prompt

	; Read user input from console
	push 0
	push offset read_written
	push sizeof buffer
	push offset buffer
	push stdin
	call ReadConsoleA

	
	mov edi, offset buffer
	mov ecx, sizeof buffer
	sub ebx, ebx
get_values_parse:
	mov bl, [edi]
	cmp ebx, '-'
	je get_values_end
	cmp ebx, 0dh
	je get_values_add
	cmp ebx, '0'
	jl get_values_bad
	cmp ebx, '9'
	jg get_values_bad

	sub ebx, '0'
	mov eax, 10
	mul dword ptr [ebp-8]
	add eax, ebx
	mov [ebp-8], eax
	add edi, type buffer
	loop get_values_parse
get_values_add:
	cmp dword ptr [ebp-8], 0
	jl get_values_bad
	cmp dword ptr [ebp-8], 100
	jg get_values_bad
	cmp byte ptr [buffer], 0dh
	je get_values_bad

	mov eax, dword ptr [ebp-12]
	add eax, dword ptr [ebp-8]
	inc dword ptr [ebp-16]
	mov dword ptr [ebp-12], eax
	push 0
	call print_status
	jmp get_values_start

get_values_end:
	; Check to make sure the next char is a number, other it's
	; just a hyphen char
	cmp byte ptr [edi+type buffer], '0'
	jl get_values_bad
	cmp byte ptr [edi+type buffer], '9'
	jg get_values_bad

	;
	mov esi, [ebp+8]				; move into esi our passed pointer
	mov ebx, dword ptr [ebp-12]		; put value into register
	mov [esi], ebx 					; place into struct value
	mov ebx, dword ptr [ebp-16]
	mov [esi+4], ebx

	;mov eax, dword ptr [ebp-12]	; just checking

	;cleanup
	mov esp, ebp
	pop ebp
	ret
get_values endp

;===================================
; print_prompt
; Print out our input prompt
;===================================
print_prompt proc
	push 0
	push offset read_written
	push 2
	push offset ch_prompt
	push stdout
	call WriteConsoleA
	ret
print_prompt endp

;===================================
; print_newline
; Print a newline
;===================================
print_newline proc
	push 0
	push offset read_written
	push 2
	push offset ch_newline
	push stdout
	call WriteConsoleA
	ret
print_newline endp

;===================================
; print_username
; Print out the input username
;===================================
print_username proc
	push 0
	push offset read_written
	push usernamec
	push username
	push stdout
	call WriteConsoleA
	ret
print_username endp

;===================================
; print_status
; prints out a status string to a fixed position
; based on a passed integer
; 0 = ok
; 1 = bad
;===================================
print_status proc
	; The declarations are sloppy, hoped to include a negative indicator
	; oh well
	.data
	bufp dword ?
	buf_colorp dword ?
	buf BYTE "ok",0
	print_status_msg_bad byte "no",0
	buf_color word 02h,02h,5,5
	print_status_msg_bad_color word 04h,04h,7,7
	print_status_msgc dword 2

	.code
	push ebp
	mov ebp, esp

	mov bufp, offset buf
	mov buf_colorp, offset buf_color

	; If the passed value's relation to 0 is: then do:
	cmp dword ptr [ebp+8], 0
	je print_status_ok
	jg print_status_no
print_status_no: 								; Here we just want to set pointers
	mov bufp, offset print_status_msg_bad
	mov buf_colorp, offset print_status_msg_bad_color
print_status_ok:
	push offset console_info
	push stdout
	call GetConsoleScreenBufferInfo				; fill a struct with info

	sub ebx, ebx
	mov bx, console_info.dwCursorPosition.x
	mov disp_status.x, 30 						; always print to same place on line
	mov bx, console_info.dwCursorPosition.y
	sub bx, 1 									; go back 1 from current line
	mov disp_status.y, bx

	; Write our formatting
	push offset read_written
	push disp_status
	push 2
	push buf_colorp
	push stdout
	call WriteConsoleOutputAttribute

	; Print actual status
	push offset read_written
	push disp_status
	push 2
	push bufp
	push stdout
	call WriteConsoleOutputCharacterA

	pop ebp
	ret
print_status endp

print_lineno proc
	push ebp
	mov ebp, esp
	sub esp, 0

	mov eax, [ebp+8]
print_lineno_reset:
	sub ecx, ecx
print_lineno_parse:
	cmp eax, 0
	je print_lineno_print
	sub edx, edx
	mov ebx, 10
	div ebx
	add edx, 30h
	mov esi, 2
	sub esi, ecx
	cmp esi, 0
	jl print_lineno_reset
	mov [ch_lineno+esi], dl
	inc ecx
	jmp print_lineno_parse
print_lineno_print:
	push 0
	push offset read_written
	push sizeof ch_lineno
	push offset ch_lineno
	push stdout
	call WriteConsoleA
	pop ebp
	ret
print_lineno endp

print_num proc
	.code
	push ebp
	mov ebp, esp
	sub esp,4
	call get_cursorpos
	mov disp_read.x, 20
	mov disp_read.y, 30
	call print_newline

	mov byte ptr [ebp-1], '0'
	mov ecx, 5
print_num_cycle:
	push ecx					; save ecx to stack
	push 100					; milliseconds
	call Sleep

	push offset read_written
	push console_info.dwCursorPosition
	push 1
	lea eax, [ebp-1]			; use address to char
	push eax
	push stdout
	call WriteConsoleOutputCharacterA
	xor eax,eax					; clear
	add byte ptr [ebp-1], 1			
	pop ecx						;restore ecx
	mov eax, ecx
	add al, 34h
	cmp byte ptr [ebp-1], al
	jg print_num_finish
	
	jmp print_num_cycle
print_num_finish:
	add console_info.dwCursorPosition.x, 1
	mov byte ptr [ebp-1], '0'
	loop print_num_cycle

	mov esp, ebp
	pop ebp
	ret
print_num endp

print_buffer proc
	; take a dword value for a count from stack
	push ebp
	mov ebp, esp
	
	; call WriteConsoleA to write global buffer of passed value
	push 0
	push offset read_written
	push [ebp+8]
	push offset buffer
	push stdout
	call WriteConsoleA
	pop ebp
	ret
print_buffer endp

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
	cmp eax, 0 				; exit if 0
	je print_int_finish
	mov ebx, 10 				; we want to get the ascii value
	sub edx, edx
	div ebx
	add dl, 30h
	push edx
	inc ecx
	jmp print_int_loop
print_int_finish: 				; we are done
	mov dword ptr [ebp-4], ecx
	cmp ecx, 0 				; is it a 0?
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

;===================================
; print_results
; deal with our formatting and taking user input
;===================================
print_results proc
	; Passed a pointer to astruct containing total and count
	; do the averaging here
	.data
	resultr real8 ?
	round_to real8 0.5
	resulti dword ?

	print_results_negative byte "Found a negative number.",0dh,0ah,0dh,0ah,0
	print_results_sum byte "Sum: ",0
	print_results_count byte "Count: ",0
	print_results_average byte "Average: ",0

	.code
	push ebp
	mov ebp, esp

	; Print negative found msg
	push 0
	push offset read_written
	push sizeof print_results_negative-1
	push offset print_results_negative
	push stdout
	call WriteConsoleA

	; Print sum msg
	push 0
	push offset read_written
	push sizeof print_results_sum-1
	push offset print_results_sum
	push stdout
	call WriteConsoleA

	mov esi, [ebp+8]			; place the pointer of the struct in esi

	mov  eax, [esi]				; fill eax with our total

	; Printing our total
	push esi					; save our esi position
	push eax					; push our value
	call print_int 				; print our
	add esp, 4 					; adjust our stack
	pop esi 					; restor esi

	call print_newline

	push 0
	push offset read_written
	push sizeof print_results_count-1
	push offset print_results_count
	push stdout
	call WriteConsoleA

	mov  eax, [esi+4]			; fill eax with our count

	; Printing our count
	push esi					
	push eax
	call print_int
	add esp, 4
	pop esi

	call print_newline

	; Printing formatting label
	push 0
	push offset read_written
	push sizeof print_results_average-1
	push offset print_results_average
	push stdout
	call WriteConsoleA

	; Printing our average, use floating points for comparison
	mov eax, [esi]				; first value is the total
	sub edx, edx				; clear edx
	div dword ptr [esi+4]		; div eax by our count
	push eax

	mov resulti, edx			; mov our remainder into a dword
	fild resulti 				; add to fpu stack the int
	fidiv dword ptr [esi+4]		; divide by count
	fcom round_to 				; do our compare to rounding thresh
	fnstsw ax 					; copy our flags to ax
	sahf 						; set eflags with ah
	jb print_results_no_round 	; if we are lower than threshold, no round
print_results_round:
	pop eax 					; reclaim eax
	add eax, 1					; add one for rounding
	jmp print_results_pass 		; jump to pass and finish
print_results_no_round: 		; when we don't round, go here
	pop eax 					; reclaim eax
print_results_pass: 			; print our results
	push eax
	call print_int
	add esp, 4

	call print_newline

	pop ebp
	ret
print_results endp

;===================================
; get_cursorpos
; set a global variable with the current cursor position
;===================================
get_cursorpos proc
	push offset console_info
	push stdout
	call GetConsoleScreenBufferInfo
	sub ebx, ebx
	mov bx, console_info.dwCursorPosition.x
	mov disp_status.x, 30
	mov bx, console_info.dwCursorPosition.y
	mov disp_status.y, bx
	ret
get_cursorpos endp

;===================================
; get_values_parse
; parse through the values collected from user
;===================================
get_values_parse proc
	.data
	get_values_parse_msg byte "Nothing to do!",0dh,0ah,0
	.code
	push ebp
	mov ebp, esp

	mov esi, [ebp+8]			; place in esi our passed var
	
	; place int registers our struct values
	mov eax, (RESULT ptr [esi]).answer
	mov ebx, (RESULT ptr [esi]).count

	; We just want to do some checking to see what kind of input
	; the user has given us, and avoid some errors

	cmp eax, 0 					; was our answer 0?
	jg input_finish				; no, finish
	je input_zero				; yes, check for input like 0
input_zero:
	cmp ebx, 0 					; check count
	jg input_finish 			; we had some input, finish
	je input_nothing			; 0 input, just exit and return
input_finish:
	push offset user_result
	call print_results
	add esp, 4
	jmp input_exit
input_nothing:
	push 0
	push offset read_written
	push sizeof get_values_parse_msg-1
	push offset get_values_parse_msg
	push stdout
	call WriteConsoleA
input_exit:
	pop ebp
	ret
get_values_parse endp

cleanup proc
; Free the username
	push username
	push dwFlags
	push hHeap
	call HeapFree
	ret
cleanup endp

display_results proc
	push offset user_result
	call get_values
	add esp, 4

	call print_newline

	push offset user_result
	call get_values_parse
	add esp, 4

	call print_newline
	ret
display_results endp

main proc
	call init 						; imitialize the process environment
	call display_introduction		; display our inrtro
	call get_user 					; call for user input
	call print_newline
	call print_username

	call display_instructions

	call display_results
	call print_num

	call display_exit 				; display our exit message
	call cleanup					; cleanup allocated memory

	push 0
	call ExitProcess
main endp

end main
