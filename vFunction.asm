global calcularPuntos 

; %1 label where to jump 
; %2 register o mem that contains the number in char that we want to convert to int 
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
	    mov r14b, byte [%2]
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

; %1 rangoX
; %2 rangoY
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

; %1 beginX
; %2 endX
; %3 beginY
; %4 endY 
; %5 rangoX 
; %6 rangoY
; %7 r12 ; donde está la funcion
; %8 xmm0 ; el incremento
%macro calcular 8 
	
	; for i = 0; i < 6; i +=2 
	xor rbx, rbx 
	xor r13, r13 
	xorpd xmm1, xmm1
	xorpd xmm2, xmm2

	%%forRango: 
		mov r13, qword[%5 + (rbx*8)] ;beginX
		mov qword[%1], r13
		mov r13, qword[%5 + (rbx*8)+8] ;endX 
		mov qword[%2], r13 
		
		mov r13, qword[%6 + (rbx*8)] ;beginY 
		mov qword[%3], r13 
		mov r13, qword[%6 + (rbx*8)+8] ;endY 
		mov qword[%4], r13  

		
		whileBeginEnd %1, %2, %3, %4, %7, %8, pointsX, pointsY  

		add rbx, 2  
		cmp rbx, 6 
		jl %%forRango

%endmacro

; %1 beginX
; %2 endX
; %3 beginY
; %4 endY 
; %5 r12 ; donde está la función  
; %6 xmm0 ; el incremento
; %7 pointsX
; %8 pointsY
%macro whileBeginEnd 8 
	
	cvtsi2sd xmm1, [%1]
	cvtsi2sd xmm2, [%2]

	cvtsi2sd xmm3, [%3]
	cvtsi2sd xmm4, [%4] 

	%%whileBeginEnd: 	
		
		forFillPoints %1, %2, %3, %4, %6, %7, %8  
		; shuntingYard %5, %7, %8, operand1, operand2, result 

		ucomisd xmm1, xmm2
		jb %%whileBeginEnd
	

%endmacro


; %1 beginX xmm1 
; %2 endX xmm2 
; %3 beginY xmm3 
; %4 endY xmm4 
; %5 xmm0 ; el incremento
; %6 pointsX
; %7 pointsY
%macro forFillPoints 7 
	
	; for j = 0; j < 8; ++j 
	xor r13, r13 

	%%forFill8:
		%%fillX: 
			cmp qword[%3], 0
			jne %%fillYandX
			cmp qword[%4], 0 
			jne %%fillYandX

			ucomisd xmm1, xmm2 	
			jae %%putCeroX 

			movsd qword[%6+(r13*8)], xmm1 
			addsd xmm1, xmm0 

			%%putCeroX: 
				xorpd xmm6, xmm6
				movsd qword[%6+(r13*8)], xmm6
				jmp %%finForFill8 	

		%%fillYandX: 
			ucomisd xmm1, xmm2 
			jae %%putCeroXandY 
			ucomisd xmm3, xmm4 
			jae %%putCeroXandY 

			movsd qword[%6+(r13*8)], xmm1
			movsd qword[%7+(r13*8)], xmm3 

			addsd xmm1, xmm0 
			addsd xmm3, xmm0  			

			%%putCeroXandY: 
				xorpd xmm6, xmm6 
				xorpd xmm7, xmm7 
				movsd qword[%6+(r13*8)], xmm6
				movsd qword[%7+(r13*8)], xmm7 
	
	%%finForFill8: 
		inc r13 	
		cmp r13, 8  
		jl %%forFill8  


%endmacro

section .data

rangoX dq 0, 0, 0, 0, 0, 0
rangoY dq 0, 0, 0, 0, 0, 0

beginX dq 0 
endX dq 0 

beginY dq 0 
endY dq 0 

pointsX dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
pointsY dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0  

section .text

; calcularPuntos(char* informacion, double* puntos, double incremento ,int sizeOfMessage, char* message) 
; info db "a,b,c,d,e,f,a2,b2,c2,d2,e2,f2, tipo, funcion"
; rdi - informacion
; rsi - puntos 
; xmm0 - incremento 
; rcx - sizeOfMessage
; r8 - message 

calcularPuntos:
	pushPila
	forGetRangos rangoX, rangoY 
	
	calcular beginX, endX, beginY, endY, rangoX, rangoY, r12, xmm0	 			

	popPila