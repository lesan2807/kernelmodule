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
	    inc %2
	    jmp %%getNumber

%endmacro

%macro getNumberFromStringMem 2
		xor r10, r10 
		mov r10, %2 
		getNumberFromString %1, r10 
		
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
		shuntingYard %5, %7, %8, operand1, operand2, result 

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
			jmp %%finForFill8

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
			jmp %%finForFill8

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

; %1 r12 ; donde está la función  
; %2 pointsX
; %3 pointsY
; %4 operand1 
; %5 operand2 
; %6 result
%macro shuntingYard 6
	

	%%shuntingYardBegin:
		xor r15, r15 	
		xor r14, r14 
	; for each token 
 
		; limpiar el token 

	%%cleanToken:
		mov byte[charToken+r14], '-' 
		inc r14 
		cmp r14, 10
		jl %%cleanToken 	

		xor r14, r14 
	%%checkIfToken: 
		cmp byte[%1], ','
		je %%checkWhatToDo
		mov r14b, byte[%1] 
		mov [charToken+r15], r14b
		inc r15
		inc %1 
		jmp %%checkIfToken

	%%checkWhatToDo:
		; switch gigante de si es operador o si es operando
		cmp byte[charToken], 'x'
		je %%itIsAnX

		cmp byte[charToken], 'y'
		je %%itIsAnY

		cmp byte[charToken], 's'
		je %%checkSen 

		cmp byte[charToken], 'c'
		je %%checkCos

		cmp byte[charToken], 'l'
		je %%checkLn 

		cmp byte[charToken], '+'
		je %%itIsSum
		
		cmp byte[charToken], '-'
		je %%itIsResta

		cmp byte[charToken], '*'
		je %%itIsMul 

		cmp byte[charToken], '/'
		je %%itIsDiv  

	%%getNumber:
		xor r13, r13	
		getNumberFromStringMem %%broadcastNum, charToken
		%%broadcastNum: 
			cvtsi2sd xmm4, r13
			movsd qword[number], xmm4  
			pushNumberToStack number
		jmp %%endOfShuntingYard

	%%itIsDiv: 
		popOperandFromStack operand2 
		popOperandFromStack operand1 

		calculateDiv operand1, operand2, result, 32 
		calculateDiv operand1, operand2, result, 0 

		jmp %%endOfShuntingYard
	
	%%itIsMul: 
		popOperandFromStack operand2 
		popOperandFromStack operand1

		calculateMul operand1, operand2, result, 32 
		calculateMul operand1, operand2, result, 0

		jmp %%endOfShuntingYard

	%%itIsResta: 
		popOperandFromStack operand2 
		popOperandFromStack operand1 

		calculateResta operand1, operand2, result, 32 
		calculateResta operand1, operand2, result, 0

		jmp %%endOfShuntingYard
	
	%%itIsSum: 
		popOperandFromStack operand2 
		popOperandFromStack operand1 

		calculateSum operand1, operand2, result, 32 
		calculateSum operand1, operand2, result, 0

		jmp %%endOfShuntingYard
	
	%%itIsAnX: 
		pushToStack pointsX
		jmp %%endOfShuntingYard
	%%itIsAnY: 
		pushToStack pointsY
		jmp %%endOfShuntingYard
	
	%%checkLn:
		cmp byte[charToken+4], 'x'
		jne %%lnYPoints 
		calculateLn pointsX, lnX, %%endOfShuntingYard
		pushToStack lnX 
		jmp %%endOfShuntingYard
		%%lnYPoints: 
			calculateLn pointsY, lnY, %%endOfShuntingYard
			pushToStack lnY 
		jmp %%endOfShuntingYard
	
	%%checkCos: 
		cmp byte[charToken+4], 'x'
		jne %%cosYPoints 
		calculateCos pointsX, cosX, %%endOfShuntingYard
		pushToStack cosX 
		jmp %%endOfShuntingYard
		%%cosYPoints: 
			calculateCos pointsY, cosY, %%endOfShuntingYard
			pushToStack cosY 
		jmp %%endOfShuntingYard
	
	%%checkSen: 
		cmp byte[charToken+4], 'x'
		jne %%sinYPoints 
		calculateSin pointsX, sinX, %%endOfShuntingYard
		pushToStack sinX 
		jmp %%endOfShuntingYard
		%%sinYPoints: 
			calculateSin pointsY, sinY, %%endOfShuntingYard
			pushToStack sinY 
		jmp %%endOfShuntingYard
	

	%%endOfShuntingYard:
		inc %1 
		cmp byte[%1], 0
		jne %%shuntingYardBegin

		popOperandFromStack resultFinal
		mov r12, rdi 
		add r12, 24 
