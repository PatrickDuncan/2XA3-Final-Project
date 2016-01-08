%include "asm_io.inc"

segment .data
argumentError: db "Incorrect number of arguments",0,0
lowerError: db "A character in the string is not in the set {a,b,...,y,z}",0,0
lengthError: db "The length of the string is incorrect",0,0

segment .bss
X: resd 20		
Y: resd 20
N: resd 1		
k: resd 1
max: resd 1
nUnder: resd 1

segment .text
	global asm_main
asm_main:
	enter 0,0               		;setup routine
	pusha

	;Check arguments
	mov eax, dword [ebp+8] 			;moves first arg to eax
	cmp eax, dword 2 			;checks if it has 2 args.
	je Init							

	;Print error and quit 
	mov eax, argumentError			;calls error 
	call print_string			;print error message
	jmp Done 					

	Init:
		mov ebx, dword [ebp+12] 	;address of argv[] 
		mov eax, dword [ebx+4] 		;get argv[1] argument
		mov ebx, eax
		mov edx, eax
		mov ecx, 0

	CountLength:
		mov al, byte [ebx]		;takes first byte/letter from ebx into al.
		cmp byte [ebx], 0		;checks if next char is blank
		je Next	
		cmp byte [ebx], 'a'
		jb CaseError
		cmp byte [ebx], 'z'
		ja CaseError
		inc ecx
		inc ebx				;move to next char
		jmp CountLength

	Next:
		cmp ecx, 20			
		ja LenError 			;>20
		mov [N], ecx
		mov ecx, 0			;set counter to 0 again
		mov ebx, edx

	ToArray:
		mov al, byte [ebx]		;takes first byte/letter from ebx into al.
		cmp byte [ebx], 0		;checks if next char is blank
		je DoneArray
		mov edx, X
		add edx, ecx
		mov [edx], al
		inc ebx				;move to next char
		inc ecx
		jmp ToArray

	DoneArray:
		mov edx, X			;X[N] = 0
		add edx, ecx
		mov [edx], al
		push X
		push dword [N]
		push dword 0
		call display
		add esp, 12			;restore the stack
		mov [k], dword 0

	CallMaxLyn:
		push X				;Z 
		push dword [N]			;N
		push dword [k]			;k
		call maxLyn 				
		add esp, 12
		inc dword[k]
		mov eax, [N]
		cmp dword[k], eax
		jge FinishMaxLyn
		jmp CallMaxLyn

	FinishMaxLyn:
		push Y
		push dword [N]
		push dword 1
		call display
		add esp, 12
		jmp Done

	LenError:
		mov eax, lengthError		;calls error 
		call print_string		;print error message
		call print_nl
		jmp Done

	CaseError:
		mov eax, lowerError		;calls error 
		call print_string		;print error message
		call print_nl
		jmp Done
		
	Done:
		call print_nl
		popa
		leave                     
		ret

global display
display:					;displays an array's contents
	enter 0,0           
	mov ebx, dword[ebp+16]			;X arg
	mov ecx, dword[ebp+12]			;N arg
	mov edx, dword[ebp+8]			;Flag
	cmp edx, dword 0			;0 for chars, 1 for nums
	jne DisplayNums

	DisplayChars:
		cmp ecx, dword 0
		jbe TillEnter
		mov al, byte [ebx]		;takes first byte/letter from ebx into al.
		call print_char
		dec ecx
		inc ebx				;move to next char
		jmp DisplayChars

	DisplayNums:
		cmp ecx, dword 0
		jbe Return
		mov eax, dword [ebx]
		call print_int
		mov al, ' '
		call print_char
		dec ecx
		add ebx, dword 4		;move to next char
		jmp DisplayNums

	TillEnter:
		call read_char			;must press enter to leave input
		jmp Return

	Return:
		leave	
		ret

global maxLyn
maxLyn:						;computes the maxLyn algorithm
	enter 0,0       
	mov eax, dword[ebp+16]			;eax = X
	mov ecx, dword[ebp+12]			;ecx = N
	mov edx, dword[ebp+8]			;edx = k

	mov [nUnder], ecx
	dec dword[nUnder]			;ecx = n-1
	cmp edx, dword[nUnder]			;if k = n-1
	je Return1
	mov [max], dword 1
	mov ebx, edx
	inc ebx					;ebx = i = k+1
	Loop:					;k+1 to n-1
		cmp ebx, dword[N] 		
		je Return2
		add eax, ebx			;add i

		sub eax, dword[max]		;i-max
		mov cl, byte[eax]

		add eax, dword[max]		;eax = Z[i] -> i-max+max = i

		cmp cl, byte[eax]		;if Z[i-p] != Z[i]
		je IncrementLoop
		cmp cl, byte[eax]		;if Z[i-p] > Z[i]
		jg Return2

		mov [max], ebx			;max = p=i+1-k
		inc dword[max]
		sub [max], edx

	IncrementLoop:	
		sub eax, ebx			;reset pointer
		inc ebx
		jmp Loop
	
	Return1:
		mov eax, Y
		mov ebx, [k]
		lea ebx, [ebx*4]
		add eax, ebx
		mov [eax], dword 1
		leave
		ret

	Return2:
		mov eax, Y
		mov ebx, [k]
		lea ebx, [ebx*4]
		add eax, ebx
		mov edx, dword[max]
		mov [eax], edx
		leave	
		ret
