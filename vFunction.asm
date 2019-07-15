global calcularPuntos 

%macro getNumberFromString 2
	%%getNumber: 
		cmp byte [%2], '0'
	    jb %1
	    cmp byte [%2], '9'
	    ja %1
	    shl r13,1
	    mov r14, r13
	    shl r13,2
	    add r14, r13
	    mov r13, r14
	    xor r14, r14
	    mov r14b, byte [r12]
	    and r14b, 0x0F
	    add r13, r14
	    inc r12
	    jmp %%getNumber

%endmacro

%macro pushPila 0
	push rbp 
	mov rbp, rsp 

	; callee saved 
	push rbx 
	push r12
	push r13
	push r14
	push r15
%endmacro

%macro popPila 0
	pop r15
	pop r14
	pop r13
	pop r12 
	pop rbx

	pop rbp
	ret	
%endmacro

%macro forGetRangos 2 
	mov rbx, 0 ; i 
	mov r12, rdi 

	%%forRangoX:
		xor r13, r13 
		getNumberFromString saveNumberRangeX, r12

	%%forRangoY:
		xor r13, r13 
		getNumberFromString saveNumberRangeY, r12

	saveNumberRangeX:
		inc r12
		mov [%1+(rbx*8)], r13
		inc rbx 
		jmp %%incForIX

	saveNumberRangeY:
		inc r12
		mov [%2+(rbx*8)], r13
		inc rbx
		jmp %%incForIY

	%%incForIX:	
		cmp rbx, 6
		jl %%forRangoX

		mov rbx,0  
	%%incForIY:
		cmp rbx, 6 
		jl %%forRangoY 

%endmacro

section .data

rangoX dq 0, 0, 0, 0, 0, 0
rangoY dq 0, 0, 0, 0, 0, 0

section .text

calcularPuntos:
	pushPila
	forGetRangos rangoX, rangoY 
	

	popPila