%endmacro

; %1 memory or register to push 
%macro pushToStack 1
		
	mov r15, 7 
	
	%%pushOperand: 
		push qword[%1+r15*8]
		dec r15 
		cmp r15, -1 
		jg %%pushOperand		

%endmacro 

%macro pushToStack4 1
		
	mov r15, 3 
	
	%%pushOperand: 
		push qword[%1+r15*8]
		dec r15 
		cmp r15, -1 
		jg %%pushOperand		

%endmacro 

%macro pushNumberToStack 1
		
	mov r15, 7 
	
	%%pushOperand: 
		push qword[%1]
		dec r15 
		cmp r15, -1 
		jg %%pushOperand		

%endmacro 


; %1 memory or register to pop  
%macro popOperandFromStack 1
	
	xor r15, r15 
	%%popOperand: 
		pop qword[%1+r15*8]
		inc r15 
		cmp r15, 8
		jl %%popOperand 

%endmacro

; %1 pointsX or pointsY 
; %2 cosX or CosY 
; %3 label to jmp to 
%macro calculateCos 3 
	
	mov r15, 7 
	%%calculateCos:
		cmp r15, -1 
		je %3
		fld qword[%1+r15*8]
		fcos	
		fstp qword[%2+r15*8]
		dec r15 
		jmp %%calculateCos

%endmacro

; %1 pointsX or pointsY 
; %2 sinX or sinY 
; %3 label to jmp to 
%macro calculateSin 3 
	
	mov r15, 7 
	%%calculateSin:
		cmp r15, -1 
		je %3
		fld qword[%1+r15*8]
		fsin	
		fstp qword[%2+r15*8]
		dec r15 
		jmp %%calculateSin 

%endmacro

; %1 pointsX or pointsY 
; %2 lnX or lnY 
; %3 label to jmp to 
%macro calculateLn 3 
	
	mov r15, 7 
	%%calculateLn: 
		cmp r15, -1 
		je %3 
		
		fld1
		fldl2e  
		fdivp st1, st0 ; 1/log2(e) 
		
		fld qword[%1+r15*8]
		fyl2x
		
		fstp qword[%2+r15*8]
		dec r15 
		jmp %%calculateLn

%endmacro
;%1 operand1 
;%2 operand2 
;%3 result 
;%4 increment 
%macro calculateDiv 4
	
	vmovupd ymm6, [%1+%4]
	vmovupd ymm7, [%2+%4] 

	vdivpd ymm5, ymm6, ymm7 
	vmovupd [%3], ymm5
	pushToStack4 %3  

%endmacro 

%macro calculateMul 4
	
	vmovupd ymm7, [%1+%4]
	vmovupd ymm6, [%2+%4] 

	vmulpd ymm5, ymm7, ymm6 
	vmovupd [%3], ymm5
	pushToStack4 %3  

%endmacro 

%macro calculateSum 4
	
	vmovupd ymm7, [%1+%4]
	vmovupd ymm6, [%2+%4] 

	vaddpd ymm5, ymm7, ymm6 
	vmovupd [%3], ymm5
	pushToStack4 %3  

%endmacro 

%macro calculateResta 4
	
	vmovupd ymm7, [%1+%4]
	vmovupd ymm6, [%2+%4] 

	vsubpd ymm5, ymm7, ymm6 
	vmovupd [%3], ymm5
	pushToStack4 %3  

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

charToken db "----------" , 0 

number dq 0.0

sinX dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
sinY dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0

cosX dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
cosY dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0

lnX dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
lnY dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0

operand1 dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
operand2 dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0

result dq 0.0, 0.0, 0.0, 0.0
resultFinal dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0

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